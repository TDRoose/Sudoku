#!/usr/bin/env bash
# Project shell policy for agent terminal commands.
set -euo pipefail

input=$(cat)

python3 -c '
import json, re, sys

data = json.load(sys.stdin)
command = data.get("command") or data.get("cmd") or ""
cmd = command.strip()

def respond(permission, user_msg=None, agent_msg=None):
    out = {"permission": permission}
    if user_msg:
        out["user_message"] = user_msg
    if agent_msg:
        out["agent_message"] = agent_msg
    print(json.dumps(out))

if not cmd:
    respond("allow")
    sys.exit(0)

# Block destructive patterns
if re.search(r"\brm\s+-rf\b", cmd) or re.search(r"\brm\s+-r\s+-f\b", cmd):
    respond(
        "deny",
        "Blocked: recursive force delete is not allowed in this project.",
        "Use safer file edits instead of rm -rf.",
    )
    sys.exit(0)

if re.search(r"git\s+push\b.*--force", cmd) or re.search(r"git\s+push\s+-f\b", cmd):
    respond(
        "ask",
        "Force push requires your approval.",
        "Confirm with the user before force-pushing.",
    )
    sys.exit(0)

if re.search(r"git\s+push\b", cmd):
    respond(
        "ask",
        "git push requires your approval for this personal repo.",
        "Only push when the user explicitly asked.",
    )
    sys.exit(0)

respond("allow")
'

exit 0
