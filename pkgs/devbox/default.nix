{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, version
, hashes
}:

let
  platformMap = {
    x86_64-linux = { suffix = "linux_amd64"; ext = "tar.gz"; };
    aarch64-linux = { suffix = "linux_arm64"; ext = "tar.gz"; };
    x86_64-darwin = { suffix = "darwin_amd64"; ext = "tar.gz"; };
    aarch64-darwin = { suffix = "darwin_arm64"; ext = "tar.gz"; };
  };

  platform = platformMap.${stdenv.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  filename = "devbox_${version}_${platform.suffix}.${platform.ext}";

in stdenv.mkDerivation rec {
  pname = "devbox";
  inherit version;

  src = fetchurl {
    url = "https://github.com/namespacelabs/devbox/releases/download/v${version}/${filename}";
    sha256 = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 devbox $out/bin/devbox
    runHook postInstall
  '';

  meta = with lib; {
    description = "Namespace devbox - portable development environments";
    homepage = "https://github.com/namespacelabs/devbox";
    license = licenses.asl20;
    platforms = builtins.attrNames platformMap;
    mainProgram = "devbox";
  };
}
