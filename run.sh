#!/bin/sh

set -u

BASH_NO_DESCRIPTIONS="${BASH_NO_DESCRIPTIONS:-0}"
BASH_USE_SELECTOR="${BASH_USE_SELECTOR:-0}"
SELECTOR="${SELECTOR-fzf}"
SELECTOR_QUERY="${SELECTOR_QUERY-'-q'}"
export BASH_NO_DESCRIPTIONS
export BASH_USE_SELECTOR
export SELECTOR
export SELECTOR_QUERY

PYTHON_CMD=python3
if ! command -v "$PYTHON_CMD" > /dev/null 2>&1; then
  PYTHON_CMD=python
fi
export PYTHON_CMD

./dependencies.sh || exit 1

usage() {
  echo "Usage:   $0 man_file"
  echo "Example: $0 /usr/share/man/man1/man.1.gz"
  exit
}

file=$1
[ -f "$1" ] || usage

name=$(echo "$file" | sed 's/.*\/\([^.]*\).*/\1/g')
[ -n "$name" ] || usage

# change working directory to the repository's root where this file should be
cd "$(dirname "$0")" || exit 1

mkdir -p completions/fish
fish_file=completions/fish/"$name".fish
if [ ! -f "$fish_file" ]; then
  echo "Generating fish completion..."

  "$PYTHON_CMD" fish-tools/create_manpage_completions.py "$file" -s > "$fish_file"
fi

echo "Building scanner..."

make || exit 1

echo "Running scanner..."

./scanner < "$fish_file" > /dev/null

process_completions() {
  shell="$1"
  mkdir -p completions/"$shell"
  shell_file=completions/"$shell"/_"$name"
  scanner_out_file="$shell"-converter.out

  echo "Generating $shell completion..."

  completions=""
  begin_line=""
  end_line='\n'
  if echo "$shell" | grep "zsh" > /dev/null; then
    begin_line='\t\t'
    end_line=' \\\n'
  fi
  while IFS= read -r line; do
    completions=$completions$begin_line$line$end_line
  done < "$scanner_out_file"
  if { echo "$shell" | grep "zsh" > /dev/null; } && [ "${#completions}" -ge 4 ]; then
    completions=$(printf '%s\n' "$completions" | head -c -4)
  fi

  template_file=templates/"$shell"
  if echo "$shell" | grep "bash" > /dev/null; then
    if [ "$BASH_NO_DESCRIPTIONS" -eq 1 ]; then
      template_file=templates/"$shell"_no_descriptions
    elif [ "$BASH_USE_SELECTOR" -eq 1 ]; then
      template_file=templates/"$shell"_use_selector
    fi
  fi

  cp "$template_file" "$shell_file"
  sed -i "s/COMMAND/$name/g" "$shell_file"
  tmp_file=$(mktemp)
  awk -v r="$completions" \
    "{gsub(/ARGUMENTS/,r)}1" \
    "$shell_file" > \
    "$tmp_file"
  mv "$tmp_file" "$shell_file"
  if { echo "$shell" | grep "bash" > /dev/null; } && [ "$BASH_NO_DESCRIPTIONS" -eq 0 ]; then
    descriptions=""
    while IFS= read -r line; do
      descriptions=$descriptions$begin_line$line$end_line
    done < "$shell"-converter-descriptions.out
    if [ -n "$descriptions" ]; then
      tmp_file=$(mktemp)
      awk -v r="$descriptions" \
        "{gsub(/DESCRIPTIONS/,r)}1" \
        "$shell_file" > \
        "$tmp_file"
      mv "$tmp_file" "$shell_file"
    fi
    if [ "$BASH_USE_SELECTOR" -eq 1 ]; then
      if [ -n "$SELECTOR_QUERY" ]; then
        sed -i "s/SELECTOR/$SELECTOR $SELECTOR_QUERY \"\$cur\"/g" "$shell_file"
      else
        sed -i "s/SELECTOR/$SELECTOR/g" "$shell_file"
      fi
    fi
  fi

  echo "Completion file available at $shell_file."
}

process_completions bash
process_completions zsh
