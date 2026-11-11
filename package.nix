{
  lib,
  appimageTools,
  fetchurl,
  vulkan-loader,
}:

let
  pname = "orchid";
  version = "0.9.3";

  # PGO (profile-guided optimization) build, the one upstream recommends.
  src = fetchurl {
    url = "https://github.com/MythosOfs/Orchid/releases/download/v${version}/orchid-v${version}-linux-x86_64-pgo.AppImage";
    hash = "sha256-YCrHLIiC7cOgcA9+ZazES0PX07FolhxVCGPE5y3dw+E=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # The AppImage bundles its libraries but uses the host Vulkan loader.
  extraPkgs = pkgs: [ vulkan-loader ];

  # Install desktop entry and icons from the AppImage, if it ships them.
  extraInstallCommands = ''
    for desktop in ${appimageContents}/*.desktop; do
      [ -e "$desktop" ] || continue
      install -Dm444 "$desktop" "$out/share/applications/$(basename "$desktop")"
      substituteInPlace "$out/share/applications/$(basename "$desktop")" \
        --replace-quiet "Exec=AppRun" "Exec=${pname}" \
        --replace-quiet "Exec=orchid" "Exec=${pname}"
    done

    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi
  '';

  meta = {
    description = "Experimental Nintendo Switch 2 emulator (PGO AppImage build)";
    homepage = "https://github.com/MythosOfs/Orchid";
    changelog = "https://github.com/MythosOfs/Orchid/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "orchid";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
