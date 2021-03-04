{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: let pkgs = nixpkgs.legacyPackages.x86_64-linux; in {
    packages.x86_64-linux =  {
      cilium = pkgs.callPackage (
        { lib, fetchFromGitHub, buildGoModule }:
        buildGoModule rec {
          pname = "cilium";
          version = "1.9.1";
          vendorSha256 = null;
          doCheck = false;
          src = fetchFromGitHub {
            owner = "cilium";
            repo = "cilium";
            rev = "v${version}";
            sha256 = "sha256-SpGxzwXwOgWrA8hFvBmq2Zrwa+aem7BMzHuYvV6ei+c=";
          };
        }
      ) { };
    };
  };
}
