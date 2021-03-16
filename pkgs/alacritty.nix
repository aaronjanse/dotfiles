{ alacritty, symlinkJoin, writeText, makeWrapper, theme }:

let config = writeText "alacritty.yaml" (builtins.toJSON {
  colors = {
    bright = {
      black = "#555555";
      blue = "#bd93f9";
      cyan = "#8be9fd";
      green = "#50fa7b";
      magenta = "#ff79c6";
      red = "#ff5555";
      white = "#ffffff";
      yellow = "#f1fa8c";
    };
    normal = {
      black = "#555555";
      blue = "#bd93f9";
      cyan = "#8be9fd";
      green = "#50fa7b";
      magenta = "#ff79c6";
      red = "#ff5555";
      white = "#f8f8f2";
      yellow = "#f1fa8c";
    };
    primary = {
      background = theme.background;
      foreground = "#f8f8f2";
    };
  };
  env.TERM = "xterm-256color";
  font = {
    normal.family = "JuliaMono";
    size = 9;
  };
}); in
symlinkJoin
{
  name = "alacritty-custom";
  paths = [
    alacritty
  ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    mkdir $out/etc
    cp ${config} $out/etc/alacritty.yml
    wrapProgram $out/bin/alacritty --add-flags "--config-file=$out/etc/alacritty.yml"
  '';
}
