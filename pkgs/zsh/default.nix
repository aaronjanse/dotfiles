{ zsh, zsh-autosuggestions, zsh-syntax-highlighting, nix-zsh-completions, fzf, gnupg, direnv, symlinkJoin, writeText, makeWrapper }:

let config = writeText ".zshrc" ''
  fpath+=(${nix-zsh-completions}/share/zsh/site-functions)
  for p in ''${(z)NIX_PROFILES}; do
    fpath+=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions)
  done

  autoload -U compinit && compinit

  source ${nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh
  source ${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  source ${fzf}/share/fzf/key-bindings.zsh

  eval "$(${direnv}/bin/direnv hook zsh | sed 's/\/nix\/store.\+\/direnv/${
    builtins.replaceStrings ["/"] ["\\/"] "${direnv}"
  }\/bin\/direnv/')"

  setopt HIST_IGNORE_DUPS
  setopt HIST_IGNORE_SPACE
  setopt EXTENDED_HISTORY
  setopt INC_APPEND_HISTORY

  export HISTSIZE="10000000"
  export SAVEHIST="10000000"
  export HISTFILE="$HOME/.zsh_history"
  mkdir -p "$(dirname "$HISTFILE")"

  export REPO_DIR=/home/ajanse/sp21-s367
  export SNAPS_DIR=/home/ajanse/snaps-sp21-s367
  export GOPATH=$HOME/.go

  bindkey '\e[1;2A' history-beginning-search-backward
  bindkey '\e[1;2B' history-beginning-search-forward
  bindkey '\e[1;2C' forward-word

  if [[ "$USER" != "private" ]]; then
    GPG_TTY="$(tty)"
    export GPG_TTY
    ${gnupg}/bin/gpg-connect-agent updatestartuptty /bye > /dev/null
  fi

  function wish() {
    if [ -z "$1" ]; then
      echo -ne '\e[2m'
      cat ~/.wish
      echo -ne '\e[m'
    else
      echo "$@" >> ~/.wish
    fi
  }

  precmd () { PS1=$(zsh ${./prompt.sh}) }
''; in
symlinkJoin
{
  name = "zsh-custom";
  paths = [
    zsh
  ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    cp ${config} $out/etc/.zshrc
    wrapProgram $out/bin/zsh --set ZDOTDIR $out/etc
  '';
  passthru = {
    shellPath = "/bin/zsh";
  };
}
