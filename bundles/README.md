# Bundles

A bundle is a set of agents plus their relations: `bundles/<id>/bundle.yaml`
(`kind: Bundle`). Members are pinned to exact agent versions in this catalog, so
changing an agent means bumping its version and every bundle that pins it.

## Relation kinds

- `normal` — a reporting line: `from` may dispatch work to `to`, and `to` shows up
  in the routing table of whoever reaches `from` (the chain is visible upstream).
  Reporting lines must not form a cycle.
- `peer` — a private horizontal channel between two colleagues (both may dispatch to
  each other). It does not propagate further, so it does not widen anyone else's
  routing table. Use it for collaborators that are not in a manager relationship
  (developer and QA, inbox and calendar).

`router` is the bundle's default entry point — the member the user's assistant sends
work to first. Set it only when the bundle has one natural lead (a manager); a bundle
of independent specialists has none, and the assistant dispatches to each directly.

| Bundle | Entry point |
|---|---|
| `software-delivery` — Software delivery team | `product-manager` |
| `platform-operations` — Platform operations | `infra` |
| `leadership-planning` — Leadership and planning | `coo` |
| `home` — Household | none |
| `personal-productivity` — Personal productivity | none |
