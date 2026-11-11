{
  description = "Orchid, an experimental Nintendo Switch 2 emulator (PGO AppImage)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        orchid = pkgs.callPackage ./package.nix { };
        default = self.packages.${system}.orchid;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.orchid}/bin/orchid";
      };

      overlays.default = final: _prev: {
        orchid = final.callPackage ./package.nix { };
      };
    };
}
