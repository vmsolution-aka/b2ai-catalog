#!/usr/bin/env bash
# Run the catalog verifier locally — the same image, pinned by digest, that the
# `verifier-l1` check runs on a pull request (.github/workflows/verifier.yml).
#
#   scripts/verify.sh [BASE_REF]    # BASE_REF defaults to origin/main
#
# The working tree is checked against BASE_REF for the version bump rule. Needs
# docker and git. Exit code: 0 valid (warnings allowed), 1 invalid, 2 usage.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
base_ref=${1:-origin/main}
image=$(sed -n 's/^ *VERIFIER_IMAGE: *//p' "$root/.github/workflows/verifier.yml" | head -1)
if [ -z "$image" ]; then
  echo "error: VERIFIER_IMAGE not found in .github/workflows/verifier.yml" >&2
  exit 2
fi

base=$(mktemp -d)
cleanup() { git -C "$root" worktree remove --force "$base" >/dev/null 2>&1 || rm -rf "$base"; }
trap cleanup EXIT
git -C "$root" fetch --quiet origin || true
git -C "$root" worktree add --quiet --detach "$base" "$base_ref"

echo "verifier: $image"
echo "base:     $base_ref ($(git -C "$base" rev-parse --short HEAD))"
docker run --rm --network none --read-only --cap-drop ALL --security-opt no-new-privileges \
  --user "$(id -u):$(id -g)" \
  -v "$root:/catalog:ro" -v "$base:/base:ro" \
  "$image" validate /catalog --base /base
