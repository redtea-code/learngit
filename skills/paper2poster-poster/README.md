# Paper2Poster Skill Pack

This folder contains a lightweight, repo-local skill for turning a paper into a poster package that Claude or Codex can execute consistently.

## Included files

- `paper2poster-poster/SKILL.md`: the actual reusable skill
- `paper2poster-poster/agents/openai.yaml`: Codex UI metadata for easier invocation
- `paper2poster-poster/references/inputs-and-deliverables.md`: what to collect and what to produce
- `paper2poster-poster/references/poster-defaults.md`: default poster heuristics and layout rules
- `paper2poster-poster/references/example-prompts.md`: copy-paste prompts for Codex and Claude

## Codex usage

If your Codex environment supports local skills, invoke:

```text
Use $paper2poster-poster to turn this paper into a conference poster package.
```

Good follow-up constraints to add:

- target venue and audience
- poster size, such as `48x36 inches`
- tone, such as `technical but scannable`
- whether you want only poster copy or also a Paper2Poster run command
- whether logos, QR codes, or sponsor branding should be included

Example:

```text
Use $paper2poster-poster to turn `paper.pdf` into a NeurIPS-style 48x36 poster package. Create poster copy, a layout brief, a Paper2Poster run command, and a draft `poster.yaml`. Keep text concise and emphasize the main quantitative results.
```

## Claude usage

1. Give Claude the paper pdf.
2. Paste one of the prompts from `paper2poster-poster/references/example-prompts.md`.
3. If needed, also paste key constraints from `paper2poster-poster/references/inputs-and-deliverables.md`.

Suggested Claude starter prompt:

```text
You are preparing a research poster from a paper. Follow the workflow and output structure described in the local skill files under `skills/paper2poster-poster/`. Produce a poster brief, poster copy, layout plan, and a Paper2Poster-ready runbook. Do not invent claims that are not supported by the source paper.
```

## Typical outputs

When used well, this skill should help the agent produce some or all of:

- `poster_brief.md`
- `poster_copy.md`
- `poster_layout.md`
- `poster_runbook.md`
- `poster.yaml`

## Notes

- The skill is grounded in the upstream Paper2Poster workflow and command structure from the project README.
- It is intentionally small: the core instructions live in `SKILL.md`, while longer examples stay in `references/`.
