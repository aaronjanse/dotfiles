{ signal-desktop, theme }:

signal-desktop.overrideAttrs (oldAttrs: {
  preFixup = oldAttrs.preFixup + ''
    cp $out/lib/Signal/resources/app.asar $out/lib/Signal/resources/app.asar.bak
    cat $out/lib/Signal/resources/app.asar.bak \
      | sed 's/background-color: #f6f6f6;/background-color: ${theme.background};/g' \
      | sed 's/#1b1b1b;/${theme.foreground};/g' \
      | sed 's/#5e5e5e;/${theme.foreground};/g' \
      | sed 's/-color: #ffffff;/-color: ${theme.backgroundSecondary};/g' \
      | sed 's/background: #ffffff;/background: ${theme.backgroundSecondary};/g' \
      | sed 's/#dedede;/#44475a;/g' \
      | sed 's/#e9e9e9;/#44475a;/g' \
      | sed 's/1px solid #ffffff;/1px solid ${theme.backgroundSecondary};/g' \
      | sed 's/#f6f6f6;/${theme.background};/g' \
      | sed 's/#b9b9b9;/#44475a;/g' \
      | sed 's/2px solid #ffffff;/2px solid ${theme.backgroundSecondary};/g' \
      | sed 's/setMenuBarVisibility(visibility);/setMenuBarVisibility(false     );/g' \
      | sed 's/setFullScreen(true)/setFullScreen(0==1)/g' \
      > $out/lib/Signal/resources/app.asar
    rm $out/lib/Signal/resources/app.asar.bak
  '';
})
