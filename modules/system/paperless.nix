{
  flake.nixosModules.paperless =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      unoconverter = pkgs.stdenv.mkDerivation {
        pname = "unoconverter";
        version = "0.4.0";
        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/gotenberg/unoconverter/v0.4.0/unoconv";
          hash = "sha256-RqVGO8iAYkfuIjvk4pVORPCWGq28SWDliaOpJeoNLSs=";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        dontUnpack = true;
        installPhase = ''
          install -Dm755 $src $out/bin/unoconverter
          sed -i "1s|.*|#!${pkgs.libreoffice-unwrapped.python.interpreter}|" $out/bin/unoconverter
          substituteInPlace $out/bin/unoconverter \
            --replace-fail "from distutils.version import LooseVersion" "" \
            --replace-fail "or LooseVersion(product.ooSetupVersion) <= LooseVersion('3.3')" "or False"
          wrapProgram $out/bin/unoconverter \
            --set-default UNO_PATH "${pkgs.libreoffice-unwrapped}/lib/libreoffice/program/"
        '';
        meta.mainProgram = "unoconverter";
      };
    in
    {
      services.paperless = {
        enable = true;
        configureTika = true;
        address = "0.0.0.0";
        passwordFile = config.sops.secrets.paperless-password.path;
        settings = {
          PAPERLESS_OCR_LANGUAGE = "ita+eng";
          PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
          PAPERLESS_STATIC_URL = "/paperless/static/";
          PAPERLESS_CSRF_TRUSTED_ORIGINS = [
            "https://mactoncino.taila7373f.ts.net"
          ]
          ++ lib.optionals config.mactoflake.proxy.enable [
            "https://paperless.${config.mactoflake.proxy.domain}"
          ];
          PAPERLESS_CONSUMER_DELETE_DUPLICATES = true;
        };
      };

      services.gotenberg = {
        port = 3199;
        package = pkgs.gotenberg.override { unoconv = unoconverter; };
      };

      sops.secrets.paperless-password.sopsFile = ../../secrets/paperless.yaml;
    };
}
