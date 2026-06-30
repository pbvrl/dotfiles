#!/usr/bin/env -S uv run --script

# Notifies of what claude-code is doing through notify-send

import json
import os
import sys
import difflib
import subprocess
import html


def notify(
    body: str,
    notification_type: str = "claude-minimal",
    title: str = "",
    transient=True,
):
    if bool(title) and notification_type == "claude-minimal":
        notification_type = "claude"
    cmd = ["notify-send", title, body, "-c", notification_type]
    if transient:
        cmd += ["-t", "10000"]
    subprocess.call(cmd)


def create_diff(old: str, new: str):
    diff_generator = difflib.unified_diff(
        old.splitlines(), new.splitlines(), lineterm="", n=3
    )
    diff_str = "\n".join(diff_generator)
    return diff_str


def generate_pango_markup(diff_str: str):
    diff_lines = diff_str.splitlines()[3:]
    markup_lines = []
    for line in diff_lines:
        prefix = line[:1]
        content = html.escape(line[1:]) if len(line) > 1 else ""
        if prefix == "+":
            markup_lines.append(
                f'<span background="green" foreground="white">{content}</span>'
            )
        elif prefix == "-":
            markup_lines.append(
                f'<span background="red" foreground="white">{content}</span>'
            )
        else:
            markup_lines.append(content)
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
            if input.get("subagent_tyype") == "general-purpose":
                notify(f"{tool} - {input.get('description')}")
            else:
                notify(
                    f"{tool} - {input.get('subagent_type')} - {input.get('description')}"
                )
        elif tool == "Bash":
            notify(
                input.get("command"),
                title=f"{tool} - {input.get('description')}",
                transient=False,
            )
        elif tool == "Glob":
            notify(f"{tool} - {input.get('pattern')}")
        elif tool == "Grep":
            notify(
                f"{input.get('pattern')}",
                notification_type="claude",
                title=f"{tool} at {input.get('path')}",
            )
        elif tool == "Read":
            notify(f"{tool} {input.get('file_path')}")
        elif tool == "Edit":
            diff = create_diff(input.get("old_string", ""), input.get("new_string", ""))
            markup = generate_pango_markup(diff)
            notify(
                markup,
                notification_type="claude-edit",
                title=input.get("file_path", "Unknown"),
                transient=False,
            )
        elif tool == "Write":
            diff = create_diff("", input.get("content"))
            markup = generate_pango_markup(diff)
            notify(
                markup,
                notification_type="claude-edit",
                title=f"Write {input.get('file_path')}",
                transient=False,
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
            markup = generate_pango_markup(diff)
            notify(
                markup,
                notification_type="claude-edit",
                title=f"{tool} {input.get('notebook_path')}",
                transient=False,
            )
        elif tool == "BashOutput":
            notify(f"{tool} - {input.get('bash_id')}")
        elif tool == "KillShell":
            notify(f"{tool} - {input.get('shell_id')}")
        elif tool == "ExitPlanMode":
            if response.get("isAgent"):
                notify(
                    f"{tool} - AGENT - {response.get('plan')}",
                    notification_type="claude-minimal-important",
                    transient=False,
                )
            else:
                notify(f"{tool} - {response.get('plan')}")
        elif tool == "SlashCommand":
            if response.get("success"):
                notify(f"{tool} - {input.get('command')} - Success")
            else:
                notify(f"{tool} - {input.get('command')} - Failure")
        else:
            notify(
                f"{tool} - {input}",
                notification_type="claude-minimal-important",
                transient=False,
            )
    elif hook == "Notification":
        message = data.get("message")
        if message == "Claude needs your permission to use Bash":
            notify(
                "Waiting for input",
                notification_type="claude-minimal-important",
                transient=False,
            )
        elif message == "Claude is waiting for your input":
            notify("Finished")
        else:
            notify(f"{hook} - {message}")

    sys.exit(0)
