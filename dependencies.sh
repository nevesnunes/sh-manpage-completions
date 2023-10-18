#!/bin/sh

set -u

if ! command -v "$PYTHON_CMD" > /dev/null 2>&1; then
  echo "'$PYTHON_CMD' not found in \$PATH." >&2
  exit 1
fi
python_version=$("$PYTHON_CMD" --version 2>&1 | grep -oiE '[0-9\.]*')
if ! echo "$python_version" | grep -qE '^3'; then
  echo "Python version must be at least 3 ('$PYTHON_CMD' is '$python_version')." >&2
  exit 1
fi

if [ "$BASH_USE_SELECTOR" -eq 1 ]; then
  if ! command -v "$SELECTOR" > /dev/null 2>&1; then
    echo "'$SELECTOR' not found in \$PATH." >&2
    exit 1
  fi
fi

for i in awk bash flex g++ make sed; do
  if ! command -v "$i" > /dev/null 2>&1; then
    echo "'$i' not found in \$PATH." >&2
    exit 1
  fi
done
