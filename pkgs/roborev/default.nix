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

  filename = "roborev_${version}_${suffix}.tar.gz";

in stdenv.mkDerivation rec {
  pname = "roborev";
  inherit version;

  src = fetchurl {
    url = "https://github.com/kenn-io/roborev/releases/download/v${version}/${filename}";
    sha256 = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 roborev $out/bin/roborev
    runHook postInstall
  '';

  meta = with lib; {
    description = "Continuous code review for AI coding agents";
    homepage = "https://github.com/kenn-io/roborev";
    license = licenses.mit;
    platforms = builtins.attrNames platformMap;
    mainProgram = "roborev";
  };
}
