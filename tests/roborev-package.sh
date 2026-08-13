#!/usr/bin/env bash
set -euo pipefail

test_cache=$(mktemp -d "${TMPDIR:-/tmp}/roborev-package-test.XXXXXX")
trap 'rm -rf "$test_cache"' EXIT
export XDG_CACHE_HOME="$test_cache"

system=$(nix eval --raw --impure --expr builtins.currentSystem)
main_program=$(nix eval --raw "path:.#packages.${system}.roborev.meta.mainProgram")

test "$main_program" = "roborev"
