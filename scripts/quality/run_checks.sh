#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_DIR"

log_step() {
  local message="$1"
  printf '\n\033[1;34m==> %s\033[0m\n' "$message"
}

log_step "Flutter analyze"
flutter analyze

log_step "Dart Code Metrics: analyze"
dart run dart_code_metrics:metrics analyze lib test --reporter console

log_step "Dart Code Metrics: check-unused-files"
dart run dart_code_metrics:metrics check-unused-files lib test

log_step "Dart Code Metrics: check-unused-code"
dart run dart_code_metrics:metrics check-unused-code lib test
