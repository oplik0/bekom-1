{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs { inherit system; }) ;
          dockerImage = pkgs.dockerTools.streamLayeredImage {
            name = "mysql-hardened";
            tag = "latest";
            contents = [ (pkgs.buildEnv {
              name = "mysql";
              pathsToLink = ["/bin"];
              paths = with pkgs; [
                pkgsStatic.busybox
                mysql84
              ];
              }) ];
            includeStorePaths = false;
            enableFakechroot = true;
            config = {
              Cmd = pkgs.writeScript "docker-entrypoint" ''
                mysqld
              '';
              WorkingDir = "/data";
              Volumes = { "/data" = { }; };
            };
          };
        in
        with pkgs;
        {
          packages =
            {
              inherit dockerImage;
            };
        }
      );
}