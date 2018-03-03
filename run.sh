#!/usr/bin/env bash

BASH_NO_DESCRIPTIONS="${BASH_NO_DESCRIPTIONS:-0}"

usage() {
  echo "Usage:   $0 man_file"
  echo "Example: $0 /usr/share/man/man1/man.1.gz"
  exit
}

file=$1
[ -f "$1" ] || usage

name=$(echo "$file" | sed 's/.*\/\([^.]*\).*/\1/g')
[ -n "$name" ] || usage

python_cmd=python3
command -v "$python_cmd" > /dev/null 2>&1
if [ $? -eq 1 ]; then
  python_cmd=python
fi

mkdir -p completions/fish
fish_file=completions/fish/"$name".fish
if [ ! -f "$fish_file" ]; then
  echo "Generating fish completion..."

  "$python_cmd" fish-tools/create_manpage_completions.py "$file" -s > "$fish_file"
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
  end_line=$'\n'
  if [[ "$shell" == "zsh" ]]; then
    begin_line="\t\t"
    end_line=" \\\\"$'\n'
  fi
  while IFS= read -r line; do
    completions+="$begin_line$line$end_line"
  done < "$scanner_out_file"
  if [[ "$shell" == "zsh" ]]; then
    completions=${completions::${#completions}-4}
  fi

  template_file=templates/"$shell"
  if [[ "$shell" == "bash" ]] && [[ "$BASH_NO_DESCRIPTIONS" -eq 1 ]]; then
    template_file=templates/"$shell"_no_descriptions
  fi

  cp "$template_file" "$shell_file"
  sed -i "s/COMMAND/$name/g" "$shell_file"
  tmp_file=$(mktemp)
  awk -v r="$completions" \
      "{gsub(/ARGUMENTS/,r)}1" \
      "$shell_file" > \
      "$tmp_file"
  mv "$tmp_file" "$shell_file"
  if [[ "$shell" == "bash" ]] && [[ "$BASH_NO_DESCRIPTIONS" -eq 0 ]]; then
    descriptions=""
    while IFS= read -r line; do
      descriptions+="$begin_line$line$end_line"
    done < "$shell"-converter-descriptions.out
    if [ -n "$descriptions" ]; then
      tmp_file=$(mktemp)
      awk -v r="$descriptions" \
          "{gsub(/DESCRIPTIONS/,r)}1" \
          "$shell_file" > \
          "$tmp_file"
      mv "$tmp_file" "$shell_file"
    fi
  fi

  echo "Completion file available at $shell_file."
}

process_completions bash
process_completions zsh
