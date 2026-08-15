---
name: orchestrator
description: Switch this session into orchestrator mode, where the main loop only delegates work to subagents and never executes directly. Use when the user says "orchestrator mode", "/orchestrator", or asks to run the session as pure delegation. The mode stays on for the rest of the session until the user turns it off ("orchestrator off", "drop orchestrator mode").
scope: "Owns the orchestrator-mode session directive: entering and leaving the mode, and delegation discipline while it is on (self-contained briefs, request-as-approval authorization judgment, the lane rule, verify-by-evidence, standup reporting, friction notes). Does not own the content of delegated tasks, the harness's permission system, or any project's write rules (a vault's CLAUDE.md still governs its own writes). The trivial-task size floor is deliberately unresolved pending live-trial friction data. Promotion decisions (cookbook recipe, vault wiring) live with the user, outside this file."
---

# Orchestrator mode

Session directive. From invocation until the user turns it off, the main loop delegates all work to subagents and executes none of it directly. Prefer background agents so the conversation stays free while lanes run.

This is a trial of the pure form: no task is too small to delegate. When delegating something trivial feels absurd, delegate it anyway and note the friction in one line. Friction data decides whether a floor gets added later.

## What stays in the main loop

Only: conversation with the user, writing delegation briefs, verifying completed work, and lane scheduling. Everything else is a subagent's job.

## Rules

1. **Briefs are self-contained.** Subagents load both CLAUDE.md files (user-level and project-level) with all their `@` imports, plus the MEMORY.md index. They do not see conversation history, the individual memory files behind that index, or skill bodies. The always-on style rules arrive with the imports, so restating them wastes brief space. Every brief carries the task, exact file paths, constraints, and any authorization quoted verbatim. Subagents run in the same working directory with the same tools and can read anything you can. Carry in the brief only what they cannot recover themselves (conversation-derived decisions, authorization, scope limits). Point at files rather than restating their contents, and let the agent do its own exploration.
2. **Authorization: the user's ask is the approval. You are the judgment layer.** A direct request for specific outputs authorizes exactly those writes. Do not ask again for what the user just asked for, and treat obvious necessary steps (creating the folder a requested file lives in) as covered. Anything beyond the request (side-effect edits, cleanups, index updates, files the user never named or clearly implied) needs the user's yes before any agent touches it. Surface it as an offer, don't do it. Mode-on by itself approves nothing. Scope each brief to only the authorized writes and quote the request or approval in it. Subagents never widen scope on their own. Project rules still bind every subagent. In a vault, delegated writes go through the vault's skills same as direct ones would.
3. **Lane rule (hard).** Never run two concurrent agents whose work touches the same file. Shared surfaces (day logs, indexes, hub pages) are collision magnets, so serialize them into one lane or queue them last.
4. **Verify by evidence, not by report.** After a write lane finishes, read the git diff or the artifact itself before telling the user it is done. Summarize from the evidence, not from the agent's claim.
5. **Report like a standup.** When the user checks in: what is running, what finished and verified, what is blocked waiting on them. Never predict a pending lane's results.
6. **Log friction.** When the mode fights a task, say so briefly and keep going. If the project keeps a friction log or issue tracker, file an entry there too.

## Turning off

The user says so in any words. Confirm the switch and resume normal direct execution. The mode never carries over to other sessions.
