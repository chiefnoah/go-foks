{
  lib,
  pkgs,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
    pname="foks";
    version="0.1.1";
    src= ./.;
    subPackages = [
        "server/foks-server"
        "client/foks"
    ];
    buildInputs = [
        pkgs.pcsclite
    ];
    nativeBuildInputs = [pkgs.nodejs];
    preBuild = ''
        make srv-assets
        go tool templ generate
        #go generate ./...
    '';

    #src = fetchFromGitHub {
    #    owner="foks-proj";
    #    repo="foks-go";
    #    tag="v${finalAttrs.version}";
    #    hash=lib.fakeHash;
    #};
    vendorHash=lib.fakeHash;
    meta = {
        description="Go implementation of FOKS -- client and server";
        homepage="https://github.com/foks-proj/go-foks";
        license = lib.licenses.mit;
        maintainers = [ lib.maintainers.ngp ];
    };
})
