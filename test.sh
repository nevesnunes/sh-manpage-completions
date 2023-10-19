#!/bin/sh

set -u

rm -f completions/*/_foo completions/fish/foo.fish

./run.sh ./test/in/foo.1

for i in bash zsh; do
  if ! diff --color=auto -uw ./test/out/"$i"/_foo ./completions/"$i"/_foo; then
    echo "Test FAILED: '$i' completion mismatched expected output." >&2
    exit 1
  fi
done

echo "Test PASSED." >&2
