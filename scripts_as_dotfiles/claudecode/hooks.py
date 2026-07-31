#!/usr/bin/env -S uv run --script

import json
import os
import sys
import difflib
import subprocess
import html


MAX_BODY_BYTES = 3500

# notify-send urgencies
ROUTINE = "low"  # grey
DONE = "normal"  # blue, finished
ATTENTION = "critical"  # goldenrod, waiting on you


def truncate(body: str):
    encoded = body.encode()
    if len(encoded) <= MAX_BODY_BYTES:
        return body
    clipped = encoded[:MAX_BODY_BYTES].decode(errors="ignore")
    head, sep, _ = clipped.rpartition("\n")
    return (head if sep else clipped) + "\n[truncated]"


def notify(
    body: str,
    level: str = ROUTINE,
    title: str = "",
    tag: str = "claude",
    sticky: bool = False,
):
    cmd = [
        "notify-send",
        "--app-name",
        "claude",
        "--category",
        tag,
        "--urgency",
        level,
        *(("-t", "0") if sticky else ()),  # 0 never expires
        title or "claude",
        truncate(body),
    ]
    try:
        subprocess.call(cmd, timeout=5)
    except (OSError, subprocess.TimeoutExpired):
        pass


def create_diff(old: str, new: str):
    diff_generator = difflib.unified_diff(
        old.splitlines(), new.splitlines(), lineterm="", n=3
    )
    diff_str = "\n".join(diff_generator)
    return diff_str


ADDED = "\U0001f7e9"  # green square
REMOVED = "\U0001f7e5"  # red square
GUTTER = " "


def generate_diff_markup(diff_str: str):
    diff_lines = diff_str.splitlines()[3:]
    markup_lines = []
    for line in diff_lines:
        prefix = line[:1]
        # fnott decodes HTML
        content = html.escape(line[1:], quote=False) if len(line) > 1 else ""
        if prefix == "+":
            markup_lines.append(f"{ADDED} {content}")
        elif prefix == "-":
            markup_lines.append(f"{REMOVED} {content}")
        else:
            markup_lines.append(f"{GUTTER} {content}")
    return "\n".join(markup_lines)


if __name__ == "__main__":
    data = json.load(sys.stdin)
    hook = data.get("hook_event_name")
    if hook == "PostToolUse":
        tool = data.get("tool_name")
        input = data.get("tool_input")
        response = data.get("tool_response")
        with open(os.path.expanduser("~/.claude/log-posttooluse.txt"), "a") as f:
            f.write(f"Tool: {tool}\nPostToolUse:{input}\nResponse:{response}\n")
        if tool == "Task":
            if input.get("subagent_type") == "general-purpose":
                notify(f"{tool} - {input.get('description')}")
            else:
                notify(
                    f"{tool} - {input.get('subagent_type')} - {input.get('description')}"
                )
        elif tool == "Bash":
            notify(
                input.get("command"),
                title=f"{tool} - {input.get('description')}",
            )
        elif tool == "Glob":
            notify(f"{tool} - {input.get('pattern')}")
        elif tool == "Grep":
            notify(
                f"{input.get('pattern')}",
                title=f"{tool} at {input.get('path')}",
            )
        elif tool == "Read":
            notify(f"{tool} {input.get('file_path')}")
        elif tool == "Edit":
            diff = create_diff(input.get("old_string", ""), input.get("new_string", ""))
            markup = generate_diff_markup(diff)
            notify(
                markup,
                title=input.get("file_path", "Unknown"),
                tag="claude-edit",
                sticky=True,
            )
        elif tool == "Write":
            diff = create_diff("", input.get("content"))
            markup = generate_diff_markup(diff)
            notify(
                markup,
                title=f"Write {input.get('file_path')}",
                tag="claude-edit",
                sticky=True,
            )
        elif tool == "TodoWrite":
            pass
            # todos = input.get("todos", [])
            # for i, td in enumerate(input.get("todos", []), 1):
            #     notify(f"Todo {td.get('status', '')} - {td.get('content', '')}")
        elif tool == "WebFetch":
            notify(f"{tool} - {input.get('url')} - {input.get('prompt')}")
        elif tool == "WebSearch":
            notify(f"{tool} - {input.get('query')}")
        elif tool == "NotebookEdit":
            diff = create_diff("", input.get("new_source"))
            markup = generate_diff_markup(diff)
            notify(
                markup,
                title=f"{tool} {input.get('notebook_path')}",
                tag="claude-edit",
                sticky=True,
            )
        elif tool == "BashOutput":
            notify(f"{tool} - {input.get('bash_id')}")
        elif tool == "KillShell":
            notify(f"{tool} - {input.get('shell_id')}")
        elif tool == "ExitPlanMode":
            if response.get("isAgent"):
                notify(
                    f"{tool} - AGENT - {response.get('plan')}",
                    level=ATTENTION,
                )
            else:
                notify(f"{tool} - {response.get('plan')}")
        elif tool == "SlashCommand":
            if response.get("success"):
                notify(f"{tool} - {input.get('command')} - Success")
            else:
                notify(f"{tool} - {input.get('command')} - Failure")
        else:
            notify(f"{tool} - {input}")
    elif hook == "Stop":
        notify("Finished", level=DONE)
    elif hook == "Notification":
        message = data.get("message")
        if message.startswith("Claude needs your permission"):
            notify(
                "Waiting for input",
                level=ATTENTION,
            )
        elif message == "Claude is waiting for your input":
            pass
        else:
            notify(f"{hook} - {message}")

    sys.exit(0)
