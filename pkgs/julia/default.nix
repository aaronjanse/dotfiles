{ pkgs }:

with pkgs;


let
  # The base Julia version
  baseJulia = pkgs.julia;

  # Extra libraries for Julia's LD_LIBRARY_PATH.
  # Recent Julia packages that use Artifacts.toml to specify their dependencies
  # shouldn't need this.
  # But if a package implicitly depends on some library being present at runtime, you can
  # add it here.
  extraLibs = [ ];

  # Wrapped Julia with libraries and environment variables.
  # Note: setting The PYTHON environment variable is recommended to prevent packages
  # from trying to obtain their own with Conda.
  juliaWrapped = runCommand "julia-wrapped" { buildInputs = [ makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${baseJulia}/bin/julia $out/bin/julia \
                --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath extraLibs}" \
                --set PYTHON ${python3}/bin/python \
                --set GRDIR ${pkgs.callPackage ./gr.nix { }}
  '';

  juliaWithDepot = callPackage ./common.nix {
    julia = juliaWrapped;

    # Run Pkg.precompile() to precompile all packages?
    precompile = false;

    # Extra arguments to makeWrapper when creating the final Julia wrapper.
    # By default, it will just put the new depot at the end of JULIA_DEPOT_PATH.
    # You can add additional flags here.
    makeWrapperArgs = "";

    # Extra buildInputs for building the Julia depot. Useful if your packages have
    # additional build-time dependencies not managed through the Artifacts.toml system.
    # Defaults to extraLibs, but can be configured independently.
    extraBuildInputs = extraLibs;
  };

  juliaSysimage = runCommand "julia-sysimage.so" { buildInputs = [ gcc fish ]; } ''
    cp ${./Manifest.toml} Manifest.toml
    cp ${./Project.toml} Project.toml
    export JULIA_DEPOT_PATH=$TMP/jl
    mkdir -p $JULIA_DEPOT_PATH/config
    cp ${./startup.jl} $JULIA_DEPOT_PATH/config/startup.jl
    export JULIA_LOAD_PATH="@:@#.#:@stdenv:${./.}"
    export PATH=${juliaWithDepot}/bin:$PATH
    export HOME=$(mktemp -d)
    julia ${./transcript.jl} --startup-file=no
    cat ${./trace.jl} >> trace.jl
    ${juliaWithDepot}/bin/julia ${./generate_sysimage.jl} trace.jl $out
  '';
in
pkgs.symlinkJoin {
  name = "julia-custom";
  paths = [
    pkgs.julia
  ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    rm $out/bin/julia
    mkdir -p $out/etc/julia
    rm $out/etc/julia/startup.jl
    cp ${./startup.jl} $out/etc/julia/startup.jl
    makeWrapper ${juliaWithDepot}/bin/julia $out/bin/julia \
                --add-flags "-J${juliaSysimage}" \
                --prefix JULIA_DEPOT_PATH : \~/.julia \
                --set JULIA_LOAD_PATH "@:@#.#:@stdenv:${./.}" \
                --set JULIA_BINDIR $out/bin \
                --add-flags "--banner=no" \
                --prefix PATH : "${pkgs.kakoune}/bin:${pkgs.fish}/bin"
  '';

  passthru = {
    shellPath = "/bin/julia";
  };
}
