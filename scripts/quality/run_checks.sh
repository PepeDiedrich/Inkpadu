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

log_step "Gemini AI: dart pub get"
(cd backend/gemini_ai && dart pub get)

log_step "Gemini AI: dart analyze"
(cd backend/gemini_ai && dart analyze)

log_step "Dart Code Metrics: activate"
dart pub global activate dart_code_metrics

log_step "Dart Code Metrics: analyze"
dart pub global run dart_code_metrics:metrics analyze lib test --reporter console

log_step "Dart Code Metrics: check-unused-files"
dart pub global run dart_code_metrics:metrics check-unused-files lib test

log_step "Dart Code Metrics: check-unused-code"
dart pub global run dart_code_metrics:metrics check-unused-code lib test
