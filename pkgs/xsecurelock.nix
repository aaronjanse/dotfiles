{ xsecurelock, symlinkJoin, makeWrapper }:
symlinkJoin
{
  name = "xsecurelock-custom";
  paths = [
    xsecurelock
  ];
  buildInputs = [ makeWrapper ];

  # https://github.com/google/xsecurelock/issues/97
  postBuild = ''
    wrapProgram $out/bin/xsecurelock \
                --set XSECURELOCK_PASSWORD_PROMPT time_hex \
                --add-flags "--backend glx"
  '';
}
