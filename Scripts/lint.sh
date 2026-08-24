#!/usr/bin/env bash
# Lints the app without modifying files. Run before pushing.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v swiftlint &> /dev/null; then
  echo "swiftlint not found. Install with: brew install swiftlint" >&2
  exit 1
fi

echo "== SwiftLint =="
swiftlint lint --strict

echo "== swift-format (check only) =="
swift format lint --recursive --configuration .swift-format App Features Models Services
