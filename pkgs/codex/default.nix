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

  # The package tarball, unlike the bare codex one, carries codex-package.json,
  # codex-code-mode-host, and codex-resources. Codex canonicalizes its own path
  # and reads the manifest from the parent of bin/, and its background server
  # refuses to start without it, so the layout has to land in $out unchanged.
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-${target}.tar.gz";
    sha256 = hashes.${stdenvNoCC.hostPlatform.system};
  };

  # No leading directory in the tarball, so give it one to keep build files
  # out of $out.
  unpackPhase = ''
    runHook preUnpack
    mkdir package
    tar -xzf $src -C package
    runHook postUnpack
  '';
  sourceRoot = "package";

  # The Linux builds are static-pie musl, so there is nothing to patch.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R . $out/
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
