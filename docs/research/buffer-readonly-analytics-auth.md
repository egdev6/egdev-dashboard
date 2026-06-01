# Buffer read-only analytics scope and auth research

This note records the M5 research result for issue #17: validate Buffer's read-only analytics access path before implementing LinkedIn or X snapshot ingestion.

## Executive result

Buffer's current public API is **not a read-only analytics API** for LinkedIn or X snapshots.

The official Help Center states that Buffer's public API is currently focused on post creation and idea management, and that analytics data is not available via the API. The GraphQL reference exposes useful read queries for account, organizations, channels, posts, posting limits, and post metadata, but it does not expose engagement analytics metrics such as impressions, clicks, reactions, comments, reposts, or engagement rate.

Therefore M5 should treat Buffer analytics ingestion as blocked on one of these paths:

1. Buffer adds analytics endpoints to the public API;
2. a private/manual export path is approved;
3. the project chooses a different analytics source for LinkedIn and X.

Do not build publishing or scheduling automation as part of this research slice.

## Sources reviewed

| Source | Relevant finding |
|---|---|
| Buffer Help Center, "Using Buffer's API" | Public API is focused on post creation and idea management; analytics data is not available via API. |
| Buffer GraphQL authentication guide | API requests use Bearer API keys; OAuth 2.0 Authorization Code with PKCE is available for app integrations. |
| Buffer GraphQL rate limits guide | Limits are per client and plan-based across 15-minute, 24-hour, and 30-day windows. |
| Buffer GraphQL API reference | Read queries exist for accounts, channels, posts, and posting limits; analytics metrics are not exposed as first-class queries. |

Reference URLs:

- `https://support.buffer.com/article/859-does-buffer-have-an-api`
- `https://developers.buffer.com/guides/authentication.html`
- `https://developers.buffer.com/guides/api-limits.html`
- `https://developers.buffer.com/reference.html`

## Auth model

### Personal API key

For first-party/internal automation, Buffer supports personal API keys:

- create a key from Buffer Settings → API;
- send it as `Authorization: Bearer <token>` to `https://api.buffer.com`;
- the key acts on behalf of the account;
- the key can access all organizations and channels available to that account;
- there is no per-organization scoping for the key, so queries must target the intended organization/channel explicitly;
- keys must stay server-side in `.env` or a secret manager.

### OAuth app client

For third-party/multi-user integrations, Buffer supports OAuth 2.0 Authorization Code with PKCE:

- confidential clients receive `client_id` and `client_secret`;
- public clients use PKCE and no client secret;
- access tokens expire and refresh tokens are single-use;
- requested scopes are space-separated in the authorization request.

Documented OAuth scopes include:

| Scope | Meaning |
|---|---|
| `posts:read` | View posts and queue. |
| `posts:write` | Create and manage posts. |
| `ideas:read` | View ideas. |
| `ideas:write` | Create and manage ideas. |
| `account:read` | View account information. |
| `account:write` | Update account settings. |
| `offline_access` | Receive refresh token for long-lived access. |

There is no documented `analytics:read` scope in the reviewed public docs.

## Read-only data currently available

The GraphQL API can support limited read-model snapshots around publishing state, not analytics outcomes.

Potentially useful read-only fields include:

| Area | Examples from GraphQL reference | Usefulness |
|---|---|---|
| Account/org | account id, organizations, timezone, owner/admin context | Identify which Buffer account/org is being queried. |
| Channels | channel id, service, display name, external link, scopes, posting schedule, queue paused, posting goal | Map Buffer channels to `discord-project-manager` network namespaces. |
| Posts | post id, status, due/sent dates, text, external link, channel service, assets, tags, metadata | Reconcile planned/published content with the content ledger. |
| Limits | daily posting limits, weekly posting limit, sent/scheduled counts | Operational capacity checks, not audience analytics. |

These reads can help reconcile content-ledger state, but they do not satisfy LinkedIn/X analytics ingestion by themselves.

## LinkedIn metrics availability

Read-only LinkedIn analytics metrics are **not available through the reviewed Buffer public API**.

Do not assume Buffer can provide these LinkedIn metrics via API yet:

- impressions;
- reactions;
- comments;
- shares/reposts;
- clicks;
- engagement rate;
- follower deltas;
- audience demographics.

The only LinkedIn-specific fields visible in the public GraphQL reference are post metadata fields such as annotations, first comment, and link attachment, plus generic post/channel fields.

## X metrics availability

Read-only X analytics metrics are **not available through the reviewed Buffer public API**.

Do not assume Buffer can provide these X metrics via API yet:

- impressions;
- likes;
- replies;
- reposts;
- quote posts;
- clicks;
- engagement rate;
- follower deltas.

The public GraphQL reference exposes Twitter/X post metadata such as thread data and retweet metadata, plus generic post/channel fields. Those are content metadata, not analytics outcomes.

## Rate limits and constraints

Buffer applies plan-based API rate limits per client.

| Window | Free | Essentials | Team |
|---|---:|---:|---:|
| 15 minutes | 100 | 100 | 100 |
| 24 hours | 100 | 250 | 500 |
| 30 days | 3,000 | 7,500 | 15,000 |

Additional constraints:

- rate limit headers include `RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`;
- exceeding limits returns HTTP `429` with `RATE_LIMIT_EXCEEDED` and `retryAfter`;
- GraphQL query complexity, depth, alias, directive, and token limits also apply;
- personal API key limits may be shared across personal keys, while OAuth app clients are tracked separately;
- Buffer's Help Center describes configurable API key expiration windows, so implementations should be prepared to rotate keys before they expire.

## Security boundaries

- Store Buffer keys/tokens only in `.env` or a secret manager.
- Never commit Buffer API keys, OAuth client secrets, refresh tokens, raw exports, or analytics snapshots.
- Treat manually exported analytics as private by default until sanitized and promoted.
- Keep public fixtures fake/demo only.
- Do not expose Buffer calls from browser/client code.

## Implementation recommendation

For #18 and #19, do not implement live Buffer analytics ingestion yet.

Recommended next safe slices:

1. Define a fake analytics snapshot schema for LinkedIn and X that can be populated later from Buffer, manual exports, or another source.
2. Add local validation scripts that use fake/demo analytics fixtures only.
3. Keep `.env.example` placeholders as credentials only; do not require live Buffer credentials in CI.
4. Create a separate spike if live API access is available to verify whether a specific Buffer account exposes any non-public analytics fields.

## Decision

M5 analytics should proceed contract-first with fake fixtures and no live Buffer dependency until an approved analytics source is confirmed.

The public Buffer API can help with content/post reconciliation, but current official docs do not support the original assumption that Buffer can provide read-only LinkedIn/X analytics metrics via public API.
