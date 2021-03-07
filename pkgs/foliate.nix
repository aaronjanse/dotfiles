{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, gettext
, pkgconfig
, python3
, wrapGAppsHook
, gobject-introspection
, gjs
, gtk3
, gsettings-desktop-schemas
, webkitgtk
, glib
, desktop-file-utils
, hicolor-icon-theme
, libarchive
, dict
}:

stdenv.mkDerivation rec {
  pname = "foliate";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = pname;
    rev = version;
    sha256 = "sha256-udRSsTBiIL0178jR9q0XuwJ6hzK/0wcbpHioM5sGDHM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    gettext
    python3
    desktop-file-utils
    wrapGAppsHook
    hicolor-icon-theme
  ];

  buildInputs = [
    glib
    gtk3
    gjs
    webkitgtk
    gsettings-desktop-schemas
    gobject-introspection
    libarchive
    # TODO: Add once packaged, unclear how language packages best handled
    # hyphen
    dict # dictd for offline dictionary support
  ];

  doCheck = true;

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py
    patchShebangs build-aux/meson/postinstall.py
  '';

  dontWrapGApps = true;

  # Fixes https://github.com/NixOS/nixpkgs/issues/31168
  postFixup = ''
    sed -e $'2iimports.package._findEffectiveEntryPointName = () => \'com.github.johnfactotum.Foliate\' ' \
      -i $out/bin/com.github.johnfactotum.Foliate
    wrapGApp $out/bin/com.github.johnfactotum.Foliate
  '';

  meta = with lib; {
    description = "Simple and modern GTK eBook reader";
    homepage = "https://johnfactotum.github.io/foliate/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dtzWill ];
  };
}
