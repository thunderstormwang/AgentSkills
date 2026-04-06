#!/usr/bin/env bash
set -euo pipefail

MSG_FILE="$1"
if [[ -z "${MSG_FILE:-}" ]]; then
  echo "Usage: $0 <commit-msg-file>" >&2
  exit 2
fi

# Read first line of commit message
read -r firstline < "$MSG_FILE"

# Conventional Commits basic pattern
# type(scope?): subject
pattern='^(feat|fix|docs|style|refactor|perf|test|chore)(\([a-zA-Z0-9_\- ]+\))?: [^ ].+'

if [[ "$firstline" =~ $pattern ]]; then
  exit 0
else
  cat <<'EOF' >&2
Invalid commit message format.
Expected Conventional Commits like:
  feat(scope): short description
See skills/git-commit-formatter-superpowers/templates/commit-templates.md for examples.
EOF
  exit 1
fi
