{ rofi, writeText, theme }:

rofi.override {
  # see https://manpages.ubuntu.com/manpages/bionic/man5/rofi-theme.5.html
  theme = writeText "rofi-theme" ''
    * {
      background-color: ${theme.background};
      color: #fafbfc;
      font: "Roboto Mono 24";
    }
    window {
      lines: 20;
      width: 800px;
      padding: 25px;
      border: 2px;
      border-color: #ffffff;
    }
    listview {
      lines: 15;
    }
    #element.selected.normal {
      color: #bd93f9;
    }
    #prompt {
      enabled: false;
    }
  '';
}
