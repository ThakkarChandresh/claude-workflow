#!/usr/bin/env bash
# Link this knowledge-base repo to a remote and push it there.
# Usage: ./link-remote.sh <remote-url>
#
# Create the remote repo empty first: no README, license or .gitignore.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <remote-url>" >&2
  exit 2
fi
url="$1"
cd "$(dirname "$0")"

# Only act on the repo this script sits at the top of.
if [ "$(git rev-parse --show-toplevel 2>/dev/null)" != "$(pwd -P)" ]; then
  echo "error: $(pwd -P) is not the top of a git repo" >&2
  exit 1
fi

if existing="$(git remote get-url origin 2>/dev/null)"; then
  echo "error: origin is already set to $existing" >&2
  exit 1
fi

branch="$(git symbolic-ref --short HEAD)"
git remote add origin "$url"
if ! git push -u origin "$branch"; then
  # Drop origin again so the script can simply be rerun.
  git remote remove origin
  echo "error: push failed, so origin was removed again." >&2
  echo "Check the URL and your access, and that the remote repo is empty." >&2
  exit 1
fi
echo "Linked to $url and pushed $branch."
