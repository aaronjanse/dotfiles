{ neo4j }:
neo4j.overrideAttrs (attrs: {
    installPhase = attrs.installPhase + ''
        patchShebangs $out/share/neo4j/bin/neo4j-admin
        # user will be asked to change password on first login
        $out/bin/neo4j-admin set-initial-password neo4j
    '';
})