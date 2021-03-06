{ stdenv, lib, qt5, libGL, xorg, fetchurl }:

let
  mainDependencies = [
    qt5.qtbase
    qt5.qtsvg
    stdenv.cc.cc.lib
    libGL
    xorg.libXt
    xorg.libX11
    xorg.libXrender
    xorg.libXext
  ];
in
stdenv.mkDerivation {
  name = "GR.jl";
  version = "4.3.10";

  src = fetchurl {
    url = "https://gr-framework.org/downloads/gr-0.53.0-Debian-x86_64.tar.gz";
    hash = "sha256-sMQslobOR6FIhnPF3V8rb9X7BKz5R7X45vFfTsg91to=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out
  '';

  preFixup =
    let
      libPath = lib.makeLibraryPath (mainDependencies ++ [
        xorg.libxcb
      ]);
    in
    ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/bin/gksqt
    '';

  propagatedBuildInputs = mainDependencies ++ [
    xorg.libxcb
    xorg.xcbproto
    xorg.xcbutil
  ];
}
