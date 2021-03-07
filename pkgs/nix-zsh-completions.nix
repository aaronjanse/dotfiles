{ nix-zsh-completions, fetchFromGitHub }:

nix-zsh-completions.overrideAttrs (attrs: {
  src = fetchFromGitHub {
    owner = "ma27";
    repo = "nix-zsh-completions";
    rev = "939c48c182e9d018eaea902b1ee9d00a415dba86";
    sha256 = "sha256-3HVYez/wt7EP8+TlhTppm968Wl8x5dXuGU0P+8xNDpo=";
  };
})
