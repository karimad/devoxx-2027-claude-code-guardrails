---
name: incident-triage
description: Investigate an observability link (logs, traces, dashboard or incident). Parse the URL, fetch the relevant logs or spans, find the root cause and report a structured diagnosis.
---

# Incident Triage

Given a link from an observability platform (Datadog in this example), fetch the underlying logs or traces and diagnose what went wrong.

## Step 1: Parse the URL

Extract these from the query parameters:

| Parameter | Use |
|---|---|
| `query` | The log search filter (URL-decode it) |
| `from_ts`, `to_ts` | Time window in milliseconds, passed straight to the search tool |
| `service` | Narrows the search when present |
| `trace_id` | For a trace URL, fetch the trace instead of searching logs |

A `/dashboard/` URL means read the dashboard. An `/incidents/` URL means read the incident. Otherwise treat it as a logs URL.

## Step 2: Load the platform's own guidance

Before searching, load any skill or guide the observability tools ship for the domain (logs, traces). It saves query-syntax mistakes.

## Step 3: Fetch all the logs

Search with the decoded query and the exact time window. Sort ascending by timestamp: the chronological order tells the story. Request all custom attributes. If the response is truncated, paginate until everything is retrieved.

## Step 4: Find the root cause

Walk the logs in order. Flag:
- entries with `status: error` or `warn`
- exception stack traces
- HTTP 4xx and 5xx responses
- database errors by SQLState (`53200` out of memory, `08006` connection failure, `40001` deadlock, `23505` unique violation)
- connection pool errors: broken connections, exhaustion, leak detection
- timeout patterns: entries 30 to 60 seconds after the request with no progress in between

Also confirm what was healthy: authentication succeeded, the request was forwarded through the service chain.

Rebuild the service chain from the `service` field. Gaps between timestamps show the slow step, and a silent gap means a silent failure.

## Step 5: Report

```
## Root cause
[One sentence: what broke and why]

## Timeline
| Time | Service | Event |
|------|---------|-------|
| HH:MM:SS | service-name | what happened |

## Errors found
- **[ERROR/WARN]** `service-name`: message, with the SQLState or exception class if relevant
  - Most relevant stack frame only

## What to investigate next
- [Specific file, query or config to check, and why it matters]
```

## Notes

- `53200` is PostgreSQL out of memory: the result set was too large. Check indexes or add pagination.
- `08006` is usually secondary to another error that killed the backend.
- A pool "marked as broken" followed by a leak report means the connection died during a query and was reclaimed.
- Wide date-range queries without `LIMIT` or a matching index are a common cause of out-of-memory errors.
- Never state a root cause the logs do not show. Say "not determined" and list what to check.
