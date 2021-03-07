{ lemonbar-xft, symlinkJoin, makeWrapper, fetchFromGitHub }:
symlinkJoin {
  name = "lemonbar-custom";
  paths = [
    (lemonbar-xft.overrideAttrs (attrs: {
      src = fetchFromGitHub {
        owner = "freundTech";
        repo = "bar";
        rev = "2cc9282bdb24458c0954c3f311031116ee305eec";
        hash = "sha256-KGntGag5ASm5LOHzyEr8HroVaItK1dIZP8H7FhM5wl8=";
      };
    }))
  ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/lemonbar --add-flags '-f "Overpass Mono:pixelsize=25;0" -f "Font Awesome 5 Free:pixelsize=25;0" -f "Font Awesome 5 Free:style=Solid:pixelsize=25;0" -f "Font Awesome 5 Brands:pixelsize=25;0" -f "Source Code Pro:pixelsize=25;0" -u 4 -g x60 -B "#00000000"'
  '';
}
