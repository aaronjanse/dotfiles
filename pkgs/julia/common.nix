{
  callPackage,
  curl,
  fetchurl,
  git,
  stdenvNoCC,
  cacert,
  jq,
  julia,
  lib,
  python3,
  runCommand,
  stdenv,
  writeText,
  makeWrapper,

  # Arguments
  makeWrapperArgs ? "",
  precompile ? true,
  extraBuildInputs ? []
}:

let
  # We need to use a specially modified fetchgit that understands tree hashes, until
  # https://github.com/NixOS/nixpkgs/pull/104714 lands
  fetchgit = callPackage ./fetchgit {};

  packages = callPackage ./packages.nix {};

  ### Repoify packages
  # This step is needed because leaveDotGit is not reproducible
  # https://github.com/NixOS/nixpkgs/issues/8567
  repoified = map (item: if item.src == null then item else item // { src = repoify item.name item.treehash item.src; }) packages.closure;
  repoify = name: treehash: src:
    runCommand ''${name}-repoified'' {buildInputs = [git];} ''
      mkdir -p $out
      cp -r ${src}/. $out
      cd $out
      git init
      git add . -f
      git config user.email "julia2nix@localhost"
      git config user.name "julia2nix"
      git commit -m "Dummy commit"

      if [[ -n "${treehash}" ]]; then
        if [[ $(git cat-file -t ${treehash}) != "tree" ]]; then
          echo "Couldn't find desired tree object for ${name} in repoify (${treehash})"
          exit 1
        fi
      fi
    '';
  repoifiedReplaceInManifest = lib.filter (x: x.replaceUrlInManifest != null) repoified;

  ### Manifest.toml (processed)
  manifestToml = runCommand "Manifest.toml" { buildInputs = [jq]; } ''
    cp ${./Manifest.toml} ./Manifest.toml

    echo ${writeText "packages.json" (lib.generators.toJSON {} repoifiedReplaceInManifest)}
    cat ${writeText "packages.json" (lib.generators.toJSON {} repoifiedReplaceInManifest)} | jq -r '.[]|[.name, .replaceUrlInManifest, .src] | @tsv' |
      while IFS=$'\t' read -r name replaceUrlInManifest src; do
        sed -i "s|$replaceUrlInManifest|file://$src|g" ./Manifest.toml
      done

    cp ./Manifest.toml $out
  '';

  ### Overrides.toml
  fetchArtifact = x: stdenv.mkDerivation {
    name = x.name;
    src = fetchurl { url = x.url; sha256 = x.sha256; };
    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;
    installPhase = "cp -r . $out";
    dontFixup = true;
  };
  artifactOverrides = lib.zipAttrsWith (name: values: fetchArtifact (lib.head (lib.head values))) (
    map (item: item.artifacts) packages.closure
  );
  overridesToml = runCommand "Overrides.toml" { buildInputs = [jq]; } ''
    echo '${lib.generators.toJSON {} artifactOverrides}' | jq -r '. | to_entries | map ((.key + " = \"" + .value + "\"")) | .[]' > $out
  '';

  ### Processed registry
  generalRegistrySrc = repoify "julia-general" "" (fetchgit {
    url = packages.registryUrl;
    rev = packages.registryRev;
    sha256 = packages.registrySha256;
    branchName = "master";
  });
  registry = runCommand "julia-registry" { buildInputs = [(python3.withPackages (ps: [ps.toml])) jq git]; } ''
    git clone ${generalRegistrySrc}/. $out
    cd $out

    cat ${writeText "packages.json" (lib.generators.toJSON {} repoified)} | jq -r '.[]|[.name, .path, .src] | @tsv' |
      while IFS=$'\t' read -r name path src; do
        # echo "Processing: $name, $path, $src"
        if [[ "$path" != "null" ]]; then
          python -c "import toml; \
                     packageTomlPath = '$path/Package.toml'; \
                     contents = toml.load(packageTomlPath); \
                     contents['repo'] = 'file://$src'; \
                     f = open(packageTomlPath, 'w'); \
                     f.write(toml.dumps(contents)); \
                     "
        fi
      done

    export HOME=$(pwd)
    git config --global user.email "julia-to-nix-depot@email.com"
    git config --global user.name "julia-to-nix-depot script"
    git add .
    git commit -m "Switch to local package repos"
  '';

  depot = runCommand "julia-depot" {
    buildInputs = [git curl julia] ++ extraBuildInputs;
    inherit registry precompile;
  } ''
    export HOME=$(pwd)

    echo "Using registry $registry"
    echo "Using Julia ${julia}/bin/julia"

    cp ${manifestToml} ./Manifest.toml
    cp ${./Project.toml} ./Project.toml

    mkdir -p $out/artifacts
    cp ${overridesToml} $out/artifacts/Overrides.toml

    export JULIA_DEPOT_PATH=$out
    julia -e ' \
      using Pkg
      Pkg.Registry.add(RegistrySpec(path="${registry}"))

      Pkg.activate(".")
      Pkg.instantiate()

      # Remove the registry to save space
      Pkg.Registry.rm("General")
    '

    if [[ -n "$precompile" ]]; then
      julia -e ' \
        using Pkg
        Pkg.activate(".")
        Pkg.precompile()
      '
    fi
  '';

in

runCommand "julia-env" {
  inherit julia depot makeWrapperArgs;
  buildInputs = [makeWrapper];
} ''
  mkdir -p $out/bin
  makeWrapper $julia/bin/julia $out/bin/julia --suffix JULIA_DEPOT_PATH : "$depot" $makeWrapperArgs
''
