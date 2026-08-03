{ lib
, stdenvNoCC
, version
, hashes
, fetchurl
}:

let
  platformMap = {
    x86_64-linux = "x86_64-unknown-linux-musl";
    aarch64-linux = "aarch64-unknown-linux-musl";
    x86_64-darwin = "x86_64-apple-darwin";
    aarch64-darwin = "aarch64-apple-darwin";
  };

  target = platformMap.${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");

in stdenvNoCC.mkDerivation rec {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${target}.tar.gz";
    sha256 = hashes.${stdenvNoCC.hostPlatform.system};
  };

  # Tarball holds a single binary named after the target triple, no leading directory.
  sourceRoot = ".";

  # The Linux builds are static-pie musl, so there is nothing to patch.
  installPhase = ''
    runHook preInstall
    install -Dm755 codex-${target} $out/bin/codex
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI - coding agent that runs in the terminal";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = builtins.attrNames platformMap;
    mainProgram = "codex";
  };
}
