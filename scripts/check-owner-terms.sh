#!/usr/bin/env bash
# Fails when catalog content names the platform owner's own organisation or
# infrastructure (#1193). Catalog agents must be generic: the installing
# organisation supplies its repositories, hosts and clusters at run time.
#
# Scope: what installs into a customer's account — agents/, bundles/, tags.yaml.
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
targets=(agents bundles tags.yaml)

if hits=$(grep -rniE "$pattern" -- "${targets[@]}" 2>/dev/null); then
  echo "Owner-specific terms found (catalog content must be generic):"
  echo "$hits"
  exit 1
fi
echo "owner-terms: 0 hits in ${targets[*]}"
