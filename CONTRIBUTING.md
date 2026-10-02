# Contributing

The full contributor guide is not written yet; it is tracked in
[vmsolution-aka/b2ai-platform#1200](https://github.com/vmsolution-aka/b2ai-platform/issues/1200).

Until then, in short:

- Open a pull request; fill in the template (what the agent does, which tools, the
  highest risk).
- Change an existing agent or bundle → bump its `metadata.version` (and the version pin
  in every bundle that includes it). The verifier fails a changed item whose version
  did not go up.
- Use tags from `tags.yaml` where one fits; a new tag is accepted deliberately in review.
- Never put credentials, binaries or symlinks in the repository.
- The verifier must be green and the owner must approve before anything merges.
