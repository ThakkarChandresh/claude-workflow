#!/usr/bin/env bash
# Create a local knowledge-base repo from the template and commit it.
# Usage: init-knowledge-base.sh <path>
#
# Link it to a remote later with link-remote.sh inside the new repo.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <path>" >&2
  exit 2
fi
kb="$1"
parent="$(dirname "$kb")"
template="$(cd "$(dirname "$0")/../template" && pwd)"

if [ -e "$kb" ]; then
  echo "error: $kb already exists" >&2
  exit 1
fi
if [ ! -d "$parent" ]; then
  echo "error: $parent does not exist" >&2
  exit 1
fi

# Check that git can name the author now, instead of failing after git init.
# A new repo has no config of its own, so check from the folder it goes in.
if ! (cd "$parent" && git var GIT_AUTHOR_IDENT && git var GIT_COMMITTER_IDENT) >/dev/null 2>&1; then
  echo "error: git has no name and email to commit with. Set them, then run this again:" >&2
  echo '  git config --global user.name "Your Name"' >&2
  echo '  git config --global user.email "you@example.com"' >&2
  exit 1
fi

git init -q -b main "$kb"
cp -R "$template/." "$kb/"
git -C "$kb" add -A
git -C "$kb" commit -q -m "Initialize knowledge base"
echo "Created $kb on branch main. No remote yet: link one with $kb/link-remote.sh <url>"
