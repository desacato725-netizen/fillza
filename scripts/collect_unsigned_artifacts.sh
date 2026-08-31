#!/bin/sh

set -eu



OUT_DIR=${1:-artifacts}

mkdir -p "$OUT_DIR"



DYLIB_PATH=$(find .theos packages -type f -name 'FilzaApplySandboxExt.dylib' -print -quit 2>/dev/null || true)

DEB_PATH=$(find .theos packages -type f -name '*.deb' -print -quit 2>/dev/null || true)



if [ -z "$DYLIB_PATH" ]; then

  echo "FilzaApplySandboxExt.dylib was not produced" >&2
  
  exit 1
  
fi

if [ -z "$DEB_PATH" ]; then

  echo "Theos did not produce a .deb package" >&2
  
  exit 1
  
fi



cp "$DYLIB_PATH" "$OUT_DIR/"

cp "$DEB_PATH" "$OUT_DIR/"

cp Makefile "$OUT_DIR/Makefile"

cp LoginViewController.m FilzaAuthGate.m FilzaAuthIntegration.m "$OUT_DIR/"



if [ -f FilzaApplySandboxExt.plist ]; then

  cp FilzaApplySandboxExt.plist "$OUT_DIR/"
  
fi



shasum -a 256 "$OUT_DIR"/* > "$OUT_DIR/SHA256SUMS"

printf '%s\n' "Unsigned artifacts collected in $OUT_DIR"






