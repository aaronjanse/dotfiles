{ alacritty, symlinkJoin, writeText }:

let config = writeText "alacritty.yaml" ''
  {"font":{"normal":{"family":"JuliaMono"},"size":10.0},"colors":{"bright":{"black":"0x555555","blue":"#bd93f9","cyan":"#8be9fd","green":"#50fa7b","magenta":"#ff79c6","red":"#ff5555","white":"0xffffff","yellow":"#f1fa8c"},"normal":{"black":"0x000000","blue":"#bd93f9","cyan":"#8be9fd","green":"#50fa7b","magenta":"#ff79c6","red":"#ff5555","white":"0xbbbbbb","yellow":"#f1fa8c"},"primary":{"background":"${colors.background}","foreground":"#f8f8f2"}},"env":{"TERM":"xterm-256color"}}
''; in
symlinkJoin
{
  name = "alacritty-custom";
  paths = [
    alacritty
  ];
  buildInputs = [ makeWrapper ];
  buildPhase = ''
    mkdir $out/etc
    cp ${config} $out/etc
    makeWrapper $out/bin/alacritty $out/bin/alacritty \
                --add-flags "--config-file=$out/etc/alacritty.yml"
  '';
}

