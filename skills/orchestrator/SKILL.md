---
name: orchestrator
description: Switch this session into orchestrator mode, where the main loop delegates the big work (builds, reviews, research) to subagents and does only small tasks itself. Use when the user says "orchestrator mode", "/orchestrator", or asks to run the session by delegating to subagents. The mode stays on for the rest of the session until the user turns it off ("orchestrator off", "drop orchestrator mode").
scope: "Owns the orchestrator-mode session directive: entering and leaving the mode, and delegation discipline while it is on (self-contained briefs, request-as-approval authorization judgment, the lane rule, verify-by-evidence, standup reporting, friction notes). Does not own the content of delegated tasks, the harness's permission system, or any project's write rules (a vault's CLAUDE.md still governs its own writes). The size floor for small tasks was added 2026-11-09 from live-trial friction. Promotion decisions (cookbook recipe, vault wiring) live with the user, outside this file."
---

# Orchestrator mode

Session directive. From invocation until the user turns it off, the main loop delegates the big work to subagents. Prefer background agents so the conversation stays free while lanes run.

Delegate the big work: builds, reviews, research, and anything that reads or writes many files. Do small things directly: a single command, a short lookup, one comment, a one-line edit. The test: if writing the brief costs more than doing the task, do the task.

Why: in the pure-form trial, posting one GitHub comment took two agents and about 170k tokens. Alex, 2026-11-09: "orchestrator doesn’t need to be that strict. For things like this it might be better to just have the orchestrator delegate big stuff like builds and reviews, not things like this."

## What stays in the main loop

Only: conversation with the user, writing delegation briefs, verifying completed work, lane scheduling, and small tasks that pass the test above. Everything else is a subagent's job.

## Rules

1. **Briefs are self-contained.** Subagents load both CLAUDE.md files (user-level and project-level) with all their `@` imports, plus the MEMORY.md index. They do not see conversation history or the individual memory files behind that index. They do have the Skill tool: a brief that needs a skill's rules names the skill and tells the agent to invoke it, rather than restating its content (verified by live test 2026-08-19, general-purpose and Explore agent types both). The always-on style rules arrive with the imports, so restating them wastes brief space. Every brief carries the task, exact file paths, constraints, and any authorization quoted verbatim. Subagents run in the same working directory with the same tools and can read anything you can. Carry in the brief only what they cannot recover themselves (conversation-derived decisions, authorization, scope limits). Point at files rather than restating their contents, and let the agent do its own exploration.
2. **Authorization: the user's ask is the approval. You are the judgment layer.** A direct request for specific outputs authorizes exactly those writes. Do not ask again for what the user just asked for, and treat obvious necessary steps (creating the folder a requested file lives in) as covered. Anything beyond the request (side-effect edits, cleanups, index updates, files the user never named or clearly implied) needs the user's yes before any agent touches it. Surface it as an offer, don't do it. Mode-on by itself approves nothing. Scope each brief to only the authorized writes and quote the request or approval in it. Subagents never widen scope on their own. Project rules still bind every subagent. In a vault, delegated writes go through the vault's skills same as direct ones would.
3. **Lane rule (hard).** Never run two concurrent agents whose work touches the same file. Shared surfaces (day logs, indexes, hub pages) are collision magnets, so serialize them into one lane or queue them last.
4. **Verify by evidence, not by report.** After a write lane finishes, read the git diff or the artifact itself before telling the user it is done. Summarize from the evidence, not from the agent's claim.
5. **Report like a standup.** When the user checks in: what is running, what finished and verified, what is blocked waiting on them. Never predict a pending lane's results.
6. **Fleet work goes through the Workflow tool.** When a lane is many items of the same shape (a sweep over N pages, a check per file, a finder-then-verifier chain), write a Workflow script instead of spawning agents one call at a time: `pipeline()` over the item list with one `agent()` per item, a `schema` on each call so results come back typed, `log()` for progress, and a final plain-code reduce. The harness runs it in the background with a live progress tree, caps concurrency, saves the script to a file, and can resume a killed run with cached results. Alex has opted in by asking for a "fleet" or for subagents in bulk; in his words is the gate, so name it back to him ("running this as a workflow") and keep a hand-spawned Agent for one-off lanes. First use: the 2026-08-22 em-dash sweep, 35 batches of 8 pages with a guard per page.
7. **Log friction.** When the mode fights a task, say so briefly and keep going. If the project keeps a friction log or issue tracker, file an entry there too.
8. **Clean up what you created.** When a lane's PR merges or is dropped, remove that lane's worktree and its harness branch before reporting. Why: the orchestrator created them, so the cleanup is its job, not the dev's (Alex, 2026-11-10: "the dev shouldnt have to be remembering to clean up worktrees").
9. **Size the lane to the risk.** Build small changes yourself with a short issue and short PR. Use a subagent builder plus an independent review only when the change is large or can destroy something. Why: full-weight lanes took 30+ minutes for changes that needed 10 (Alex, 2026-11-10: "thats so ling for such a simple change").
10. **Check quiet lanes.** If a lane is quiet for 20 minutes, check that it is alive before reporting it as running. Why: an interrupt in the main chat kills background subagents with no notice, and a dead reviewer was reported as running for 90 minutes (2026-11-10).

## Turning off

The user says so in any words. Confirm the switch and resume normal direct execution. The mode never carries over to other sessions.
