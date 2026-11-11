---
name: multi-model-orchestration
description: Use when a workflow should split work across different models by step, usually via sub-agents or delegated tasks. Best for tasks where cheap/fast steps and high-quality reasoning steps should use different models. Teaches how to structure main-agent, sub-agent, and tool-driven flows with explicit model choices.
---

# Multi-Model Orchestration

Use this skill when one workflow should intentionally use different models for different stages.

## Core rule

Do not assume SKILL.md itself switches models.
Model selection happens when you delegate work through a mechanism that supports model override, such as a sub-agent/task runner that accepts a model parameter.

## When to use multi-model orchestration

Use it when the workflow has clearly different step types, for example:

- cheap classification first, expensive synthesis later
- broad scraping first, deep reasoning later
- repetitive formatting first, careful final writing later
- automation steps on default model, analysis steps on stronger model

## Default pattern

Split work into 3 lanes:

1. **Main agent lane**

- Owns user context
- Decides routing
- Calls tools
- Verifies outputs
- Writes final answer

2. **Fast/cheap lane**

- Use a lower-cost or default model
- Best for:
  - triage
  - extraction
  - cleanup
  - simple transforms
  - repetitive batch steps

3. **Strong reasoning lane**

- Use a stronger model such as `sonnet`
- Best for:
  - planning
  - synthesis
  - ambiguous decisions
  - writing high-stakes output
  - strategy or ranking

## Recommended decision framework

Before delegating, classify each step by:

- **cost sensitivity**: low / medium / high
- **reasoning depth**: shallow / medium / deep
- **risk of mistakes**: low / medium / high
- **need for user-context continuity**: low / high

Then route:

- shallow + low risk → default or cheaper model
- deep reasoning or high stakes → stronger model
- actions touching user context / external side effects → main agent supervises

## Reusable orchestration skeleton

### Pattern A: Main agent routes to one stronger sub-agent

Use when only one phase needs a better model.

Example:

1. Main agent gathers inputs.
2. Main agent delegates planning/synthesis to sub-agent with `sonnet`.
3. Main agent executes tools and returns final result.

### Pattern B: Fan-out + synthesis

Use when many items need light processing, then one final synthesis step.

Example:

1. Main agent splits items.
2. Fast lane processes each item.
3. Strong lane synthesizes results.
4. Main agent verifies and responds.

### Pattern C: Automation + judgment

Use when browser/tool work is deterministic but interpretation is not.

Example:

1. Main agent performs browser automation and data capture.
2. Strong lane analyzes the captured data.
3. Main agent applies the analysis back into tools or final response.

## Suggested wording inside a skill

When authoring another skill, use language like this:

- `Use the default model for browser automation and stateful page interaction.`
- `If a reasoning-heavy ranking/synthesis step is needed, spawn a sub-agent with model alias sonnet.`
- `Keep final user-facing judgment in the main agent unless the delegated task is purely analytical.`

## Template snippets

### Snippet: route by step type

```markdown
If the step is mostly extraction, formatting, or bulk processing, keep it on the default model.
If the step requires deep comparison, nuanced judgment, or high-quality writing, delegate to a sub-agent using model alias `sonnet`.
```

### Snippet: supervised delegation

```markdown
Delegate analysis to a stronger model, but keep tool execution, external actions, and final verification in the main agent.
```

### Snippet: batch then synthesize

```markdown
For N similar inputs, do lightweight extraction first. After collecting structured outputs, use a stronger model once to rank or synthesize.
```

## Example mapping

### Example 1: Research workflow

- Search + scrape → default model
- Compare options and rank → `sonnet`
- Final concise recommendation → main agent

### Example 2: Browser automation workflow

- Navigate/click/upload/download → default model
- Interpret messy page results / summarize findings → `sonnet`
- Confirm final files and report status → main agent

### Example 3: Inbox triage workflow

- Message classification → default model
- Sensitive reply drafting → `sonnet`
- Sending / routing → main agent

## Guardrails

- Do not use a stronger model for everything by default.
- Do not delegate actions with external side effects unless supervision is explicit.
- Do not lose track of source-of-truth files, outputs, or user constraints when splitting work.
- Prefer fewer, larger delegations over many tiny ones.
- Record in the parent flow which step used which model if traceability matters.

## Minimal authoring checklist

When adapting this template into a real skill, define:

- which steps stay on the main/default model
- which steps should use a stronger model
- what input/output contract each delegated step must follow
- what the main agent must verify before replying
