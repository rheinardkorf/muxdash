---
name: muxdash
description: Answer questions about the user's work from muxdash's cache, what their fetchers have already gathered (GitHub PRs and Actions runs, running agents, and whatever else this machine's muxdash shows, such as Jira, AWS, calendar or feeds). Use when the user asks what's waiting on them, what's failing, what's new, or about a specific PR, run, ticket, alarm, meeting or agent session.
---

# muxdash

muxdash is the user's tmux dashboard. Its fetchers call the outside services on a timer and
write everything to a cache. You only read that cache, through the `read` script in this
skill's folder: no network, no API calls. If the cache doesn't have something, say so; don't
go looking for it elsewhere (no `gh`, no `curl`, no `muxdash fetch`).

Run `~/.config/muxdash/skills/muxdash/read` with one of these, one command at a time.

**A question about everything ("what do I need to know", "anything to worry about") gets
`read list`** with nothing after it: every pane at once.

**A question about one area ("my GitHub status", "how are my agents") gets
`read list <pane>`** (`read list github`, `read list agents`): it shows every list in that pane,
so nothing is missed. Pick single lists only when the question is about one ("my open PRs").

- `read panes`: what's there: each pane, its lists, their item counts and how long ago they
  were fetched. Use it when you don't know the pane names.
- `read list <pane>` (e.g. `read list github`): every list in that pane, each as below. Use
  this for a broad question about a pane, so nothing in it is missed.
- `read list <list>`: one list. A long list comes as counts by status, then what needs attention (failing,
  or marked `●` changed / `?` waiting on the user), then the most recent. A short list comes
  whole. Columns: mark, key, status, when, title, id.
- `read all <list>`: every item, only when the user wants everything.
- `read show <pane> <id>`: one item in detail, as Markdown. `<pane>` is the part before the
  `/`; `<id>` is the last column of `read list`, quoted.
- `read search <pane> <words>`: items whose content has the words (not every pane can).

Don't `read show` everything: only what the user asks about, or the one
or two items that clearly need them.

## Answering

Answer from what you read: titles, statuses, counts, how long ago. Lead with what needs the
user (waiting on their review, failing, marked `?`), then the rest, briefly. Say how fresh it
is when that matters ("as of 2 minutes ago"). Give a `url` from `read show` when the user will
want to open something.
