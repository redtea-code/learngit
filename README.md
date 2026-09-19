# Portable Codex Skills

This repository contains a portable snapshot of the personal Codex skills installed on one machine.
The skills live under [`skills/`](skills/). The original demo files in this repository are preserved.

## Install

### Windows PowerShell

```powershell
git clone https://github.com/redtea-code/learngit.git
cd learngit
.\install.ps1
```

Install into a different Codex home, or select specific skills:

```powershell
.\install.ps1 -Destination "$HOME\.codex" -SkillNames ppt-master,paper2poster
```

The default destination is `$env:CODEX_HOME` when set, otherwise `$HOME\.codex`.

### macOS/Linux

```bash
git clone https://github.com/redtea-code/learngit.git
cd learngit
./install.sh
```

Set `CODEX_HOME` to install elsewhere. Both installers copy into `<CODEX_HOME>/skills/<skill-name>` and refuse to overwrite an existing skill unless an explicit force flag is supplied.

## Included skills

The snapshot currently includes these 17 personal skills:

- `academic-poster-builder`
- `dataflow-model-explainer`
- `experiment-plan`
- `experiment-submap-builder`
- `idea_spark`
- `local-gpt-image2`
- `optimization-reading-group`
- `paper_search`
- `paper-poster-imagegen`
- `paper2assets`
- `paper2blog`
- `paper2poster`
- `paper2poster-poster`
- `paper2reel`
- `paper2video`
- `ppt-master`
- `scoop_check`

Only personal skills from `~/.codex/skills` were packaged. Codex internal skills (`.system`) and agent-bundled skills (`~/.agents/skills`) are intentionally excluded. Python bytecode, `__pycache__`, logs, and generated validation reports are also excluded because they are machine-specific or reproducible.

## Configuration and dependencies

Skills may require external runtimes or packages documented in their own `SKILL.md` and reference files. API keys are not included. Configure provider credentials through process environment variables or a local ignored `.env` file after installation; never commit secrets.

The snapshot preserves each skill's own license and attribution files. Where a bundled skill comes from an upstream project, follow that project's license and attribution requirements.
