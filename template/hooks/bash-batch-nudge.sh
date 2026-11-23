#!/bin/bash
# Soft nudges, never blocks - always exits 0.
# 1) Bash-batch nudge: fires every N consecutive Bash calls (any other tool resets it).
# 2) Explore-fork nudge: fires every M consecutive "exploration" calls
#    (Bash/Read/Grep/Glob/WebFetch/ToolSearch), reset only when real work/delegation
#    happens (Edit/Write/NotebookEdit/Agent) - so long Read/Grep/Bash chains still count
#    even if they never touch Bash on back-to-back calls.

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // ""' 2>/dev/null)
session_id=$(echo "$input" | jq -r '.session_id // "unknown"' 2>/dev/null)

bash_counter_file="/tmp/.claude_bash_streak_${session_id}"
explore_counter_file="/tmp/.claude_explore_streak_${session_id}"

messages=""

# --- 1) Bash-batch nudge ---
if [ "$tool_name" == "Bash" ]; then
  bash_count=0
  [ -f "$bash_counter_file" ] && bash_count=$(cat "$bash_counter_file" 2>/dev/null || echo 0)
  bash_count=$((bash_count + 1))
  echo "$bash_count" > "$bash_counter_file"

  if [ $((bash_count % 15)) -eq 0 ]; then
    messages="${messages}You have made ${bash_count} consecutive Bash calls without using another tool in between. Combine remaining shell commands into fewer, batched invocations (chain with && or a single script) where possible - each turn re-bills the full accumulated context from cache. "
  fi
else
  rm -f "$bash_counter_file" 2>/dev/null
fi

# --- 2) Explore-fork nudge ---
case "$tool_name" in
  Bash|Read|Grep|Glob|WebFetch|ToolSearch)
    explore_count=0
    [ -f "$explore_counter_file" ] && explore_count=$(cat "$explore_counter_file" 2>/dev/null || echo 0)
    explore_count=$((explore_count + 1))
    echo "$explore_count" > "$explore_counter_file"

    if [ $((explore_count % 20)) -eq 0 ]; then
      messages="${messages}You have made ${explore_count} consecutive exploration-type calls (Bash/Read/Grep/Glob) in the main session without producing a result. Consider delegating further exploration/iteration to a fork or subagent instead of continuing serial calls here - the main session's cache-read cost compounds with every turn."
    fi
    ;;
  Edit|Write|NotebookEdit|Agent)
    rm -f "$explore_counter_file" 2>/dev/null
    ;;
  *)
    : # neutral tools (AskUserQuestion, Skill, ScheduleWakeup, etc.) - no increment, no reset
    ;;
esac

# --- 3) Agent model right-sizing nudge ---
if [ "$tool_name" == "Agent" ]; then
  subagent_type=$(echo "$input" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null)
  model=$(echo "$input" | jq -r '.tool_input.model // ""' 2>/dev/null)
  model_lc=$(echo "$model" | tr '[:upper:]' '[:lower:]')

  if [ "$subagent_type" != "fork" ]; then
    if [ -z "$model" ]; then
      messages="${messages}This Agent call has no explicit model param - it will inherit the parent session's model. Pass model: \"haiku\" or model: \"sonnet\" explicitly (never let it silently inherit Opus). "
    elif [[ "$model_lc" == *"opus"* ]]; then
      messages="${messages}This Agent call requests model=${model}. Opus should only be used for subagents when explicitly requested by the user in this conversation - otherwise use sonnet or haiku. Confirm this was an explicit user request; if not, switch the model. "
    fi
  fi
fi

if [ -n "$messages" ]; then
  python3 -c "import json,sys; print(json.dumps({'hookSpecificOutput': {'hookEventName': 'PreToolUse', 'additionalContext': sys.argv[1]}}))" "$messages"
fi

exit 0
