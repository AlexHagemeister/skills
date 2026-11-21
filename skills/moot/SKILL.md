---
name: moot
description: Convene a moot, a team of independent subagents the orchestrating agent casts for the motion at hand (a problem, a decision, a design to review, a research question, or an open "what am I missing"), runs in parallel, lets argue once, and synthesizes for the user in plain language. Use whenever the user invokes /moot, says "call a moot", "convene the moot", "moot this", asks for second opinions, wants a flagged issue adjudicated, or hands over a question they lack the bandwidth or context to work themselves. Also offer it (never auto-run it) when you have just flagged a non-trivial problem or argued yourself into a position on a design question the user has not yet weighed in on.
---

# Moot

A moot is a team you build for one motion. Each seat owns one question nobody else on the team owns. Seats investigate alone, hand in sealed reports, argue once if they split, and you synthesize for the user. You are the clerk, never a seat.

The name is from the Bobiverse: copies of one mind, drifted by different experience, assembled to argue a question. The seats are that. You are the one who called the moot.

## What it buys, and what it costs

It buys fresh eyes (seats do not see this conversation, so they cannot inherit its frame), a real objection (a seat cast to own the case against argues to win), visible variance (agreement is replication, disagreement is the map of the decision), and parallel depth. It costs five to ten times a solo answer and several minutes. The record says it beats a solo answer on judgment questions with a real tradeoff and on catching factual errors by cross-comparison, and merely replicates elsewhere. Every run measures this (see Sealed solo answer).

**Do not call a moot for:** a factual lookup, a question with an obvious answer, or a question whose substance is this conversation (what the user meant, what was already tried). Seats do not have the conversation and will do worse than you.

## The flow

1. **Frame.** If the motion is ambiguous, offer the user two or three one-line framings and take their pick. This is the only question you ask before the report.
2. **Seal your solo answer.** Write to the scratchpad, before casting: the motion kind, your own recommendation as if no moot were available (a real answer, not a one-liner), and a predicted verdict per seat once cast. File `moot-<slug>-sealed.md`.
3. **Cast** (below). Announce the cast to the user: one line per seat, its question, its kind, its model.
4. **Dispatch all seats in one message**, in parallel. Foreground them (`run_in_background: false`) unless the session is interactive and you will keep the turn alive until every report is in. Never end a turn with seats outstanding: the caller cannot tell unfinished from failed.
5. **Check facts, run falsifiers.** Two seats stating incompatible checkable facts is an error with a cheap test. Run it yourself (a grep, a git log, a stat). Never pass a known contradiction through.
6. **Rebuttal round, only on a split.** Skip it when the first round agrees, and say you skipped it. Otherwise continue each seat that is party to a named conflict (SendMessage to its id) with the other seats' relevant findings and ask for one paragraph per item: HOLD, MOVE, or CONCEDE, with the reason, then a one-line position. One round, no more. All messages go through you. No direct seat-to-seat sends: the reply routes to you anyway and re-bills both ends.
7. **Score the seal.** Compare seat verdicts to your predictions and the synthesis to your solo answer. Record the outcome (see Sealed solo answer).
8. **Synthesize and report** (below).
9. **Do not act.** The moot advises. Edits, fixes, and follow-up dispatches wait for the user's word.

## Building the cast

The seat is the unit, and a seat is a question owned. Before dispatch, write one line per seat: the question it owns, and the one finding it could return that no other seat could and that you would not. If you cannot write that line, the seat is an echo. Cut it or change its question.

**Three ways to make a seat answer differently.** Use at least two across any cast of three or more.
- Disposition: a way of thinking, briefed in its own voice. The bench personas are this kind.
- Research task: a slice of the territory it alone reads deeply.
- Context slice: what it is given and what it is denied. A seat that has not read your investigation is the only seat that can catch what your reading hid from you. Every subagent already carries both CLAUDE.md files and their imports, so a slice adds to that floor and never goes below it.

Two seats with the same reading list and the same brief are one seat with variance.

**Size.** One seat per question you can name, and stop when you run out of questions. Two suffice for a checkable fact (one reproduces, one doubts the statement). Three or four for a judgment motion. Five is the ceiling.

**Standing seats, every cast:**
- One seat owns doubting the statement as written: is this real, is it what the reporter thinks it is.
- One seat owns "what would have to be true for the reporter's hypothesis (or your sealed lean) to be wrong." Cast it by question, never by conclusion. A seat briefed to argue a side produces a case, and the clerk cannot weigh a case.
- When you have already investigated, one seat gets the motion and the territory and none of your findings.

