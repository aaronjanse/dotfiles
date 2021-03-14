{ vscode, vscode-extensions, vscode-with-extensions, vscode-utils, texlive, symlinkJoin, makeWrapper }:
symlinkJoin {
  name = "vscode-custom";
  postBuild = ''
    ln -s $out/bin/code-insiders $out/bin/code
  '';
  paths = [
    texlive.combined.scheme-full
    (vscode-with-extensions.override {
      vscode = (vscode.override { isInsiders = true; }).overrideAttrs (_: rec {
        pname = "vscode-insiders";
        version = "nightly";
        src = builtins.fetchurl {
          name = "VSCode_latest_linux-x64.tar.gz";
          url = "https://az764295.vo.msecnd.net/insider/9ecd3fc3022e8c154aff868f74bd5d77f7d4a2ea/code-insider-x64-1614078105.tar.gz";
          sha256 = "1qn84qc1cvprrhhgpaj7nkrsixs11k9n9xvkljai6x9plq2w91my";
        };
      });
      vscodeExtensions = with vscode-extensions; [
        ms-vscode.cpptools
        matklad.rust-analyzer
        jnoortheen.nix-ide
        # (vscode-utils.buildVscodeMarketplaceExtension {
        #   mktplcRef = {
        #     name = "jupyter";
        #     publisher = "ms-toolsai";
        #     version = "2021.3.593162453";
        #     sha256 = "sha256-giM71SBy7+dv8lBkClVG+m1aY371TsRCc2Qc+RZwUR0=";
        #   };
        #   buildInputs = [ jupyter ];
        #   meta = {
        #     license = lib.licenses.unfree;
        #   };
        # })
        dbaeumer.vscode-eslint
        ms-python.vscode-pylance
        james-yu.latex-workshop
        ms-python.python
        ms-vsliveshare.vsliveshare
      ] ++ vscode-utils.extensionsFromVscodeMarketplace
        [
          {
            name = "org-mode";
            publisher = "vscode-org-mode";
            version = "1.0.0";
            sha256 = "sha256-o9CIjMlYQQVRdtTlOp9BAVjqrfFIhhdvzlyhlcOv5rY=";
          }
          {
            name = "vsc-conceal";
            publisher = "brboer";
            version = "0.2.3";
            sha256 = "sha256-K3cNyUrCrakstnZ846TwJLipJx0WCNFxEyYSOdjaW00=";
          }
          {
            name = "dance";
            publisher = "gregoire";
            version = "0.4.0";
            sha256 = "sha256-xc+nmOw5sxs/+G0NtDBrGqxeD3XCIocHGqxNQbNDX7c=";
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
            name = "vscode-direnv";
            publisher = "rubymaniac";
            version = "0.0.2";
            sha256 = "sha256-TVvjKdKXeExpnyUh+fDPl+eSdlQzh7lt8xSfw1YgtL4=";
          }
          {
            # One Dark Pro
            name = "Material-theme";
            publisher = "zhuangtongfa";
            version = "3.9.12";
            sha256 = "sha256-D1CpuaCZf1kkpc+le2J/prPrOXhqDwtphVk4ejtM8AQ=";
          }
          {
            name = "better-toml";
            publisher = "bungcip";
            version = "0.3.2";
            sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
          }
          {
            name = "vscode-scheme";
            publisher = "sjhuangx";
            version = "0.4.0";
            sha256 = "sha256-BN+C64YQ2hUw5QMiKvC7PHz3II5lEVVy0Shtt6t3ch8=";
          }
          {
            name = "rainbow-brackets";
            publisher = "2gua";
            version = "0.0.6";
            sha256 = "sha256-TVBvF/5KQVvWX1uHwZDlmvwGjOO5/lXbgVzB26U8rNQ=";
          }
        ];
    })
  ];
}
