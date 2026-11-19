#!/usr/bin/env sh
# muxdash's tmux keys. Load it from tmux.conf, through a plugin manager
# (set -g @plugin ...) or directly:
#
#   run-shell ~/.config/muxdash/muxdash.tmux
#
# Options, set before it loads (all optional):
#   @muxdash-bin       the muxdash engine      (default: bin/muxdash next to this file)
#   @muxdash-hud-key   prefix key: the HUD   (default: A; "off": no key)
#   @muxdash-key       prefix key: the muxdash session, built or repaired first
#                                          (default: off)

dir="$(cd "$(dirname "$0")" && pwd)"

opt() {
  v="$(tmux show-option -gqv "$1")"
  printf '%s' "${v:-$2}"
}

bin="$(opt @muxdash-bin "$dir/bin/muxdash")"
case $bin in "~/"*) bin="$HOME/${bin#"~/"}" ;; esac

hud_key="$(opt @muxdash-hud-key A)"
muxdash_key="$(opt @muxdash-key off)"

# the HUD over everything, borderless (esc closes it)
[ "$hud_key" = off ] || tmux bind-key "$hud_key" display-popup -E -B -w 100% -h 100% "'$bin' hud"
# muxdash up switches this client to the session once it's built
[ "$muxdash_key" = off ] || tmux bind-key "$muxdash_key" run-shell -b "'$bin' up"
