{ gitFull, symlinkJoin, makeWrapper }:

symlinkJoin {
  name = "git-custom";
  paths = [ gitFull ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    rm $out/bin/git
    makeWrapper ${gitFull}/bin/git $out/bin/git \
                --set-default GIT_AUTHOR_NAME 'Aaron Janse' \
                --set-default GIT_AUTHOR_EMAIL 'aaron@ajanse.me' \
                --set-default GIT_COMMITTER_NAME 'Aaron Janse' \
                --set-default GIT_COMMITTER_EMAIL 'aaron@ajanse.me'
  '';
}
