# Coding Standards

Rules for reviewing changes in any project. The `code-review` skill reads this
file on the Standards axis. Agents read it during review, not during
implementation. A project-level `CODING_STANDARDS.md` or `CONTRIBUTING.md`
wins on conflict.

Skip anything tooling already enforces. Check the repo's linter, formatter,
and pre-commit config first. Flag only what a linter cannot see.

## General code

- Match the style already in the file over any general default.
- A new dependency needs a stated reason in the PR. Flag any lockfile or
  manifest change with no reason.
- A comment says only what the code cannot show: the why, the gotcha, the
  external constraint. Flag comments that restate the code.
- Comments keep the articles ("the", "a"). Flag telegram style.
- One name per thing. Flag a second name for a concept the file already
  names.
- Flag unfinished code that is not marked with a `TODO` comment. Flag an
  improvised workaround where the clean fix was in reach.

## Tests

- A test that cannot fail when the logic is wrong is not worth having.
  Flag tests that assert a mock returns what the mock was told to return.
- A behaviour change needs a test that proves it. Flag a bug fix with no
  test that would have caught the bug.
- Failure paths need tests, not only the happy path. For anything that
  retries, times out, or talks to a remote system, see the failure list
  under [Cross-service consistency](#cross-service-consistency).

## API design

Applies to every HTTP handler, route, request model, and response model.

### Resources and routes

- Collection nouns are lowercase, stable, and use one multiword convention
  across the module.
- Identifiers in paths are opaque. Flag paths that expose storage layout.
- Nesting is for true containment or scope only.
- Query parameters carry filtering, sorting, pagination, and field selection.
- `GET` and `HEAD` never change state. Flag `?action=...` style verbs.
- A command endpoint is a last resort. If one is added, the PR states its
  authorization, idempotency, result, and failure behaviour.

### Contract

- Every input is validated and bounded: path, query, header, cookie, and
  body. Flag unbounded page sizes, list lengths, string lengths, and body
  sizes.
- Unknown fields have a documented policy: reject or ignore. Flag silence.
- Responses are serialized from an allowlisted response type, not from the
  persistence object.
- New public error bodies use RFC 9457 Problem Details. An existing module
  that already commits to another error shape keeps that shape.
- Status codes follow HTTP semantics. Flag `200` for a created resource,
  `500` for a client mistake, and `404` used to hide an authorization
  failure without a stated reason.
- Naming of JSON fields, timestamps, identifiers, enums, money, and nulls
  follows the convention already in the module. Flag a new convention.
- Lists that paginate have a maximum page size and a deterministic tie-break
  order.

### Security

- Authentication and authorization are separate steps. Every protected
  object, tenant, relationship, field, and action is authorized on the
  server.
- Input schema checks run before policy and business logic. Output
  filtering runs after authorization.
- Secrets, credentials, raw payloads, and unneeded personal data stay out
  of errors, logs, metrics, and traces. Flag any log line that prints a
  request body or a token.
- Outbound calls have an explicit destination policy. Flag user-controlled
  URLs with no allowlist.
- Webhook receivers verify signature and timestamp, reject replays, and hand
  off durably before returning `2xx`.

### Retries, idempotency, and concurrency

- A retryable mutation has a stable operation identity: an idempotency key
  the client owns, a request fingerprint, atomic persistence, and a replayed
  response on duplicate.
- Idempotent means the server effect is stable. It does not mean the
  response is byte-identical.
- Mutable resources where concurrency matters use optimistic concurrency
  (`ETag` or version) and return a stale-write error.
- Every remote call has one end-to-end deadline and a per-attempt timeout.
  Retries have a named owner, a bounded count, backoff, and jitter. Flag
  retries with no budget, and retries of non-transient errors.
- Rate limits name the principal, the quota unit, the window, and the
  response headers.

### Evolution

- The OpenAPI document is a versioned contract. Flag any change to request
  or response schema, requiredness, defaults, enums, error types, status
  codes, ordering, pagination, or authorization that is not classified as
  breaking or additive in the PR.
- An additive syntax change can still be a breaking behaviour change. The
  classification looks at behaviour, not only at schema.
- A breaking change has migration evidence and a deprecation owner.

## Cross-service consistency

Applies when one business operation spans services, databases, brokers, or
external systems, including third-party APIs.

### Non-negotiables

- One local ACID transaction wins when the data stays in one ownership
  boundary. Flag distributed patterns used where one transaction would do.
- A database write followed by a direct publish is a dual write. Flag it
  unless the change uses a Transactional Outbox.
- Messages can be delayed, duplicated, reordered, and redelivered. Consumers
  make duplicates harmless at the business-effect boundary.
- Acknowledging a message is not proof the effect happened once. Flag
  claims such as "the broker guarantees exactly once".
- Compensation is a new business action, not a rollback. It can fail. The
  PR states what happens when it fails.
- Workflow state, deadlines, attempts, and decisions live in durable storage.
  Flag authoritative Saga state held only in process memory.
- Retries and timeouts are bounded. Poison messages are quarantined with an
  owner, an alert, and a replay path.

### Pattern choice

Pick the simplest correct pattern and say why in the PR:

1. One service, one database: local transaction.
2. Publish after a local state change: Transactional Outbox.
3. Protect a consumer from duplicate effects: Inbox or a domain idempotency
   key, or both.
4. Short cross-service flow with central ownership and complex compensation:
   Saga orchestration.
5. Loose event reaction, few participants, no central state: choreography.
6. Many ordered steps, long waits, approvals, deadlines: a durable workflow
   engine or an explicit orchestrator.
7. Strong global atomicity required: rethink the service boundary before
   reaching for distributed locks or two-phase commit.

### Reliability contract

- Operation and message identifiers are generated before the first attempt
  and reused on retry.
- Retrying the transport and retrying the business command are different
  decisions. Flag code that conflates them.
- Stale state transitions are rejected with an explicit version or
  expected-state check.
- Operations on one aggregate are serialized where concurrent transitions
  would break an invariant.
- Handlers are deterministic around recorded input. Nondeterministic calls
  sit behind persisted results.
- Reconciliation compares authoritative business state with Outbox, Inbox,
  broker, and workflow state. It does not replay everything blindly.

### Observability

Structured events and metrics exist for: workflow state transitions and age,
relay backlog age, duplicate and stale message counts, retry and timeout and
compensation counts, dead-letter depth, and correlation and causation IDs on
every command and event. Logs carry identifiers, state, and schema version,
not payloads.

### Failure tests

Flag a cross-service change with no test for the failure boundaries it
touches:

- crash after the domain commit but before publish;
- publish succeeds but the publication mark fails;
- duplicate, delayed, stale, and out-of-order delivery;
- consumer crash before and after the local commit;
- concurrent commands for the same aggregate;
- timeout followed by a late success;
- compensation failure and repeated compensation;
- schema version skew during a rolling deployment;
- replay from dead-letter storage.

## Commits

- Conventional Commits, subject line only unless a body was asked for.
  Match the scope style already in the repo, for example `feat(frontend):`.
- The subject describes the change a user or reviewer sees, in plain words.
  The how belongs in the diff.

## Docs

- README order: what it is and who it is for, does it work, how to run it,
  how it is built.
- Present tense only for what exists. Unfinished work goes under
  Limitations, with what does not work and why.
- A warning goes before the command it applies to.
- Every command in a doc runs from a clean clone. A PR that touches nearby
  code updates or deletes stale commands, screenshots, and numbers.
- Update the existing doc. Flag a new doc file that nobody asked for.

## Diagrams

- Diagrams are hand-authored SVG files in `docs/images/`, referenced from
  the doc with a one-sentence text description underneath. Flag mermaid,
  raster images, and external fonts.
- Style: annotated schematic. Rounded boxes with thin coloured outlines and
  pale fills. Colour carries meaning: green for structure, blue for auth or
  flow, orange for unvalidated, red for risk. Numbered circles for steps.
  Dashed lines for proposed or candidate paths. A legend strip and a
  one-line caption at the bottom. Sans-serif system fonts only.
- The author renders each SVG and looks at it before reporting it done.

## Prose in code, docs, and PRs

- Lead with the answer, the fix, or the action.
- Instructions have at most 20 words, other sentences at most 25. One
  instruction per sentence. Active voice with a named actor.
- Everyday words. A technical term gets a short explanation on first use.
- No noun chain over three words.
- Banned words: leverage, utilize, robust, seamless, delve, holistic,
  cutting-edge, "at the end of the day", "in today's fast-paced world",
  "it's important to note", "it's worth noting".
