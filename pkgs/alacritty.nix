{ alacritty, symlinkJoin, writeText, makeWrapper, theme }:

let config = writeText "alacritty.yaml" ''
  {"font":{"normal":{"family":"JuliaMono"},"size":10.0},"colors":{"bright":{"black":"0x555555","blue":"#bd93f9","cyan":"#8be9fd","green":"#50fa7b","magenta":"#ff79c6","red":"#ff5555","white":"0xffffff","yellow":"#f1fa8c"},"normal":{"black":"0x000000","blue":"#bd93f9","cyan":"#8be9fd","green":"#50fa7b","magenta":"#ff79c6","red":"#ff5555","white":"0xbbbbbb","yellow":"#f1fa8c"},"primary":{"background":"${theme.background}","foreground":"#f8f8f2"}},"env":{"TERM":"xterm-256color"}}
''; in
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
    rm -rf $out/bin
    makeWrapper ${alacritty}/bin/alacritty $out/bin/alacritty \
                --add-flags "--config-file=$out/etc/alacritty.yml"
  '';
}