**The bench.** The persona files in `personas/` are ready seats: Empiricist (is it real), Pathologist (what produces it), Field Medic (what is it worth), Prodigy (what would make this easy), and Harness Engineer (what the tools this depends on mechanically do, promoted 2026-09-28 on its third run). Draw one whenever a seat's question matches its question. For a problem motion, draw the first four: that cast is the only one with a run record. Add the Harness Engineer when the motion rests on tool or harness behavior. A bench persona is pasted verbatim, never paraphrased or trimmed.

**Free seats.** Any seat you write from scratch is saved to `personas/drafts/<YYYY-MM-DD>-<slug>.md` in the same form as a bench file (question owned above the line, briefing below it, in the seat's voice) and named in the report's closing line. A free seat whose question recurs three times moves to `personas/` and joins the bench. That is how the roster grows: from evidence, never by decree.

**Default casts by motion kind.** Starting points, edited per motion.
- Problem (something is wrong): the bench.
- Decision (choose between options): one seat per live option owning "what has to be true for this to be the right pick," one owning what happens if nothing is chosen, one owning reversibility and the cost of being wrong.
- Design review: one seat per audience the design serves or harms, one owning the simplest thing that does the job (the Prodigy).
- Research fan-out: seats by territory slice, plus one that reads none of the sources and answers cold, so the synthesis shows what the reading changed.
- Open scan (what am I missing): seats by lens, capped at four, one owning "what here is fine as it stands."

**Writing a free seat's brief.** Under ten lines of briefing: the question owned, one or two sentences of disposition in that seat's voice, what it reads and what it is denied. Voice over rule lists: a seat briefed as a person behaves like one, a seat briefed as a checklist behaves like a form. Test: strip the seat's name and see whether the brief still identifies it.

## The brief

Identical for every seat, appended after the seat's briefing:

- **The motion, verbatim.** As the user or flagging agent stated it, quoted. Do not sharpen it.
- **The reporter's hypothesis, labeled.** Any guess at cause, fix, or answer from whoever raised the motion, marked "a hypothesis, not a finding." Your own view goes here too, under the same label, or nowhere.
- **Pointers, not conclusions.** Paths, output, where the symptom was seen.
- **Territory and bounds.** Usually the whole repo or vault, read-only. Name a scratch prefix per seat (`<seat>-`) and forbid writes elsewhere. Say that a sibling's scratch file looks like a "modified since read" error, not tampering.
- **Anything from this conversation the seat needs.** Seats inherit both CLAUDE.md files, their imports, and the memory index. They do not inherit the conversation, chat approvals, pointed-at files, or skill bodies (they can invoke a skill by name if told to).
- **The return contract** for the motion kind.
- **Register:** plain, no em dashes, no semicolons joining clauses.

## Return contracts

Voice belongs to the seat. The structure does not bend. The verdict or position vocabulary is chosen once per motion, never per seat. The one kind-specific field may differ by seat when seats own different questions (an option advocate returns CONDITIONS, a nothing-chosen seat returns WHAT HAPPENS IF NOTHING IS CHOSEN, a reversibility seat returns OPTIONS RANKED).

**Problem motions:**
```
VERDICT: real-as-stated | misframed (say what it actually is) | elsewhere (say where) | not-a-problem (say why it looked like one)
EVIDENCE: what you observed or reproduced, with paths. Verified vs inferred.
REASONING: in your own voice.
RECOMMENDATION: only if the verdict warrants one, with cost and blast radius. "No action" is complete.
CONFIDENCE: low / medium / high, and the one thing that would change your mind.
```

**Every other kind:**
```
POSITION: one or two sentences.
EVIDENCE: what you read, ran, or counted, with paths. Verified vs inferred.
CASE AGAINST YOUR OWN POSITION: the strongest honest version.
[kind-specific field, named per seat's question: CONDITIONS or OPTIONS RANKED or WHAT HAPPENS IF NOTHING IS CHOSEN for a decision, DRAFT for a design review, FINDINGS numbered for research, WHAT IS MISSING for an open scan]
WHAT WOULD CHANGE MY MIND: the one thing.
CONFIDENCE: low / medium / high.
```

## Running seats in Claude Code

Measured facts, re-probe before building on any one of them.

- A seat is addressed by the agentId from its spawn result. SendMessage to that id resumes it with its full context intact.
- Every continuation re-bills the seat's whole context, which starts large before the seat reads anything (every CLAUDE.md file and import loads first). Budget one rebuttal round, never more.
- Seat replies arrive as task notifications to you, whoever sent the message. Direct seat-to-seat sends work but are not worth it.
- Seats run background by default and can spawn their own children (a seat may run a probe).
- Model: inherit the session model unless the user has set a rule.
- No shared floor file. Each seat writes with its own prefix or returns text only.
- The Workflow tool fits a dispatch-and-collect phase with many same-shape lanes. It cannot hold the rebuttal round.
- If `TUNING.md` exists next to this file, read it before casting. It can hold notes about this user's setup that override the defaults above.

## Synthesis

You are the clerk of the court, not a fifth juror.

- **Unanimity needs no deciding.** Agreement across decorrelated seats is replication. Report it short.
- **Factual conflicts get checked, not weighed.** Run the check, report who was right.
- **Runnable falsifiers get run.** When a conflict hangs on a falsifier that costs a command, run it and fold the result in.
- **What survives is a judgment call** (values, timing, risk appetite). Those belong to the user. Do not resolve them, and do not add a judge agent: that reintroduces the single-sample problem one layer up.
- **Never average.** A blended "on balance, the council suggests" erases the variance the moot exists to expose.
- The best answer is usually a composition: each seat's answer to its own question, minus anything refuted.

## Reporting to the user

The seats write for you. You write for the user, who called the moot because they lack the time or context to dig in.

- Plain words, short sentences, roughly a sixth-grade reading level. A technical term earns its place only when nothing plain exists, and gets a one-line gloss on first use.
- Open with two or three lines: what was asked, what the team found, what you recommend. This must survive being the only thing read.
- Then one composed recommendation with a default, saying what would concretely be done. "Nothing" is a complete answer. "This isn't a problem" and "the problem is elsewhere" are findings, never caveats.
- Then a block headed **Your calls**, numbered. One call per item: the disagreement in plain words, the default you would take, and what happens if the user does nothing. Only calls that survived checking belong here. Name the thing the call is about as if the reader had not read the report: never a bare label like "item 3" or a pointer back to an earlier line. Three logged instances of this failing moved it here as a rule.
- If a rebuttal round ran, the user sees who moved and why, one line per call, never the exchange itself.
- Below that, the detail: one row per seat (what it argued, key evidence, cost), inline links, exact paths. Skimmable, never required.
- The spine (summary, recommendation, your calls) fits one screen, about 250 words.
- Close with one line naming the team you built and why. Add the tag "all seats echoed my sealed lean" only when that happened: it is the one case where the recommendation deserves distrust, and the user should see it.
- Ask before, not during. Once the moot runs, run it to completion and bring back answers.

## Sealed solo answer: the running benchmark

Every run compares the moot to the answer you would have given alone. After synthesis, classify the run as one of three and log it in the tuning log (one dated line, kind and outcome, no run detail):

1. **Matched.** The moot's recommendation matched your sealed solo answer. Expensive confirmation. A pattern of these on one motion kind means stop mooting that kind.
2. **Differed, moot preferred.** The user took the moot's answer over yours. The win. Note the motion kind.
3. **Differed, solo preferred.** The user took your solo answer. A loss. Look at the cast or the synthesis.

Outcome 2 or 3 needs the user's reaction, so log the difference at run time and the preference when it arrives.

## Calibration

This skill is expected to be wrong in places and to tune with use. Gaps are this file's debt, not the user's error.

- The tuning log lives in `TUNING.md` next to this file. Create it with the first entry. It is this user's record, not part of the skill: never copy it into this file. It takes an entry when the user reacts in words (a correction, an override, a stated preference, a "that was useful because"), and one line per run for the sealed-answer outcome. Never log your own read of a run's quality.
- An entry is one dated line: what happened or what was said (verbatim or not called a quote), and what changed in this file, or "noted, no change."
- A single reaction edits the log, not the rules. A reaction that repeats (about three times) moves into the body as a rule, and its log lines collapse to one summary.
- A month with no moot is itself an entry: note it and ask the user once, in one line, whether the skill is the reason.
- Past about ten entries, compact: fold the lessons into the rules and keep one dated summary line.
- **Reassess point:** after ten logged runs, the sealed-answer tally decides what changes.
