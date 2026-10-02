# b2ai catalog

The public catalog of agents for the [b2ai](https://github.com/vmsolution-aka) platform
(ADR-154). Each agent is a reviewed manifest plus its instructions; bundles group agents
into teams with reporting lines.

```
agents/<id>/agent.yaml    kind: Agent — tools, extensions, capabilities (with risk), model
agents/<id>/prompt.md     the agent's instructions
bundles/<id>/bundle.yaml  kind: Bundle — agents pinned to exact versions + relations
tags.yaml                 tag vocabulary (a tag outside it is flagged for review)
```

## How a change gets in

1. **Pull request.** Every change, from anyone, is a PR against `main`.
2. **Verifier (required check).** CI runs the platform's own validator — the
   `b2ai-catalog-verifier` image built from the platform, pinned by digest — on the PR:
   schema, tools only from the platform's tools catalog, required extensions exist,
   bundle references resolve without cycles, a version bump for every changed agent or
   bundle, no binaries, no credentials, prompt present and within the size cap, tag
   format and count (a new tag is a warning for the reviewer).
3. **Owner review (required).** CODEOWNERS: nothing merges without the owner's approval.
4. **Release.** Installations read **releases**, never `main`. A `vX.Y.Z` tag publishes
   `catalog.json` (every agent and bundle with its version and content hash) on the
   GitHub release. A merge reaches nobody until a release is cut, and an installed agent
   is a pinned snapshot.

Contributor guide: [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[Apache-2.0](LICENSE).
