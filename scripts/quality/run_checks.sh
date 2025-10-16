#!/bin/bash

# Quality checks script for Flutter project
# This script runs static analysis and code formatting checks

set -e  # Exit on any error

echo "🔍 Running Flutter static analysis..."
flutter analyze

echo ""
echo "✨ Checking code formatting..."
dart format --set-exit-if-changed --line-length 80 .

echo ""
echo "✅ All quality checks passed!"
