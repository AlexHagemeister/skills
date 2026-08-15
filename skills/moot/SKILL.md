---
name: moot
description: Convene a moot, a council of four independent persona subagents (the Empiricist, the Pathologist, the Field Medic, the Prodigy) that investigate a stated problem and return diagnosis-first verdicts, then synthesize the comparison for the user. Use whenever the user invokes /moot, says "call a moot", "convene the moot", asks for second opinions on a problem, wants a flagged issue adjudicated before acting on it, or hands over a problem they lack the bandwidth or context to scrutinize themselves. Works on any problem statement, whether a codebase bug, a vault inconsistency, a design concern, or a process failure. Also offer it (don't auto-run it) when you have just flagged a non-trivial problem and the user seems unsure whether it is real or worth fixing.
---

# Moot

Four subagents investigate the same problem independently, each embodying a distinct problem-solving archetype. They return diagnosis-first verdicts. You compare the verdicts and hand the user the disagreement, not a blend.

## Why this exists

A single agent answering "here's a problem, what do we do?" fails in predictable ways, and each part of this skill's design counters one of them:

- **One sample, read as truth.** A solo answer is one draw from a distribution, delivered in a confident register. The user can't see the variance. Three decorrelated draws make the variance visible: agreement is signal, disagreement is exactly where the user's attention should go.
- **Premise acceptance.** Models tend to take the problem statement as true and start solving. Sometimes the right answer is "this isn't actually a problem" or "the problem is real but lives elsewhere." The return contract makes those first-class verdicts a persona can win with.
- **Action bias.** Models reward themselves for producing a fix. The Field Medic exists to make "do nothing" a respectable, fully-argued position.
- **Correlated blind spots.** Neutral agents sample from the same center of the distribution and miss the same things. The personas start from different corners: one interrogates the evidence, one the mechanism, one the stakes, one the frame itself. The persona is the decorrelation mechanism.
- **Solution-space anchoring.** Models inherit the problem's frame and overbuild inside it: ask for a fix, get machinery. The Prodigy exists to find the assumption everyone accepted without saying it out loud, and to ask whether "just do X" was available the whole time.

## The flow

1. **Assemble the brief** (below).
2. **Dispatch all four personas in parallel**, in a single message, as general-purpose subagents. Each prompt is: the persona briefing pasted verbatim from `personas/<name>.md`, then the brief, then the return contract. Never paraphrase or trim a briefing. The voice is the mechanism, and a summarized persona is a costume, not a disposition.
3. **Synthesize** (below) once all four return.

## The brief

The same brief goes to all four, containing:

- **The problem statement, verbatim.** As the user or flagging agent stated it, quoted. Do not clean it up or sharpen it: the Empiricist's job includes doubting its framing, so hand over the framing intact.
- **The reporter's hypothesis, if one exists, labeled as such.** If whoever flagged the problem also guessed at a cause or fix, include it marked "the reporter's hypothesis, not a finding." Hiding it wastes information; presenting it unlabeled would contaminate the Empiricist.
- **Pointers, not conclusions.** File paths, error output, the issue file, where the symptom was seen. Enough for each agent to start exploring, nothing that pre-digests the investigation.
- **Territory.** What they may explore (usually: the whole repo or vault, read-only) and anything out of bounds.

Do not include your own diagnosis anywhere in the brief except under the reporter's-hypothesis label. If you have already investigated and formed a view, you are the reporter, and your view is a hypothesis like anyone else's.

## The return contract

Identical for all four personas, appended after the persona briefing and brief. Voice belongs to the persona; this structure does not bend:

```
Return your findings in exactly this structure:

VERDICT: one of
  real-as-stated   — the problem is what the statement says it is
  misframed        — something is wrong, but the statement misidentifies it; say what it actually is
  elsewhere        — the symptom is real but the problem lives in a different place; say where
  not-a-problem    — nothing here warrants action; say why it looked like a problem

EVIDENCE: what you actually observed or reproduced, with file paths.
Distinguish what you verified from what you inferred.

REASONING: your analysis, in your own voice.

RECOMMENDATION: only if your verdict warrants one. Include cost and
blast radius (what it touches, what could break, effort to review).
"No action" is a complete recommendation.

CONFIDENCE: low / medium / high, with the one thing that would most
change your mind.
```

## Synthesis

You are the clerk of the court here, not a fourth juror.

- **Plain language, always.** The person reading this report called the council precisely because they lack the bandwidth or context to dig in themselves, so a report in dense technical language defeats the skill's whole purpose. Write at roughly a sixth-grade reading level: short sentences, everyday words. Before any verdict, say in one or two plain sentences what the problem is and why it matters. Every recommendation says what would concretely be done ("move the finished items to the bottom of the page"), not mechanism shorthand. A technical term earns its place only when the thing has no plain name, and then it gets a one-line gloss on first use. The jurors write for you; you translate for the human. Exact paths, commands, and evidence stay in the report, but below the plain-language spine, not woven through it.
- **Lead with the split.** The headline is the verdict pattern: "3/3 say not-a-problem" or "the Empiricist couldn't reproduce it, the other two disagree on where it lives." Agreement earns a short report. Disagreement earns the user's attention, and your job is to name precisely where the verdicts diverge and what evidence would settle it.
- **One row per persona**: verdict, key evidence, recommendation, cost. Table or tight list, skimmable in seconds.
- **Never average.** A blended "on balance, the council suggests..." erases the variance the skill exists to expose. If the verdicts conflict, present the conflict.

### Deciding between verdicts

"Which report wins" is usually the wrong question. The jurors answer different questions (is it real, what produces it, what is it worth, what would make it easy), so the best answer is normally a composition: each juror's answer to its own native question. A conflict needs deciding only where two jurors answer the same question differently, and it resolves cheapest-first:

1. **Unanimity needs no deciding.** Agreement across decorrelated jurors is replication. Report it short and stop.
2. **Factual conflicts get checked, not weighed.** Two jurors stating incompatible checkable facts is an error with a cheap test, not a disagreement. Run the check (a grep, a git log, a stat) and report who was right. Never pass a known contradiction through to the user.
3. **Runnable falsifiers get run.** Each report names the one thing that would change its juror's mind. When a conflict hangs on a falsifier that costs a command or a quick read, run it and fold the result in.
4. **What survives is a judgment call** (values, timing, risk appetite). Those belong to the user by design. Do not resolve them yourself, and do not add a judge agent to resolve them either: that reintroduces the single-sample problem one layer up and launders exactly the disagreement the council exists to expose.

End the report with two things: one composed recommended course (each juror's answer to its own question, minus anything refuted at steps 2–3, labeled as your synthesis), then the irreducible calls, one per bullet, each stating what happens if the user does nothing. The user should receive a single actionable read plus only the disagreements that genuinely need them.

- **Do not act.** The council advises, the user decides. No edits, no fixes, no follow-up dispatches without the user's say-so.

## Extending the roster

The default four cover evidence, mechanism, stakes, and the frame's unexamined assumption. When a problem has a known flavor, the caller may add a persona: any file in `personas/` is dispatchable, and the user can request one by name ("add the security one"). A new persona earns its slot by owning a question the default four don't, and its briefing must be written in its own voice — the test is whether you could identify the persona with the label stripped. Additions beyond a fifth dilute the comparison more than they add coverage.
