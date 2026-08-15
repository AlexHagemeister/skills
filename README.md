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

A skill is a folder. Installing means getting that folder to where your agent looks for skills. There are five ways to do that. Pick by what you use:

| You use | Do this | Updates |
|---|---|---|
| Claude Code in the desktop app, no terminal | [Plugin, from the app](#plugin-from-the-app) | one pasted sentence when you want them |
| Claude Code, and a terminal is fine | [Plugin, from a terminal](#plugin-from-a-terminal) | automatic once you turn it on |
| Cursor, Codex, or another agent that reads skills | [Skills CLI](#skills-cli) | one command when you want them |
| Claude on the web or your phone, no Claude Code | [Upload to your Claude account](#upload-to-your-claude-account) | re-upload |
| Any of the above, and you want to see the files first | [By hand](#by-hand) | re-copy |

If you are not sure which agent you have: Claude Code is the one that runs in a terminal or in the Code tab of the Claude desktop app. Claude on the web (claude.ai) and the phone app are not Claude Code.

### Plugin, from the app

For the Claude desktop app, no terminal needed. One plugin, `ah`, holds every skill in this repo and picks up new ones as they land.

1. Open the Code tab and start a session in any folder.
2. Paste this into the prompt and send it:

   ```
   Run these two shell commands for me, then tell me when they finish:
   claude plugin marketplace add AlexHagemeister/skills
   claude plugin install ah@alexhagemeister
   ```

3. Start a new session. The skills answer to `/ah:moot`, `/ah:align`, `/ah:yes-and`, `/ah:orchestrator`.

To see what is installed later, click the **+** button next to the prompt box and choose **Plugins**. To get the latest changes, paste `Run claude plugin update ah for me` into any session. If you also use Claude Code in a terminal, you can turn on auto-update instead (next section) and skip that step forever.

### Plugin, from a terminal

Same plugin, two commands. Works in any terminal where `claude` runs:

```bash
claude plugin marketplace add AlexHagemeister/skills
claude plugin install ah@alexhagemeister
```

Then, inside a terminal Claude Code session, run `/plugin`, go to **Marketplaces**, pick `alexhagemeister`, and turn on auto-update. It is off by default for every marketplace that is not Anthropic's own. With it on, anything I push arrives on your next launch. If you would rather not, `claude plugin update ah` pulls the latest whenever you like.

If you are already inside a terminal session, the same two install steps work as slash commands: `/plugin marketplace add AlexHagemeister/skills`, then `/plugin install ah@alexhagemeister`.

### Skills CLI

For any agent the [skills CLI](https://github.com/vercel-labs/skills) supports, including Cursor, Codex, Gemini CLI, and Claude Code. Needs [Node.js](https://nodejs.org/) so `npx` works. Installs one skill for one agent, globally:

```bash
npx skills add AlexHagemeister/skills --skill moot -g -a claude-code
```

Swap `moot` for the skill you want, or `'*'` for all of them. Swap `claude-code` for your agent's name (`cursor`, `codex`, and so on). Add `--list` to see what is available. Later, `npx skills update -g` pulls whatever changed. Skills installed this way answer to their plain names: `/moot`, `/align`.

### Upload to your Claude account

For Claude on the web or the phone app. Account skills are zip files you upload once, and they follow you to every device.

1. On this page, click the green **Code** button, then **Download ZIP**. Unzip it.
2. Inside, open the `skills` folder and find the skill you want (for example `align`). Compress that one folder into its own zip.
3. In Claude, go to Settings, then Capabilities, then Skills, and upload the zip.

To get changes later, repeat the three steps. This path does not update itself.

One limit: `moot` and `orchestrator` work by launching subagents, which chat on the web and phone cannot do. Upload `align` and `yes-and` there. Use the other two in Claude Code.

### By hand

Download the ZIP as above, or clone the repo. Copy the skill folder you want into your agent's skills directory: `~/.claude/skills/` for Claude Code, `~/.agents/skills/` for most others. Start a new session and the skill is live. To update, copy it again.

You can also skip all of this and hand the job to your agent: give it the link to a skill's `SKILL.md` and ask it to install the skill. It reads the file and knows where the folder goes.

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
