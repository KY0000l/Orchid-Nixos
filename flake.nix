{
  description = "Switch 2 emulators (Orchid, Lichii) packaged from their PGO AppImages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      emulators = pkgs.callPackage ./package.nix { };
    in
    {
      packages.${system} = {
        inherit (emulators) orchid lichii;
        default = emulators.orchid;
      };

      apps.${system} = {
        orchid = {
          type = "app";
          program = "${emulators.orchid}/bin/orchid";
        };
        lichii = {
          type = "app";
          program = "${emulators.lichii}/bin/lichii";
        };
        default = self.apps.${system}.orchid;
      };

      # Adds pkgs.orchid and pkgs.lichii
      overlays.default = final: _prev: {
        inherit (final.callPackage ./package.nix { }) orchid lichii;
      };
    };
}
