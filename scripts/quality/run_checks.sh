#!/usr/bin/env bash
set -euo pipefail

flutter analyze --fatal-infos --fatal-warnings

dart run dart_code_metrics:metrics analyze lib test \
  --fatal-style \
  --fatal-performance \
  --fatal-warnings
