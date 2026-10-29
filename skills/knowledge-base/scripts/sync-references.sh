#!/usr/bin/env bash
# Clone or update every repo in repos.yaml into a references folder, each
# at its listed branch. The clones are read-only mirrors: one with local
# changes, or one that can't fast-forward, is left as it is and reported.
# Usage: sync-references.sh <repos.yaml> <references-dir> [<service-to-skip>]
#
# Prints one line per repo, and exits 1 if any repo failed.

set -uo pipefail

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "usage: $0 <repos.yaml> <references-dir> [<service-to-skip>]" >&2
  exit 2
fi
repos_file="$1"
refs="$2"
skip="${3:-}"

if [ ! -f "$repos_file" ]; then
  echo "error: $repos_file not found" >&2
  exit 2
fi
mkdir -p "$refs" || exit 2

# Nobody can answer a password prompt here, so fail instead of waiting.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes}"

# Print name, url and branch for each entry, separated by \037 so empty
# fields survive `read`. This reads only the YAML that repos.yaml uses: a
# list of entries made of "key: value" lines.
entries() {
  awk '
    function clean(v) {
      sub(/[ \t]+#.*$/, "", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      if (v ~ /^".*"$/ || v ~ /^'\''.*'\''$/) v = substr(v, 2, length(v) - 2)
      return v
    }
    function flush() {
      if (open) print name "\037" url "\037" branch
      open = 0; name = ""; url = ""; branch = ""
    }
    { sub(/\r$/, "") }
    /^[ \t]*#/ || /^[ \t]*$/ { next }
    /^[ \t]*-[ \t]/ || /^[ \t]*-$/ { flush(); open = 1; sub(/^[ \t]*-[ \t]*/, "") }
    open && /^[ \t]*name:/   { sub(/^[ \t]*name:/, "");   name = clean($0) }
    open && /^[ \t]*url:/    { sub(/^[ \t]*url:/, "");    url = clean($0) }
    open && /^[ \t]*branch:/ { sub(/^[ \t]*branch:/, ""); branch = clean($0) }
    END { flush() }
  ' "$repos_file"
}

last_line() {
  printf '%s\n' "$1" | tail -n 1
}

status=0
while IFS=$'\037' read -r name url branch; do
  if ! [[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    echo "failed   ${name:-(no name)}: names may only use letters, digits, '.', '_' and '-'"
    status=1; continue
  fi
  if [ -z "$url" ] || [ -z "$branch" ]; then
    echo "failed   $name: needs both a url and a branch"
    status=1; continue
  fi
  if [ "$name" = "$skip" ]; then
    echo "skipped  $name: the project you're in"
    continue
  fi

  dir="$refs/$name"
  if [ ! -e "$dir" ]; then
    if out="$(git clone -q --single-branch --branch "$branch" "$url" "$dir" 2>&1)"; then
      echo "cloned   $name ($branch)"
    else
      echo "failed   $name: $(last_line "$out")"
      status=1
    fi
    continue
  fi

  top="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"
  if [ ! -d "$dir" ] || [ "$top" != "$(cd "$dir" && pwd -P)" ]; then
    echo "failed   $name: $dir is there but isn't a git repo"
    status=1; continue
  fi
  origin="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
  if [ "$origin" != "$url" ]; then
    echo "failed   $name: it was cloned from ${origin:-somewhere else}, not $url; delete $dir to clone it again"
    status=1; continue
  fi
  if [ -n "$(git -C "$dir" status --porcelain --untracked-files=no)" ]; then
    echo "failed   $name: has local changes, so it was left as it is"
    status=1; continue
  fi
  if ! out="$(git -C "$dir" fetch -q origin "+refs/heads/$branch:refs/remotes/origin/$branch" 2>&1)"; then
    echo "failed   $name: $(last_line "$out")"
    status=1; continue
  fi

  before="$(git -C "$dir" rev-parse HEAD)"
  if [ "$(git -C "$dir" symbolic-ref -q --short HEAD)" != "$branch" ]; then
    # repos.yaml now names a different branch.
    if ! out="$(git -C "$dir" checkout -q -B "$branch" "origin/$branch" 2>&1)"; then
      echo "failed   $name: $(last_line "$out")"
      status=1; continue
    fi
  elif ! git -C "$dir" merge -q --ff-only "origin/$branch" >/dev/null 2>&1; then
    echo "failed   $name: can't fast-forward to origin/$branch, so it was left as it is"
    status=1; continue
  fi
  after="$(git -C "$dir" rev-parse HEAD)"
  if [ "$before" = "$after" ]; then
    echo "current  $name ($branch)"
  else
    echo "updated  $name ($branch) $(git -C "$dir" rev-parse --short "$before")..$(git -C "$dir" rev-parse --short "$after")"
  fi
done < <(entries)

exit "$status"
