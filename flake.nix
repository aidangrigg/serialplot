{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/25.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          qwt = (pkgs.qt6.callPackage "${nixpkgs}/pkgs/development/libraries/qwt/default.nix" { }).overrideAttrs (prev: final: {
            preFixup = ''
             mkdir -p "$out/lib/qt-6/plugins"
             mv "$out/plugins/designer" "$out/lib/qt-6/plugins"
             rmdir "$out/plugins"
           '';
          });
        in {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              qt6.full
              qwt
              cmake
            ];
          };

          packages.default = pkgs.stdenv.mkDerivation {
            pname = "serialplot";
            version = "0.13";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              cmake
              qt6.wrapQtAppsHook
            ];

            cmakeFlags = ["-DBUILD_QWT=false"];

            buildInputs = with pkgs; [
              qt6.full
              qwt
            ];
          };
        });
}
