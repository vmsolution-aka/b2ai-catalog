## What the agent (or bundle) does

<!-- One or two sentences. For a change to an existing item: what changes and why. -->

## Tools and extensions

<!-- Every tool in spec.tools and every extension (required/optional), and why it needs each.
     Flag anything with cluster or production access. -->

## Highest risk

<!-- The riskiest capability (risk_level) and what could go wrong if the agent misbehaves
     or its instructions are subverted. What limits the damage? -->

## Checklist

- [ ] `metadata.version` bumped for every changed agent/bundle (and bundle pins updated)
- [ ] No credentials, binaries or symlinks
- [ ] Tags from `tags.yaml`, or a new tag explained above
