#!/bin/sh
set -eu

OUT_DIR=${1:-artifacts}
mkdir -p "$OUT_DIR"

find .theos -type f \( -name 'FilzaApplySandboxExt.dylib' -o -name '*.deb' \) -exec cp {} "$OUT_DIR"/ \;
cp Makefile "$OUT_DIR/Makefile"
cp LoginViewController.m FilzaAuthGate.m FilzaAuthIntegration.m "$OUT_DIR/"

if ! find "$OUT_DIR" -type f -print -quit | grep -q .; then
  echo "No unsigned build artifacts found" >&2
  exit 1
fi

shasum -a 256 "$OUT_DIR"/* > "$OUT_DIR/SHA256SUMS"
printf '%s\n' "Unsigned artifacts collected in $OUT_DIR"
