{ lemonbar-xft, runCommand, python36, fetchFromGitHub, alsaUtils, mullvad-vpn, playerctl }:

runCommand "lemonbar-custom"
{
  LEMONBAR = lemonbar-xft.overrideAttrs (attrs: {
    src = fetchFromGitHub {
      owner = "freundTech";
      repo = "bar";
      rev = "2cc9282bdb24458c0954c3f311031116ee305eec";
      hash = "sha256-KGntGag5ASm5LOHzyEr8HroVaItK1dIZP8H7FhM5wl8=";
    };
  });
  PYTHON = python36.withPackages (ps: with ps; [ psutil i3ipc ]);
} ''
  mkdir -p $out/bin
  cat > $out/bin/lemonbar << EOF
  export PATH=${alsaUtils}/bin:${mullvad-vpn}/bin:${playerctl}/bin:\$PATH
  $PYTHON/bin/python3 -u ${./status.py} | $LEMONBAR/bin/lemonbar \
      -f "Overpass Mono:pixelsize=25;0" -f "Font Awesome 5 Free:pixelsize=25;0" \
      -f "Font Awesome 5 Free:style=Solid:pixelsize=25;0" -f "Font Awesome 5 Brands:pixelsize=25;0" \
      -f "Source Code Pro:pixelsize=25;0" -u 4 -g x60 -B "#00000000"
  EOF
  chmod +x $out/bin/lemonbar
''
