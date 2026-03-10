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

  filename = "nsc_${version}_${platform.suffix}.${platform.ext}";

in stdenv.mkDerivation rec {
  pname = "nsc";
  inherit version;

  src = fetchurl {
    url = "https://github.com/namespacelabs/foundation/releases/download/v${version}/${filename}";
    sha256 = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 nsc $out/bin/nsc
    install -Dm755 docker-credential-nsc $out/bin/docker-credential-nsc
    install -Dm755 bazel-credential-nsc $out/bin/bazel-credential-nsc
    runHook postInstall
  '';

  meta = with lib; {
    description = "Namespace CLI - command line interface for Namespace";
    homepage = "https://github.com/namespacelabs/foundation";
    license = licenses.asl20;
    platforms = builtins.attrNames platformMap;
    mainProgram = "nsc";
  };
}
