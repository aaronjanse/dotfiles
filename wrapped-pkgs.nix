{ nixpkgsOrig }:
let
  nixpkgs = import nixpkgsOrig {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  farm = entries: nixpkgs.runCommandLocal "farm" { } (with nixpkgs.lib; ''
    mkdir $out
    cd $out
  '' + "\n" + (concatMapStrings
    (x: ''
      mkdir -p "$(dirname ${escapeShellArg x.name})"
      cp ${escapeShellArg x.path} ${escapeShellArg x.name}
    '')
    entries));

  wrap = pkg: bin: args: files:
    nixpkgs.symlinkJoin {
      name = nixpkgs.${pkg}.name + "-custom";
      paths = [ nixpkgs.${pkg} (farm files) ];
      buildInputs = [ nixpkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${bin} \
          ${builtins.concatStringsSep " " args}
      '';
      pathsToLink = [ "/share/man" "/share/doc" "/bin" "/etc" ];
      inherit (nixpkgs.${pkg}) passthru;
    };

  # Phase 1
  nixpkgs' = nixpkgs // {
    zsh = (wrap "zsh" "zsh" [ "--set ZDOTDIR ${placeholder "out"}/etc" ] [{
      name = "etc/.zshrc";
      path = nixpkgs.writeText ".zshrc" ''
        source ${nixpkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

        setopt HIST_FCNTL_LOCK
        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_SPACE
        unsetopt HIST_EXPIRE_DUPS_FIRST
        unsetopt SHARE_HISTORY
        unsetopt EXTENDED_HISTORY
        setopt autocd

        HISTSIZE="10000000"
        SAVEHIST="10000000"
        export HISTFILE="$HOME/.zsh_history"
        mkdir -p "$(dirname "$HISTFILE")"

        GPG_TTY="$(tty)"
        export GPG_TTY
        ${nixpkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye > /dev/null

        # if [[ $options[zle] = on ]] && [ -x "$(command -v fzf)" ]; then
        # fi
        source ${nixpkgs.fzf}/share/fzf/key-bindings.zsh

        source ${nixpkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        precmd () { PS1=$(zsh ${./bin/prompt.sh}) }
      '';
    }]);

    alacritty = nixpkgs.symlinkJoin {
      name = "alacritty-custom";
      paths = [
        nixpkgs.dejavu_fonts
        (wrap "alacritty" "alacritty" [ "--add-flags --config-file=${placeholder "out"}/etc/alacritty.yml" ] [{
          name = "etc/alacritty.yml";
          path = nixpkgs.writeText "alacritty.yml" ''
            {"font":{"normal":{"family":"DejaVu Sans Mono"}},"colors":{"bright":{"black":"0x555555","blue":"#bd93f9","cyan":"#8be9fd","green":"#50fa7b","magenta":"#ff79c6","red":"#ff5555","white":"0xffffff","yellow":"#f1fa8c"},"normal":{"black":"0x000000","blue":"#bd93f9","cyan":"#8be9fd","green":"#50fa7b","magenta":"#ff79c6","red":"#ff5555","white":"0xbbbbbb","yellow":"#f1fa8c"},"primary":{"background":"#181920","foreground":"#f8f8f2"}},"env":{"TERM":"xterm-256color"}}
          '';
        }])
      ];
    };

    rofi = nixpkgs.symlinkJoin {
      name = "rofi-custom";
      paths = [
        nixpkgs.roboto-mono
        (nixpkgs.rofi.override {
          # see https://manpages.ubuntu.com/manpages/bionic/man5/rofi-theme.5.html
          theme = nixpkgs.writeText "rofi-theme" ''
            * {
              background-color: #181920;
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
        })
      ];
    };

    vscode = nixpkgs.symlinkJoin {
      name = "vscode-custom";
      paths = [
        nixpkgs.lmodern
        nixpkgs.texlive.combined.scheme-full
        (nixpkgs.vscode-with-extensions.override {
          vscodeExtensions = with nixpkgs.vscode-extensions; [
            ms-vscode.cpptools
            james-yu.latex-workshop
            ms-python.python
            ms-vsliveshare.vsliveshare
          ] ++ nixpkgs.vscode-utils.extensionsFromVscodeMarketplace [
            { # broken, I think
              name = "hg";
              publisher = "mrcrowl";
              version = "1.7.1";
              sha256 = "sha256-ANHzZGAHtKoT/WGarg55jp4S4FO7/1+mFylliM9hluI=";
            }
            {
              name = "Go";
              publisher = "golang";
              version = "0.18.1";
              sha256 = "sha256-b2Wa3TULQQnBm1/xnDCB9SZjE+Wxz5wBttjDEtf8qlE=";
            }
            {
              name = "theme-dracula-refined";
              publisher = "mathcale";
              version = "2.22.1";
              sha256 = "03m44a3qmyz4mmfn1pzfcwc77wif4ldf2025nj9rys6lfhcz0x1n";
            }
            {
              name = "rust";
              publisher = "rust-lang";
              version = "0.7.8";
              sha256 = "039ns854v1k4jb9xqknrjkj8lf62nfcpfn0716ancmjc4f0xlzb3";
            }
            {
              name = "better-toml";
              publisher = "bungcip";
              version = "0.3.2";
              sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
            }
            {
              name = "nix-ide";
              publisher = "jnoortheen";
              version = "0.1.3";
              sha256 = "sha256-VCH/3nYtQ6js2p11gw0baV6NSlM4whFEhieoKb+kXrA=";
            }
          ];
        })
      ];
    };

    signal-desktop = nixpkgs.signal-desktop.overrideAttrs (
      oldAttrs: rec {
        preFixup =
          let
            foreground = "#f8f8f2";
            background = "#181920";
          in
          oldAttrs.preFixup + ''
            cp $out/lib/Signal/resources/app.asar $out/lib/Signal/resources/app.asar.bak
            cat $out/lib/Signal/resources/app.asar.bak \
              | sed 's/background-color: #f6f6f6;/background-color: ${background};/g' \
              | sed 's/#1b1b1b;/${foreground};/g' \
              | sed 's/#5e5e5e;/${foreground};/g' \
              | sed 's/-color: #ffffff;/-color: #282a36;/g' \
              | sed 's/background: #ffffff;/background: #282a36;/g' \
              | sed 's/#dedede;/#44475a;/g' \
              | sed 's/#e9e9e9;/#44475a;/g' \
              | sed 's/1px solid #ffffff;/1px solid #282a36;/g' \
              | sed 's/#f6f6f6;/${background};/g' \
              | sed 's/#b9b9b9;/#44475a;/g' \
              | sed 's/2px solid #ffffff;/2px solid #282a36;/g' \
              | sed 's/setMenuBarVisibility(visibility);/setMenuBarVisibility(false     );/g' \
              | sed 's/setFullScreen(true)/setFullScreen(0==1)/g' \
              > $out/lib/Signal/resources/app.asar
            rm $out/lib/Signal/resources/app.asar.bak
          '';
      }
    );

    xsecurelock = wrap "xsecurelock" "xsecurelock" [ "--set XSECURELOCK_PASSWORD_PROMPT time_hex" ] [ ];

    git-wrapped = wrap "gitFull" "git" [
      "--set-default GIT_AUTHOR_NAME 'Aaron Janse'"
      "--set-default GIT_AUTHOR_EMAIL 'aaron@ajanse.me'"
      "--set-default GIT_COMMITTER_NAME 'Aaron Janse'"
      "--set-default GIT_COMMITTER_EMAIL 'aaron@ajanse.me'"
    ] [ ];
  };

  nixpkgs'' = nixpkgs' // {
    i3 = nixpkgs.symlinkJoin {
      name = "vscode-custom";
      paths = [
        nixpkgs.roboto-mono
        (wrap "i3-gaps" "i3" [ "--add-flags \"-c ${placeholder "out"}/etc/i3-config\"" ] [{
          name = "etc/i3-config";
          path = import ./i3-config.nix nixpkgs';
        }])
      ];
    };
  };
in
nixpkgs''
