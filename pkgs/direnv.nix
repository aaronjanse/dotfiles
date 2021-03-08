{ direnv, nix-direnv, symlinkJoin, writeText, makeWrapper }:

let config = writeText "alacritty.yaml" ''
  source ${nix-direnv}/share/nix-direnv/direnvrc
''; in
symlinkJoin
{
  name = "direnv-custom";
  paths = [ direnv ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    mkdir $out/direnv
    cp ${config} $out/direnv/direnvrc
    wrapProgram $out/bin/direnv \
                --set XDG_CONFIG_HOME $out \
                --set DIRENV_LOG_FORMAT "$(printf "\033[1;30m %%s\033[0m")"
  '';
}
