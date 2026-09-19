# Experiment Submap Examples

## Results table with complete metrics

```markdown
### Target 结果表（subject-level，ADNI→NACC，seeds=42,43,44）

| Variant | ACC | AUROC | BA | Macro-F1 | Sensitivity | ΔAUROC vs source-only |
|---|---:|---:|---:|---:|---:|---:|
| `source_only` (baseline) | 0.6603 ± 0.0457 | 0.7362 ± 0.0131 | 0.6763 ± 0.0281 | 0.6467 ± 0.0386 | 0.7216 ± 0.0359 | — |
| `uda` | 0.7085 ± 0.0478 | 0.7311 ± 0.0172 | 0.6515 ± 0.0487 | 0.6443 ± 0.0515 | 0.4902 ± 0.2294 | -0.0051 |
```

The delta is calculated against the same-seed source-only row. The table does
not imply that a higher ACC overrides a lower BA or AUROC.

## Results table with unavailable metrics

```markdown
### Target 结果表（subject-level，seeds=42,43,44）

| Variant | ACC | AUROC | BA | Macro-F1 | Sensitivity | ΔAUROC vs baseline |
|---|---:|---:|---:|---:|---:|---:|
| `baseline` (baseline) | NR | 0.7156 ± 0.0509 | 0.5827 ± 0.0456 | NR | NR | — |
| `variant_a` | NR | 0.7936 ± 0.0225 | 0.6131 ± 0.0166 | NR | NR | +0.0780 |
```

`NR` means that the source result did not report the value. Do not estimate it
from another metric.

## No-real-data result

```markdown
### Target 结果表（真实数据尚未运行；seed=未运行，baseline 对比不可计算）

| Variant | ACC | AUROC | BA | Macro-F1 | Sensitivity | ΔAUROC vs baseline |
|---|---:|---:|---:|---:|---:|---:|
| `control` (baseline) | NR | NR | NR | NR | NR | — |
| `proposed_variant` | NR | NR | NR | NR | NR | NR |
```

Follow the table with the verified interface/test evidence and state that it
does not establish real-data performance.

## Compact variant-diff pattern

```markdown
| Variant | Changed input/branch | Classifier path | Target influence | Question |
|---|---|---|---|---|
| `baseline` | none | unchanged | none | matched control |
| `full_alignment` | target feature branch | unchanged | alignment loss | does target distribution help? |
| `residual_alignment` | frozen residual projector | unchanged | residual-only alignment | does restricting pressure preserve task support? |
```

