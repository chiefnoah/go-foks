{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };
    outputs = {
        self,
        nixpkgs,
        flake-utils
    }: let
        nixosModule = {
            config,
            lib,
            pkgs,
            ...
        }: {
            options.services.foks-server = {
                enable = lib.mkEnableOption "The FOKS federated server.";

                port = lib.mkOption {
                    type = lib.types.port;
                    default = 8080;
                    description = "The port to listen on";
                };
            };
            config = lib.mkIf config.services.foks-server.enable {
                systemd.services.foks-server = {
                    description = "The FOKS federated server.";
                    wantedBy = ["multi-user.target"];
                    after = ["network.target"];
                    serviceConfig = {
                        ExecStart = "${self.packages.${pkgs.system}.default}/bin/foks-server";
                        Restart = "always";
                        Type = "simple";
                        DynamicUser = "yes";
                    };
                };

            };
        };
        in
            (flake-utils.lib.eachDefaultSystem (system: let
                pkgs = nixpkgs.legacyPackages.${system};
            in {
                packages.default = (pkgs.callPackage ./package.nix {});
                devShell = with pkgs; mkShell {
                    buildInputs = [ pkg-config gopls go gotools nil nixfmt-tree nodejs ];
                };
                apps.default = {
                    type = "app";
                    program = "${self.packages.${system}.default}/bin/go-foks";
                };
            }))
            // {
                nixosModules.default = nixosModule;
            };

}
