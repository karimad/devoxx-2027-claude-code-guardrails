#!/usr/bin/env bash
# PreToolUse(Bash): block top-level `gh pr comment`; PR findings must be inline review comments.
# Escape hatch: prefix the command with ALLOW_PR_COMMENT=1.
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[[ "$cmd" == *ALLOW_PR_COMMENT=1* ]] && exit 0
if printf '%s' "$cmd" | grep -Eq '(^|[;&|(]|&&|\|\|)[[:space:]]*gh[[:space:]]+pr[[:space:]]+comment\b'; then
  echo "Blocked: post PR findings as inline review comments (gh api repos/{owner}/{repo}/pulls/{n}/reviews). For an intentional top-level comment, prefix the command with ALLOW_PR_COMMENT=1." >&2
  exit 2
fi
exit 0
