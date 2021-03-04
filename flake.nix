{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };
  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux; in
    {
      packages.x86_64-linux = rec {
        cilium = pkgs.callPackage ./pkgs/cilium.nix { };
        foliate = pkgs.libsForQt5.callPackage ./pkgs/foliate.nix { };
        gr = pkgs.libsForQt5.callPackage ./pkgs/gr.nix { };

        python3 = (pkgs.python38.withPackages (ps: with ps; [
          numpy
          sympy
          jupyter
        ])).override (args: { ignoreCollisions = true; });

        julia = pkgs.symlinkJoin {
          name = "julia-custom";
          paths = [
            pkgs.julia
          ];
          postBuild = ''
            mv $out/bin/julia $out/bin/.julia-impl
            cat > $out/bin/julia << EOF
            export GHDIR=${gr}
            export PYTHONPATH=${python3}/lib/python3.8/site-packages
            if [ -f "\$HOME/sys_calc.so" ]; then
              exec -a "\$0" $out/bin/.julia-impl -J"\$HOME/sys_calc.so" "\$@"
            else
              exec -a "\$0" $out/bin/.julia-impl "\$@"
            fi
            EOF
            chmod +x $out/bin/julia
          '';
          passthru = {
            shellPath = "/bin/julia";
          };
        };

        profiles = { };
      };
    };
}
