<!-- Contributor guide: CONTRIBUTING.md. Check locally first: scripts/verify.sh -->

## What the agent (or bundle) does

<!-- One or two sentences. For a change to an existing item: what changes and why. -->

## Tools and extensions

<!-- Every tool in spec.tools and every extension (required/optional), and why it needs each.
     Flag anything with cluster or production access. -->

## Highest risk

<!-- The riskiest capability (risk_level) and what could go wrong if the agent misbehaves
     or its instructions are subverted. What limits the damage? -->

## Author

<!-- Official (the catalog owner's team) or Community (you / your organisation)?
     Community submissions list their own authors in metadata.authors, never the owner's team. -->

## Checklist

- [ ] `scripts/verify.sh` passes locally (or the verifier check is green)
- [ ] `metadata.version` bumped for every changed agent/bundle (and bundle pins updated)
- [ ] No credentials, binaries or symlinks; nothing specific to one organisation in the prompt
- [ ] Every tool and extension is needed, and every `risk_level` is honest
- [ ] Tags from `tags.yaml`, or a new tag explained above
- [ ] I license this contribution under Apache-2.0
