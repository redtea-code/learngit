---
name: experiment-submap-builder
description: Build implementation-grounded experiment submaps for research master maps, including model inputs/outputs, data flow, modules, concrete implementation, and seed-aware result tables with baseline deltas. Use when the user asks for 副地图、实验变体地图、研究主地图拆分、模型变体对比, or an experiment architecture summary.
---

# Experiment Submap Builder

## Purpose

Turn a research master map and its experiment records into concise, traceable
submaps. Each submap describes one experiment family and its registered model
variants. Treat code, protocol documents, and result records as separate
evidence layers; never fill missing results from intuition.

## Scope and storage

- For a repository-level request, write submaps under the repository's existing
  map directory, normally `1.MAP/`.
- Preserve the user's main map. Add a separate index such as
  `DUALSHIFT_SUBMAP_INDEX_YYYY-MM-DD.md` rather than rewriting the main map.
- Use repository-relative links in generated documents. Do not put personal
  machine paths into experiment contracts.
- Preserve unrelated files and existing worktree changes.

## Required discovery

Before writing, locate in parallel where possible:

1. the master map and any existing map index;
2. experiment plans, result records, ledgers, and reports;
3. model constructors, `forward` methods, losses, loaders, selectors, and
   variant registries;
4. actual metrics, predictions, checkpoints, manifests, and audit artifacts.

Use `rg`/`rg --files` first. Treat a document saying that a branch is
implemented as a lead, not proof: verify the source and artifact inventory.

## Evidence classification

For every experiment and variant, label the evidence as one of:

- `implemented`: code path is present and interface checks pass;
- `screening`: real or synthetic screening exists but budget or diagnostics
  limit the claim;
- `exploratory`: target result exists on an internal or previously exposed
  holdout;
- `formal`: protocol and required artifacts meet the project's formal gate;
- `proposed`/`code ready`: design or tests exist but no real-data result;
- `blocked`/`inconclusive`/`no-go`: the source result explicitly says so.

Do not merge non-poolable artifact generations, directions, protocols, or seed
sets. Keep historical numbers historical; do not relabel them as evidence for
a newer method.

## Canonical submap structure

Create exactly these five major sections, in this order:

```markdown
# [Experiment ID] 副地图：[short family name]

## 1. 模型输入与输出
## 2. 模型的数据流
## 3. 涉及的模块
## 4. 每个模块的具体实现
## 5. 实验结果与分析
```

### 1. Model inputs and outputs

State the input contract for source training, unlabeled target adaptation, and
final target evaluation separately. Include MRI geometry, table fields,
missingness fields, labels, domain/environment metadata, and whether each is
actually consumed. State the classifier output and important auxiliary outputs
(attention, discriminator, relation, transport, or audit values).

Use explicit tensor notation when code supports it, for example
`[B,1,D,H,W]`, `[B,C,D',H',W']`, `[B,F]`, and `[B,K]`. If a shape is not
verified, say that it is configuration-dependent.

### 2. Model data flow

Give an ordered flow diagram or code block. Separate:

- inference/classification path;
- source-supervised training path;
- unlabeled target adaptation path;
- augmentation or synthetic-control path;
- diagnostic-only path.

For UDA, explicitly audit `S_train`, `S_val`, `S_test`, `T_adapt`, and
`T_test`. State checkpoint selector and target-label access. Trace gradients:
CE updates the task path normally; GRL reverses encoder gradients; CORAL/MMD,
relation, consistency, identity, and proximal losses connect only the tensors
they actually receive. A computed tensor that only reaches logging is not an
optimization path.

### 3. Modules

Use a compact table with at least `module` and `role`. Include the backbone,
conditioning/fusion, adaptation operator, losses, classifier, loaders/selectors,
and negative controls. Name a module from its implementation, not only from a
variant label.

### 4. Concrete implementation

For each module or variant, record:

- repository-relative code entry point;
- constructor and forward behavior;
- changed input or representation;
- shape/capacity change, if any;
- training-only loss or gradient path;
- inference behavior;
- scientific question tested.

Describe each variant as a diff from a named baseline. State identity behavior,
bounded strengths, frozen projectors/checkpoints, and target access whenever
they matter. Compare the plan/report with code and flag mismatches explicitly.

### 5. Results and analysis

Every submap with results must include a Markdown table containing these five
common classification metrics:

1. `ACC`;
2. `AUROC` (or `AUC`, but use one spelling consistently within the table);
3. `BA`;
4. `Macro-F1`;
5. `Sensitivity`.

Add one comparison column: preferably `ΔAUROC vs [baseline]`; use `ΔACC` only
when AUC is unavailable and ACC is reported. The delta must compare each
variant with the named baseline under the same direction, protocol, split,
checkpoint rule, and seed set.

The table heading must identify the seeds, for example:

```markdown
### Target 结果表（subject-level，ADNI→NACC，seeds=42,43,44）
```

If there are multiple directions, presets, or non-poolable artifact
generations, use separate tables with separate headings. Never average them
silently. If no real-data run exists, write `seed=未运行` and include a table
whose metric values and deltas are `NR` (not reported/not run).

Use `NR` when the source report does not provide a metric. Never infer ACC from
BA, infer sensitivity from AUROC, or reconstruct a missing metric from rounded
values. For seed-level values, compute paired deltas before rounding. If only
aggregate means are available, calculate the aggregate difference and label it
as an aggregate difference rather than a paired-seed estimate.

After the table, explain directionality, variability, class-collapse or
sensitivity/specificity trade-offs, and evidence status. Do not turn a higher
AUROC into a method promotion when the registered primary endpoint is BA, and
do not turn a discrepancy reduction into a task success claim.

## Baseline and protocol rules

- Name one baseline per comparison table and mark its row `(baseline)`.
- For image/table studies, distinguish MRI-only, table-only, matched
  source-only, and UDA variants.
- For strict multimodal UDA, keep target labels, predictions, metrics, and
  model rankings out of adaptation and checkpoint selection.
- Keep `T_adapt` and `T_test` subject-disjoint. Target covariates used only in
  final inference are not the same as covariates used in adaptation; say which
  occurred.
- Keep `ADNI_to_NACC` and `NACC_to_ADNI` separate when the source cohort or
  protocol differs.
- Mark internal or historically exposed target holdouts as exploratory, even
  when several seeds were run.
- Do not claim scanner, manufacturer, field-strength, biological, or causal
  correction from a module name, domain loss, discriminator accuracy, or one
  target metric.

## Index requirements

Create or update an index with one row per experiment containing:

- experiment ID and linked submap;
- variant coverage;
- seed/direction scope;
- current evidence status;
- source plan/result links.

Add a short note defining the five metrics, `NR`, and the delta convention so
that the tables are self-describing.

## Verification checklist

Before finishing:

- [ ] All submaps contain the five required headings in order.
- [ ] Every result table has ACC, AUROC/AUC, BA, Macro-F1, and Sensitivity.
- [ ] Every multi-seed table heading lists the exact seeds.
- [ ] Every variant is compared with a named baseline using `ΔAUROC` or
      `ΔACC`, or is explicitly marked not computable.
- [ ] Missing metrics are `NR`, not guessed.
- [ ] Direction, protocol, split, selector, and artifact generations are not
      silently pooled.
- [ ] Target-label and target-metric access is stated separately for
      adaptation, selection, and final evaluation.
- [ ] Source links resolve and no personal absolute paths were introduced.
- [ ] Claims match the strongest verified evidence status.
- [ ] Run a final heading/table/link check and inspect the diff for unrelated
      edits.

