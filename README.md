# skills

Agent skills I use every day and have run long enough to trust. Each one is a folder with a `SKILL.md`: a short procedure an agent loads when the task matches. They work with any agent that reads the [Agent Skills](https://agentskills.io) format (Claude Code, Codex, Cursor, and others).

Skills land here after a pilot period in my own setup. What is here is what I actually reach for.

## Skills

| Skill | What it does | Invoke |
|---|---|---|
| [`moot`](skills/moot/) | Convenes four subagents with distinct dispositions (Empiricist, Pathologist, Field Medic, Prodigy) to investigate the same problem independently. You get their verdicts side by side and the disagreement between them, never a blend. | `/moot <problem>` |
| [`align`](skills/align/) | Pins down what you are actually asking before any work starts. The agent echoes its model of the ask in its own words, names contradictions and gaps, and iterates until you both confirm. Then it stops and waits. | `/align` |
| [`yes-and`](skills/yes-and/) | Ideation register. Suspends the default caveats and pushback, builds on the idea, and keeps about three distinct forms of it alive. Drops the mode the moment you ask for rigor. | say "brainstorm", "riff", "what if we" |
| [`orchestrator`](skills/orchestrator/) | Session directive. The main loop delegates every task to subagents and executes nothing itself. Self-contained briefs, one file per lane, verify by evidence. Stays on until you turn it off. | `/orchestrator` |

The [GNADD](https://github.com/AlexHagemeister/gnadd) suite (git-native agent-driven development, nine skills plus a script) lives in its own repo. It has tests and versioned releases and did not fit a folder-per-skill layout.

## Install

Pick whichever fits how you work. Every path ends the same way: a folder in your agent's skills directory.

**Claude Code plugin.** The repo is also a plugin marketplace. One plugin, `ah`, holds every skill here, and it picks up new ones as they land. Inside Claude Code:

```
/plugin marketplace add AlexHagemeister/skills
/plugin install ah@alexhagemeister
```

Skills then answer to `/ah:moot`, `/ah:align`, and so on. To get updates without doing anything, open `/plugin`, go to Marketplaces, pick `alexhagemeister`, and turn on auto-update. It is off by default for every marketplace that is not Anthropic's own. In the desktop app the same controls live in the plugin browser.

**With the skills CLI** (needs Node for `npx`). Works with any agent the CLI supports. Installs one skill, globally, for the agent you name:

```bash
npx skills add AlexHagemeister/skills --skill moot -g -a claude-code
```

Use `--list` to see what is available, `--skill '*'` for all of them, and `npx skills update -g` to pull changes later. Agent names and flags are in the [skills CLI docs](https://github.com/vercel-labs/skills).

**By hand.** Download or clone, then copy the skill folder into your agent's skills directory (`~/.claude/skills/` for Claude Code, `~/.agents/skills/` for most others). Restart the session and the skill is live.

**Point your agent at it.** Give the agent the URL of a `SKILL.md` and ask it to install the skill. It reads the file and knows where the folder goes.

## Layout

```
skills/<name>/SKILL.md      the procedure, with name and description in frontmatter
skills/<name>/...           anything the procedure references (persona files, scripts)
.claude-plugin/             marketplace.json and plugin.json, so Claude Code can install the set as one plugin
scripts/link.sh             author-side: symlink every skill into ~/.claude/skills
scripts/promote.sh          author-side: move a piloted skill in and link it back
```

The scripts are how I work on these. My live skills directory holds symlinks into this repo, so an edit made mid-session is an edit to the repo. A skill I am still piloting lives as a plain folder there. When it earns its place, `promote.sh` moves it in.

## License

[MIT](LICENSE).
