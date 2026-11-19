# muxdash

A tmux dashboard for what's waiting on you: pull requests, CI runs, tickets,
alarms, meetings, feeds and your running Claude Code sessions, as fzf lists
that never wait on the network.

**Status:** used every day, on macOS. Expect changes.

Each context gets a tmux window, and each window holds fzf lists. A fetcher
calls the services on a timer and writes to a cache; the lists, their Markdown
previews and an optional assistant HUD read only the cache, so they open
instantly and work offline. Markers stay quiet unless something really changed:
`●` new, `◆` changed since you looked.

```
 GitHub · Jira · AWS · Google Calendar · RSS        Claude Code hooks
        │ only the fetcher talks to these               │ muxdash event agents
        ▼                                               ▼
 fetcher (every N min, per list) ──▶ sources/* ──▶ cache ~/.cache/muxdash
                                                        │ read only
                                                        ▼
                         tmux session "muxdash": one window per context,
                         one fzf list per pane, a preview beside it
```

## What's in it

- **Sources** are small scripts that know one service each. The engine only
  knows items (`id`, `title`, `status`, `updated`, `url`), so a new service is
  a new script, and yours live beside the built-in ones.

  | Source | Shows | Uses |
  |---|---|---|
  | `github` | PR searches, Actions runs with a run-history spark, contributions with flow stats | `gh` |
  | `jira` | JQL searches, live SLA timers | `acli` |
  | `aws` | CloudWatch alarms with a 24h spark, CloudFormation stacks, DynamoDB tables, SQS queues | `aws` |
  | `calendar` | today and the next days, with a countdown and your RSVP | `gog` (read-only) |
  | `rss` | RSS and Atom feeds with pictures, a read-later list | Python, `uv` |
  | `agents` | running Claude Code sessions and their sub-agents, waiting / finished marks | local files, hooks |
  | `dynamodb-feature-flags` | feature flags kept as single-table DynamoDB items, with a toggle | `aws` |

- **Views and tabs:** a pane can hold several lists (tab switches), some hidden
  until you ask (alt-h).
- **Find** (alt-f) searches inside the cached items, not just their titles.
- **Actions and tags:** a key can tag an item (rss: read later) or run a
  source's action, behind a Yes/No popup.
- **The HUD** (`muxdash hud`, prefix A): a full-screen assistant over all of
  it, purely for show. Each source describes itself in a line and a spoken
  sentence, read aloud by an offline voice (Kokoro) or macOS `say`.
- **A Claude skill** (`skills/muxdash`) that answers "what's waiting on me?"
  from the cache: no API calls, and only the rows that matter.

## Requirements

macOS (idle detection and the HUD's CPU, memory and battery read the Mac),
with:

- `zsh`, `tmux` 3.3 or later, `fzf`, `jq`, `glow`
- `python3` for the HUD and `rss`; `uv` for the voice and `rss`'s article text
- kitty for pictures in previews and for `muxdash-open` (optional)
- each source's CLI, signed in: `gh`, `acli`, `aws`, `gog`

Tested with tmux 3.7, fzf 0.74, jq 1.8, glow 3.0 and kitty 0.48.

## Install

```sh
git clone https://github.com/rheinardkorf/muxdash ~/.local/share/muxdash
ln -s ~/.local/share/muxdash/bin/muxdash ~/.local/bin/muxdash
ln -s ~/.local/share/muxdash/bin/muxdash-open ~/.local/bin/muxdash-open   # optional

mkdir -p ~/.config/muxdash
cp ~/.local/share/muxdash/config.example.json ~/.config/muxdash/config.$(hostname -s | tr A-Z a-z).json
```

In `tmux.conf`:

```tmux
run-shell ~/.local/share/muxdash/muxdash.tmux
```

Then `muxdash up` builds the session and switches to it. Run it again any time:
it puts back windows that are missing or lost their program (after a
tmux-resurrect restore, say) and leaves the rest alone.

## Configure

`~/.config/muxdash/config.<machine>.json`, where the machine is
`$MUXDASH_MACHINE` or the lowercased hostname, with `config.local.json` merged
on top for anything that shouldn't be public (profiles, orgs, table names). JSON
with `//` comments:

```jsonc
{
  "panes": {
    "github": {
      "title": "GitHub",
      "source": "github",
      "views": {
        "review-requests": "is:open is:pr review-requested:@me archived:false",
        "my-prs": "is:open is:pr author:@me archived:false",
        "actions": "actions"
      },
      "every": "5m"
    },
    "calendar": {"title": "Calendar", "source": "calendar", "query": "upcoming", "every": "15m"}
  },
  // a layout is the session: one window per context, one pane per entry
  "layouts": {"work": {"github": ["github"], "calendar": ["calendar"]}}
}
```

`config.example.json` has every pane, the HUD's settings and each source's
options.

## Keys

| Key | Does |
|---|---|
| tab / shift-tab | next / previous view |
| enter / ctrl-o | full preview / open it (a browser, or the agent's tmux pane) |
| alt-f | find inside items |
| alt-h | show / hide the pane's hidden views |
| alt-s / alt-u | mark all seen / mark this one unseen |
| ctrl-r | fetch now |
| prefix A | the HUD (esc closes it) |

## Claude Code

The `agents` pane lists sessions from `~/.claude/sessions/`. Hooks fill in
what those files can't say (finished, waiting on a permission prompt): add
`muxdash event agents` as an async command hook in `~/.claude/settings.json` for
`SessionStart`, `SessionEnd`, `UserPromptSubmit`, `Stop`, `Notification`,
`PostToolUse`, `PostToolUseFailure`, `SubagentStart` and `SubagentStop`:

```json
{"hooks": {"Stop": [{"hooks": [{"type": "command", "command": "muxdash event agents", "async": true}]}]}}
```

For the skill, link `skills/muxdash` into `~/.claude/skills/`.

## The voice (optional)

The HUD speaks with [Kokoro](https://github.com/thewh1teagle/kokoro-onnx), run
through `uv`, when `kokoro-v1.0.onnx` and `voices-v1.0.bin` (from kokoro-onnx's
`model-files-v1.0` release) are in `~/.local/share/kokoro`; otherwise it uses
`say`.

## More

[`docs/architecture.md`](docs/architecture.md) covers how it all fits together:
the cache, seen tracking, every config key, the HUD, and writing a source.

muxdash started in my [dotfiles](https://github.com/rheinardkorf/dotfiles) as
`panel`; its history came along.

## License

MIT
