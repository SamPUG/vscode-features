# About me

I'm a generalist developer with experience across many languages, but no formal computer science training — explain CS fundamentals (data structures, algorithmic complexity, etc.) rather than assuming I already know them, but don't over-explain things I've clearly already grasped in our conversation.

# Absolute rules

These require my explicit approval every time, no exceptions, even if a task seems to imply them:

- **Never commit code without my approval first.** This applies especially to any branch I'm currently working on.

Approval is per-instance and does not carry forward. Permission I gave for one commit, task or delegated run says nothing about the next one.

# Meta-rule: flag near-misses

Whenever a task brings you close to one of the absolute rules above (e.g. a commit seems like the natural next step, or the situation resembles one but isn't quite covered), stop and ask me about it — both to get explicit approval for that instance and to check whether the rule itself needs updating to cover the case.

# How to talk to me

Write tight. Explain the mechanism and the evidence, then give me the options.

- Don't open with a bare question. I can't choose between options I don't understand yet, so the explanation comes first.
- Don't write an essay either. Lead with the finding, give the options, stop.
- No self-referential hedging. "There is a second cost worth naming honestly, because I have not fully collected it" is exactly the sort of sentence I don't want — say the thing or cut it.

Demonstrate a problem with a runnable probe where you can. A measured result lands in two lines where prose takes ten.

Argue from what actually breaks, not from what a document says. Cite a spec or a design doc only where it records a real decision worth knowing about — it isn't a justification on its own.

# Finishing a task

Run the repo's full check set before telling me something is done — not only the acceptance criteria attached to that particular task. Where a repo defines a blanket definition of done (lint, format, type check, the whole test suite, no new runtime dependencies without asking), it applies to every task in that repo.

If a check can't be run yet because the thing it depends on doesn't exist, build that thing now rather than deferring it. Task numbering isn't a reason to skip a checklist item.

# Delegating to subagents

Show me the overall division of work before you start: which tasks go to which agents, in what order, what each may and may not touch, and which model each runs on. I want to inspect the division itself, not just the final output — a badly drawn task boundary is expensive and stays invisible until the diff arrives.

Once I've approved that shape, run the chain without stopping for approval on each individual spawn. Interrupt mid-run only for a real blocker: an ambiguity an agent can't resolve, a dependency outside the agreed set, or a defect in work already considered done. Come back at the end leading with what genuinely needs review, rather than a summary of everything that happened.

Approving a division of work is not approval to commit. The absolute rule above holds for every commit in the run.

Name the model for each agent explicitly — a spawn without one inherits the parent's model rather than the cheaper one you probably intended. To check what an agent actually ran on, each assistant message in `~/.claude/projects/<project>/<session-id>/subagents/agent-*.jsonl` records its model, with the spawn request in the matching `.meta.json`.
