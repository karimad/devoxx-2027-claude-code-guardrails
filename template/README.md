# Claude Code configuration used in the talk

A generic subset of a daily-use setup. Copy what is useful and adapt it: every file here came from a real need, but your repositories and rules will differ.

| Path | What it does |
|---|---|
| `garde-fous.md` | Checklist of guardrails (in French), the talk's takeaway |
| `CLAUDE.md.example` | A short global instructions file |
| `settings.example.json` | Wires the hooks below and sets the default model |
| `hooks/block-pr-top-level-comment.sh` | Blocks a top-level `gh pr comment`. Findings must be inline review comments. Prefix the command with `ALLOW_PR_COMMENT=1` to override |
| `hooks/pr-review-recheck-reminder.sh` | After review comments are posted, reminds the assistant to schedule the follow-up recheck |
| `hooks/bash-batch-nudge.sh` | Soft nudges, never blocks: batch shell calls, delegate long exploration, and set an explicit model on subagents |
| `hooks/wiki-session-sync-on-end.sh` | At session end, starts the wiki sync in the background, throttled and skipped for short sessions |
| `skills/verify/SKILL.md` | Runs the project's tests before claiming work is done |
| `skills/wiki-session-sync/SKILL.md` | Mines recent sessions for verified facts and updates a personal wiki |
| `skills/incident-triage/SKILL.md` | Turns an observability link into a structured diagnosis |
| `agents/pr-reviewer.md` | A PR review subagent that verifies each finding before reporting it |

The hooks need `jq`. Install the files under `~/.claude/` and merge `settings.example.json` into your own `settings.json`: do not overwrite it.
