# Contributing to the b2ai catalog

Anyone can propose an agent or a bundle. Every change, including the owner's own,
arrives as a pull request, passes the **verifier**, and is merged only after the
**owner's review**. Nothing you merge reaches an installation until a release is cut
(installations read releases, never `main`).

- [What a submission is](#what-a-submission-is)
- [Start from b2ai (export a custom agent)](#start-from-b2ai-export-a-custom-agent)
- [Write it by hand](#write-it-by-hand)
- [Check it locally](#check-it-locally)
- [Open the pull request](#open-the-pull-request)
- [How review works](#how-review-works)
- [Official and Community](#official-and-community)
- [What gets refused](#what-gets-refused)
- [Changing an existing agent or bundle](#changing-an-existing-agent-or-bundle)

## What a submission is

```
agents/<id>/agent.yaml    kind: Agent — model, tools, extensions, capabilities (with risk)
agents/<id>/prompt.md     the agent's instructions (plain Markdown)
bundles/<id>/bundle.yaml  kind: Bundle — agents pinned to exact versions + reporting lines
tags.yaml                 tag vocabulary
```

`<id>` is a lowercase slug (`a-z`, `0-9`, `-`, at most 63 characters). It equals the
directory name and `metadata.id`, and it is unique across agents and bundles.

A minimal agent:

```yaml
apiVersion: b2ai.dev/v1
kind: Agent
metadata:
  id: invoice-chaser
  name: Invoice Chaser
  description: Chases unpaid invoices politely and reports who paid.
  icon: receipt             # optional; one of the fixed icon names, otherwise a monogram
  version: 1.0.0            # semver; a new agent starts at 1.0.0
  authors:
  - name: Your Name         # or your organisation
    url: https://github.com/your-handle
  license: Apache-2.0       # the catalog's license; see "License" below
  tags: [finance, email]    # 1-6 tags, preferably from tags.yaml
spec:
  model: {name: claude-sonnet-4-6, effort: medium}   # recommended; the installer may change it
  prompt: prompt.md
  tools: []                 # CLI tools from the platform's tools catalog only
  extensions:
    required: [gmail]       # the agent does not work without these
    optional: [kb]
  capabilities:
  - id: invoices.chase      # domain.action, unique within the agent
    description: Send a reminder for one unpaid invoice.
    inputs: {type: object, properties: {invoice: {type: string}}}   # JSON Schema (Draft 7)
    risk_level: medium      # none | low | medium | high — required, be honest
    plugins: [gmail]        # every extension a capability uses must be declared above
```

The full field reference (and the mapping from the older `role.yaml`) is in the
platform's catalog package README; the schema is enforced by the verifier, so the
verifier's messages are the quickest guide.

A bundle groups agents into a team:

```yaml
apiVersion: b2ai.dev/v1
kind: Bundle
metadata: {id: back-office, name: Back office, description: ..., version: 1.0.0,
           authors: [{name: Your Name}], license: Apache-2.0, tags: [finance]}
spec:
  agents:
  - {id: invoice-chaser, version: 1.0.0}   # exact pins, no ranges
  - {id: finance, version: 1.1.0}
  relations:
  - {from: finance, to: invoice-chaser, kind: normal}   # finance dispatches to invoice-chaser
  router: finance                                      # optional entry point
```

`normal` is a reporting line (it must not form a cycle); `peer` is a horizontal channel
between two colleagues. Every member must exist in the catalog at exactly the pinned
version.

## Start from b2ai (export a custom agent)

If you built the agent in b2ai first (**Agents → Create agent**), export it:

1. Open the agent, tab **Catalog**. It shows what the verifier would say about the
   agent as it is now — fix any error in the agent (add tags in the **Tags** tab, for
   example) and come back.
2. **Download (.zip)** and unzip it at the root of your clone of this repository. It
   creates `agents/<id>/agent.yaml` and `agents/<id>/prompt.md`.
3. Read both files before you go on. The export uses your name as the author, version
   `1.0.0` and license `Apache-2.0`; the emoji icon is dropped (pick a named icon if you
   like). Remove anything specific to your organisation from the prompt: hosts, people,
   repositories, internal names.

The product never opens the pull request for you. **Open a pull request** in the
Catalog tab takes you to GitHub's upload page for the agent's folder, which forks the
repository and opens the pull request from the files you drop there.

## Write it by hand

Copy an existing agent from `agents/` that is close to yours, rename the directory and
`metadata.id`, reset `metadata.version` to `1.0.0`, put yourself in `metadata.authors`,
and rewrite the rest.

## Check it locally

The verifier is the platform's own validator, published as an image built from the
platform. Run exactly the image CI runs (it is pinned in
`.github/workflows/verifier.yml`):

```sh
scripts/verify.sh              # validates the working tree against origin/main
```

or by hand:

```sh
IMAGE=$(sed -n 's/^ *VERIFIER_IMAGE: *//p' .github/workflows/verifier.yml)
git worktree add --detach /tmp/catalog-base origin/main
docker run --rm --network none -v "$PWD:/catalog:ro" -v /tmp/catalog-base:/base:ro \
  "$IMAGE" validate /catalog --base /base
```

Exit code `0` = valid (warnings may be printed), `1` = invalid. The tools and
extensions it accepts are the platform's, listed in the image:

```sh
docker run --rm --entrypoint cat "$IMAGE" /platform/tools.json /platform/extensions.json
```

## Open the pull request

Open it against `main` and fill in the template: what the agent does, every tool and
extension and why it needs it, and the highest risk. One agent (or one bundle with its
new agents) per pull request keeps the review readable.

## How review works

A pull request merges only after **both** gates; neither replaces the other.

1. **The verifier** (`verifier-l1`, a required check) proves the submission conforms:
   schema, tools from the platform's tools catalog only, extensions that exist, bundle
   references and pins that resolve, no reporting-line cycles, a version bump for every
   changed item, no binaries, symlinks or credentials, a prompt that is present and
   within the size cap, tag format and count. A tag outside `tags.yaml` is a warning so
   the reviewer accepts it deliberately. Nobody can merge a red pull request, the owner
   included.
2. **The owner's review** (CODEOWNERS) judges intent: does the agent do what the
   description says, does it need every tool and extension it asks for, is every
   capability's `risk_level` honest, does the prompt try to do anything else.

Review catches a malicious *structure*; a prompt is natural language and a subtle
injection can survive a reading. The real limit on damage is tools and extensions,
which is why the review looks at them first and why unknown tools are refused outright.
Before installing, an organisation sees the same things: capabilities with risk, tools
(cluster access flagged), extensions, the recommended model, the full prompt, source and
version.

## Official and Community

Both are reviewed the same way. The badge says who wrote the agent:

- **Official** — written by the catalog owner's team. Its `metadata.authors` names the
  team (`url: https://github.com/vmsolution-aka`).
- **Community** — submitted by anyone else. Put yourself (or your organisation) in
  `metadata.authors`.

The badge is decided by each installation, not by the manifest: an item is Official only
when the installation reads this catalog (its configured official sources) **and** an
author's `url` or `name` is in its official authors. A fork or a mirror that names the
owner's team therefore stays Community. In this repository, a community pull request
that lists the owner's team as an author is refused.

## What gets refused

By the verifier (the pull request stays red):

- a tool that is not in the platform's tools catalog, or an extension that does not exist
- a missing, empty or oversized prompt (64 KiB), or a prompt that is not UTF-8
- anything that looks like a credential (API keys, tokens, private keys, passwords in
  URLs) — the verifier reports the kind and the line, never the value
- binaries, symlinks, or files over 256 KiB
- a changed agent or bundle whose `metadata.version` did not go up
- retired fields (`sector`, `category`, `parent`, `children`) and emoji icons
- a bundle member that is not in the catalog at exactly the pinned version, or a cycle in
  its reporting lines
- more than 6 tags, or a tag that is not a lowercase slug of at most 24 characters

By the reviewer:

- tools or extensions the agent does not need for what it describes
- a `risk_level` lower than what the capability can do (sending email, spending money,
  changing infrastructure is not `low`)
- a prompt that hides instructions: sending data elsewhere, ignoring approvals, acting
  outside the agent's description, overriding the platform's rules
- an agent tied to one organisation (its hosts, people, repositories, internal names):
  catalog agents take those from the task or the installing organisation's context
- a community submission that claims the owner's team as its author
- a duplicate of an existing agent — propose a change to that one instead

## Changing an existing agent or bundle

Installed agents are pinned snapshots, so a version identifies content:

- bump `metadata.version` of every agent you change (semver: patch for wording, minor for
  a new capability or tool, major for a breaking change of capabilities);
- bump every bundle that pins it, and update the pin;
- removing an agent is a warning, not an error — say why in the pull request.

Organisations see an update as an explicit offer with a diff (prompt, tools,
capabilities with risk, model, extensions, tags); nothing updates on its own.

## License

The catalog is licensed under [Apache-2.0](LICENSE). By opening a pull request you agree
that your contribution is licensed under it, and `metadata.license` should say
`Apache-2.0`.
