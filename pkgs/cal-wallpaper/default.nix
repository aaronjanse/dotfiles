{ runCommand, imagemagick, theme }:

runCommand "call-wallpaper.png" { } ''
  ${imagemagick}/bin/convert ${./source.png} -fuzz 16% -fill "${theme.background}" -opaque "#181920" $out
''
