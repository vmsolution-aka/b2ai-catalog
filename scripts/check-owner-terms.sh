#!/usr/bin/env bash
# Fails when catalog content names the platform owner's own organisation or
# infrastructure (#1193). Catalog agents must be generic: the installing
# organisation supplies its repositories, hosts and clusters at run time.
#
# Scope: what installs into a customer's account — agents/, bundles/, extensions/, tags.yaml.
# Temporary: to be replaced by a verifier L1 rule in b2ai-platform.
set -euo pipefail
cd "$(dirname "$0")/.."

# Case-insensitive extended regexes, one per line.
terms=(
  'b2ai-platform'
  'vmsolution'
  'karpiu'
  'argo-gitops'
  'pve-dev'
  'proxmox'
  '(^|[^a-z0-9])pve([^a-z0-9]|$)'
  '(^|[^a-z0-9])k3s([^a-z0-9]|$)'
  'tail37b73e'
  'ccweb'
)

pattern=$(IFS='|'; echo "${terms[*]}")
targets=(agents bundles extensions tags.yaml)

# The one exemption: the value of `spec.runtime.image` of an extension (4-space indent, as the
# manifests are written), when it is exactly the official platform image
# ghcr.io/vmsolution-aka/b2ai-<service>@sha256:<digest> and the service part has no owner term.
# Any other line, in any other file, is checked. The verifier applies the same rule on the parsed
# YAML; this script is the cheap second check.
image_re='^extensions/[^:]+/extension\.yaml:[0-9]+:    image: ghcr\.io/vmsolution-aka/b2ai-([a-z0-9]+(-[a-z0-9]+)*)@sha256:[0-9a-f]{64}$'

hits=""
while IFS= read -r line; do
  if [[ $line =~ $image_re ]] && ! grep -qiE "$pattern" <<<"b2ai-${BASH_REMATCH[1]}"; then
    continue
  fi
  hits+="$line"$'\n'
done < <(grep -rniE "$pattern" -- "${targets[@]}" 2>/dev/null || true)

if [ -n "$hits" ]; then
  echo "Owner-specific terms found (catalog content must be generic):"
  printf '%s' "$hits"
  exit 1
fi
echo "owner-terms: 0 hits in ${targets[*]}"
