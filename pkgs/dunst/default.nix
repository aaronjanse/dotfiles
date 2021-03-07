{ dunst, symlinkJoin, makeWrapper, fetchFromGitHub }:
symlinkJoin
{
  name = "dunst-custom";
  paths = [
    (dunst.overrideAttrs (attrs: {
      src = fetchFromGitHub {
        repo = "dunst";
        owner = "dunst-project";
        rev = "0e6997b6fcb9bb89c961597123945bc0075445c9";
        hash = "sha256-SNGrxcQhDflvaN9GWzyA46bVJHpmAWF83ew8zgFxStI=";
      };
    }))
  ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    makeProgram $out/bin/dunst --add-flags "-config ${./dunstrc.ini}"
  '';
}
