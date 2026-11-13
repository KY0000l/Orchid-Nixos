# Provides both emulators as PGO AppImage wrappers:
#   (callPackage ./package.nix { }).orchid
#   (callPackage ./package.nix { }).lichii
{
  lib,
  appimageTools,
  fetchurl,
}:

let
  # Libraries the AppImages expect the host to provide.
  # If another "cannot open shared object file" error shows up,
  # find the owner with `nix-locate <file>` and add it here.
  extraLibs =
    pkgs: with pkgs; [
      vulkan-loader
      libgpg-error
      libgcrypt
      libselinux
      libdrm
      libGL
      libxkbcommon
      wayland
      alsa-lib
      libpulseaudio
      pipewire
      dbus
      fontconfig
      freetype
      harfbuzz
      glib
      zlib
      openssl
      systemdLibs
      stdenv.cc.cc.lib
    ];

  mkEmulator =
    {
      pname,
      version,
      src,
      description,
      homepage,
      changelog,
    }:
    let
      appimageContents = appimageTools.extract { inherit pname version src; };
    in
    appimageTools.wrapType2 {
      inherit pname version src;

      extraPkgs = extraLibs;

      # Install desktop entry and icons from the AppImage, if it ships them.
      extraInstallCommands = ''
        for desktop in ${appimageContents}/*.desktop; do
          [ -e "$desktop" ] || continue
          install -Dm444 "$desktop" "$out/share/applications/$(basename "$desktop")"
          substituteInPlace "$out/share/applications/$(basename "$desktop")" \
            --replace-quiet "Exec=AppRun" "Exec=${pname}"
        done

        if [ -d ${appimageContents}/usr/share/icons ]; then
          mkdir -p $out/share
          cp -r ${appimageContents}/usr/share/icons $out/share/
        fi
      '';

      meta = {
        inherit description homepage changelog;
        license = lib.licenses.gpl3Plus;
        mainProgram = pname;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      };
    };
in
{
  orchid =
    let
      version = "0.9.3";
    in
    mkEmulator {
      pname = "orchid";
      inherit version;
      src = fetchurl {
        url = "https://github.com/MythosOfs/Orchid/releases/download/v${version}/orchid-v${version}-linux-x86_64-pgo.AppImage";
        hash = "sha256-YCrHLIiC7cOgcA9+ZazES0PX07FolhxVCGPE5y3dw+E=";
      };
      description = "Experimental Nintendo Switch 2 emulator (PGO AppImage build)";
      homepage = "https://github.com/MythosOfs/Orchid";
      changelog = "https://github.com/MythosOfs/Orchid/releases/tag/v${version}";
    };

  lichii =
    let
      build = "177";
    in
    mkEmulator {
      pname = "lichii";
      version = build;
      src = fetchurl {
        url = "https://github.com/zortos293/Lichii/releases/download/build-${build}/lichii-linux-x86_64-pgo.AppImage";
        hash = "sha256-zBoJ5Gw+hg6vEJE0BAoUSK4I/b1RtYZuE+qfQrDZEzI=";
      };
      description = "Experimental Nintendo Switch 2 emulator, Lichii (PGO AppImage build)";
      homepage = "https://github.com/zortos293/Lichii";
      changelog = "https://github.com/zortos293/Lichii/releases/tag/build-${build}";
    };

  cheezyemu =
    let
      build = "c1eecfd";
    in
    mkEmulator {
      pname = "cheezyemu";
      version = build;
      src = fetchurl {
        url = "https://github.com/CheezerWheezer/CheezyEmu/releases/download/test-${build}/cheezyemu-linux-x86_64-pgo.AppImage";
        hash = "sha256-4S+Y+8HDTdPHncYFkCjVHLi+Z/zQxVxVQCtLWuCJoPg=";
      };
      description = "Experimental Nintendo Switch 2 emulator, CheezyEmu (PGO AppImage build)";
      homepage = "https://github.com/CheezerWheezer/CheezyEmu";
      changelog = "https://github.com/zortos293/Lichii/releases/tag/test-${build}";
    };
}
