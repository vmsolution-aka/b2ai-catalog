#!/usr/bin/env bash
# Fails when catalog content names the platform owner's own organisation or
# infrastructure (#1193). Catalog agents must be generic: the installing
# organisation supplies its repositories, hosts and clusters at run time.
#
# Scope: what installs into a customer's account — agents/, bundles/, extensions/, tags.yaml.
# The one exemption: a digest-pinned `image: ghcr.io/<org>/b2ai-<service>@sha256:...` line of an
# extension (the platform's own published image); the verifier applies the same rule.
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

image_line='^[^:]*:[0-9]+:[[:space:]]*image:[[:space:]]*ghcr\.io/[a-z0-9-]+/b2ai-[a-z0-9-]+@sha256:[0-9a-f]{64}[[:space:]]*$'
if hits=$(grep -rniE "$pattern" -- "${targets[@]}" 2>/dev/null | grep -vE "$image_line"); then
  echo "Owner-specific terms found (catalog content must be generic):"
  echo "$hits"
  exit 1
fi
echo "owner-terms: 0 hits in ${targets[*]}"
