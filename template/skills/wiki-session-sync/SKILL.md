---
name: wiki-session-sync
description: Scan recently ended sessions for confirmed technical or functional facts that are not yet in the personal wiki (~/wiki), and update the wiki if needed. Runs automatically from a SessionEnd hook, or manually as /wiki-session-sync.
---

# Wiki Session Sync

Keep `~/wiki` current by mining the sessions that happened since the wiki was last touched, and update it only when there is something real to add.

Read `~/wiki/CLAUDE.md` first (wiki schema and conventions) if it has not been loaded in this run.

## Step 0: Load state and pick the window

```bash
STATE=~/.claude/wiki-session-sync/state.json
LAST_LOG_DATE=$(grep -oE '^## \[[0-9-]+\]' ~/wiki/wiki/log.md | tail -1 | grep -oE '[0-9-]+')
LAST_PROCESSED_TS=$(python3 -c "import json,os; p=os.path.expanduser('$STATE'); print(json.load(open(p)).get('last_processed_ts','') if os.path.exists(p) else '')")
echo "last wiki log entry: $LAST_LOG_DATE"
echo "last processed session timestamp: $LAST_PROCESSED_TS"
```

Scan sessions with activity after `LAST_PROCESSED_TS`. On the first run, fall back to `LAST_LOG_DATE`.

## Step 1: Find candidate sessions

Look at every project directory under `~/.claude/projects/` for `*.jsonl` files (excluding `subagents/`) modified after the window start. For each candidate, extract the first user message (the topic) and the `cwd` (which repository the session ran in).

Keep only sessions that touch a domain the wiki tracks: a repository or service that has a page, a pull request or issue against one of them, or a personal project already in the wiki. Skip pure Q&A, tooling questions about Claude Code itself, and one-off scripts.

## Step 2: Mine each session for confirmed facts

Read the tail of the assistant messages (the last 40 to 60 entries is usually enough). Apply the wiki's own bar:

> Only include facts that were verified, implemented, tested or explicitly confirmed in the session. Never speculation, abandoned ideas or untested hypotheses.

Look for:
- a root-caused bug, confirmed by a code read, a reproduction, or log evidence
- a verified architecture fact or business rule that was not documented
- a resolved gotcha or workaround
- a review finding that reveals a real bug pattern
- a design decision reached and validated

Do not record work in progress, decisions not to do something (unless durable), or pull request mechanics with no technical substance.

## Step 3: Update the wiki

For each surviving finding:
1. Find the most relevant page under `~/wiki/wiki/concepts/`. If none exists and the topic is substantive, create one following the frontmatter convention in `~/wiki/CLAUDE.md`.
2. Append the fact under the right section, matching the tone of the existing bullets.
3. Bump the page's `updated:` date.
4. Flag a contradiction with an earlier claim explicitly instead of overwriting it silently.

Update `~/wiki/wiki/index.md` for every page touched or created, and append one entry to `~/wiki/wiki/log.md`:

```
## [YYYY-MM-DD] ingest | <short title for this sync run>

- <one bullet per finding, with the session or PR it came from>
- <anything borderline that was excluded, and why>
```

If nothing passes the bar, change no wiki file and write no log entry. Still do Steps 4 and 5 so the run is recorded as a no-op.

## Step 4: Commit and update state

```bash
cd ~/wiki && git add -A && git status --short
git diff --cached --quiet || git commit -m "ingest: automated session sync, <short summary>"
```

Record the latest timestamp actually scanned, even on a no-op run, so the next run does not rescan the same sessions:

```bash
python3 -c "
import json, os
p = os.path.expanduser('~/.claude/wiki-session-sync/state.json')
json.dump({'last_processed_ts': '<ISO timestamp of the latest message scanned>', 'last_run': '<now, ISO>'}, open(p, 'w'), indent=2)
"
```

## Step 5: Record the run

The skill runs headless from a hook, so leave a trace:

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)  pages_touched=<N>  findings=<N>  sessions_scanned=<N>  <one-line summary or 'no-op'>" >> ~/.claude/wiki-session-sync/runs.log
```

## Notes for headless runs

- Never ask the user a question. Make the conservative call and record it. A genuine contradiction goes into the page as a flagged discrepancy.
- Keep the work bounded. Do not read multi-megabyte session files whole: read the tail and use targeted greps.
- This skill owns `~/wiki` only. Do not touch other memory or preference files here.
