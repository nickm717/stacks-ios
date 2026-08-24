#!/usr/bin/env bash
# Applies swift-format in place across the app's source folders.
set -euo pipefail
cd "$(dirname "$0")/.."

swift format --in-place --recursive --configuration .swift-format App Features Models Services
