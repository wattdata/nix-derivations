{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, version
, hashes
}:

let
  platformMap = {
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
    x86_64-darwin = "darwin_amd64";
    aarch64-darwin = "darwin_arm64";
  };

  suffix = platformMap.${stdenv.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

in stdenv.mkDerivation rec {
  pname = "seaweedfs";
  inherit version;

  src = fetchurl {
    url = "https://github.com/seaweedfs/seaweedfs/releases/download/${version}/${suffix}.tar.gz";
    sha256 = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 weed $out/bin/weed
    runHook postInstall
  '';

  meta = with lib; {
    description = "SeaweedFS - simple and highly scalable distributed file system with S3 API";
    homepage = "https://github.com/seaweedfs/seaweedfs";
    license = licenses.asl20;
    platforms = builtins.attrNames platformMap;
    mainProgram = "weed";
  };
}
