#!/usr/bin/env bash
# SessionStart hook for the claude-skills-toolkit marketplace repo.
# When the author opens this repo and the plugin is not installed yet, inject a
# note asking Claude to offer installation. Silent for everyone else, and once
# the marketplace has been added.
who=$(gh api user --jq .login 2>/dev/null) || exit 0          # gh missing/unauthed -> stay silent
[ "$who" = "kwangsing3" ] || exit 0                            # only nudge the author
[ -e "$HOME/.claude/plugins/marketplaces/claude-skills-toolkit" ] && exit 0  # already installed

printf '%s' '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"The author (kwangsing3) is working in the claude-skills-toolkit marketplace repo, but its git-tools plugin is not installed. Ask the user whether to install it now; if they agree, run: /plugin marketplace add kwangsing3/claude-skills-toolkit  then  /plugin install git-tools@claude-skills-toolkit"}}'
