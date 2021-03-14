rec {
  # text color
  foreground = "#f8f8f2";
  # darker background for wallpaper, terminal, etc
  background = "#1d1f23";
  # background for primary editing areas in text editors etc
  backgroundSecondary = "#21252b";

  normal = {
    black = "#555555";
    blue = "#bd93f9";
    cyan = "#8be9fd";
    green = "#50fa7b";
    magenta = "#ff79c6";
    red = "#ff5555";
    white = "#f8f8f2";
    yellow = "#f1fa8c";
  };
  bright = {
    black = "#555555";
    blue = "#bd93f9";
    cyan = "#8be9fd";
    green = "#50fa7b";
    magenta = "#ff79c6";
    red = "#ff5555";
    white = "#ffffff";
    yellow = "#f1fa8c";
  };

  colors16 = map (builtins.replaceStrings [ "#" ] [ "" ]) [
    background
    normal.red
    normal.green
    normal.yellow
    normal.blue
    normal.magenta
    normal.cyan
    normal.white
    backgroundSecondary
    bright.red
    bright.green
    bright.yellow
    bright.blue
    bright.magenta
    bright.cyan
    bright.white
  ];
}
