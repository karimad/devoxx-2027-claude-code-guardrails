#!/bin/bash
# PostToolUse(Bash): after PR review comments are posted, remind the assistant to arm a follow-up recheck.
# Never blocks: it only adds context to the conversation.
cmd=$(jq -r '.tool_input.command // empty')
posted=0
if echo "$cmd" | grep -Eq 'gh pr review' && ! echo "$cmd" | grep -q -- '--approve'; then posted=1
elif echo "$cmd" | grep -Eq 'pulls/[0-9]+/(reviews|comments)' \
  && echo "$cmd" | grep -Eq '(--input|-X POST|--method POST|(^| )-[fF] )'; then posted=1
fi
[ "$posted" = 1 ] || exit 0
jq -n '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:"PR review comments were just posted. In this same turn, schedule the follow-up recheck for this PR (see Step 6 of the pr-reviewer agent). Do not wait for the user to ask."}}'
