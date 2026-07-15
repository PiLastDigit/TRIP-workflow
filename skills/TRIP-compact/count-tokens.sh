#!/usr/bin/env bash
# Estimate Claude token count for a given file.
# Uses character-category weighting calibrated against Claude's tokenizer.
#
# How it works:
#   LLM tokenizers treat different character types differently:
#   - Letters form subwords (~4.8 chars per token — common words are single tokens)
#   - Digits group in small runs (~2.5 chars per token)
#   - Punctuation/special chars (~2.8 chars per token — markdown merges: ##, **, ---, |, ```, ://)
#   - Spaces are merged with adjacent tokens (~6 chars per token)
#   - Newlines partially merge with surrounding tokens (~0.75 tokens each)
#
# Calibrated against Claude's tokenizer on markdown/documentation.
# Accuracy: ±5% for markdown/documentation.
#
# Usage:
#   ./count-tokens.sh <file> [file2 ...]
#   ./count-tokens.sh docs/ARCHI.md docs/ARCHI-compact.md

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file> [file2 ...]"
  exit 1
fi

for file in "$@"; do
  if [ ! -f "$file" ]; then
    echo "Error: '$file' not found"
    continue
  fi

  lines=$(wc -l < "$file")
  words=$(wc -w < "$file")
  chars=$(wc -m < "$file")

  tokens=$(awk '
  {
    len = length($0)
    for (i = 1; i <= len; i++)
    {
      c = substr($0, i, 1)
      if      (c ~ /[a-zA-Z]/) letters++
      else if (c ~ /[0-9]/)    digits++
      else if (c ~ /[ \t]/)    spaces++
      else                      punct++
    }
    newlines++
  }
  END {
    t = letters/4.8 + digits/2.5 + punct/2.8 + spaces/6.0 + newlines*0.75
    printf "%d\n", t + 0.5
  }' "$file")

  printf "%-40s  %5d lines  %6d words  %7d chars  ~%6d tokens\n" \
    "$file" "$lines" "$words" "$chars" "$tokens"
done
