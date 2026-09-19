---
name: local-gpt-image2
description: Configure a third-party OpenAI-compatible image provider for the system imagegen skill when the request mentions the local gpt-image2 configuration or local image generation.
metadata:
  short-description: Configure the local imagegen provider
---

# Local Image Provider

This skill is an environment adapter only. It does not own prompt writing, image composition, model selection, chart construction, output naming, or visual QA. Load it alongside the system `imagegen` skill when the user wants the system image workflow to use a third-party OpenAI-compatible endpoint. Do not ask the user to repeat the configuration path when a usable `gen_config` folder exists.

## Local configuration

Put a folder named `gen_config` in the workspace, next to this skill, or under the user's Codex home. It should contain:

- `config-gpt-image2.toml`
- `auth-gpt-image2.json`

The provider adapter searches these locations in order: an explicitly supplied `-ConfigDir`, `<current-workspace>\gen_config`, `<skill-root>\gen_config`, `<CODEX_HOME>\gen_config`, and `<USERPROFILE>\.codex\gen_config`. It finds the active Codex home from `CODEX_HOME` or `USERPROFILE`, so the skill does not depend on a particular Windows username or a Chinese directory name.

Use `scripts/configure_gpt_image2.ps1` to load the first matching `gen_config` folder without printing the API key. It derives the OpenAI-compatible `/v1` endpoint and sets process-local `OPENAI_API_KEY` and `OPENAI_BASE_URL`.

Run the configure script in the same shell/process that will run the system `imagegen` CLI. In PowerShell, dot-source it before invoking `image_gen.py`:

```powershell
. 'path\to\local-gpt-image2\scripts\configure_gpt_image2.ps1'
python 'path\to\image_gen.py' generate --model gpt-image-2 --prompt '...'
```

## Operating rules

1. Keep the key process-local. Never print it, put it in a prompt, commit it, or include it in a user-facing response.
2. Treat the configured endpoint as a third-party OpenAI-compatible relay. Do not claim it is the official OpenAI endpoint.
3. Keep prompt, model, size, quality, output path, and image QA under the system `imagegen` skill or the user's explicit request.
4. Use the CLI/API imagegen path for this provider adapter. The built-in image tool may not honor a custom `OPENAI_BASE_URL`.
5. Do not silently change the requested image model. If the endpoint or SDK rejects the model, report the failure.

When the configuration folder is not in one of the automatic locations, dot-source `configure_gpt_image2.ps1 -ConfigDir 'path\\to\\gen_config'` before invoking `imagegen`.
