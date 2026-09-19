---
name: dataflow-model-explainer
description: Explain model architectures and ablation variants from input to output using code-grounded data-flow tracing, tensor dimensions, training-only branches, target-data access, and gradient paths. Use when the user asks for 数据流介绍、模型变体对比、模型内部机制、UDA target 使用说明, or an implementation-grounded architecture summary.
---

# Data-Flow Model Explainer

## Purpose

Produce an implementation-grounded explanation of a model and its variants. Treat the exact code as the source of truth, and separate verified behavior, historical behavior, and proposed changes.

## Workflow

1. **Identify the baseline.**
   - Locate the model constructor, forward method, training loop, variant registry, and data loaders.
   - State which implementation is the baseline, its inputs, and its inference output.
   - Do not use a variant name as evidence of behavior.

2. **Build the canonical source flow.**
   Trace the source batch in order:

   ```text
   raw input -> preprocessing -> backbone -> conditioning/calibration
              -> representation -> pooling/fusion -> head -> output
   ```

   Record tensor shapes after every meaningful module. For 3-D MRI, include batch, channel, and spatial dimensions; for tabular data, include feature and missingness dimensions.

3. **Separate data roles.**
   Label every branch as one of:
   - inference/classification path;
   - source-supervised training path;
   - unlabeled target adaptation path;
   - augmentation or synthetic-control path;
   - diagnostic-only path.

   A tensor being computed does not mean it affects optimization. Check whether it reaches the returned loss with a differentiable path.

4. **Trace target access explicitly.**
   For `T_adapt` and `T_test`, state separately whether the code reads:
   - MRI/image;
   - table/covariates and missingness;
   - labels;
   - domain or environment metadata;
   - predictions or metrics.

   Distinguish target image use for style mixing, target feature use for GRL/CORAL/consistency, target table conditioning, and target labels. Never call a method strict UDA without checking the loader and selector.

5. **Describe each variant as a diff from the baseline.**
   For every variant, answer in this order:
   - what new or replaced input is created;
   - which module consumes it;
   - what tensor shape changes, if any;
   - whether the classifier path changes;
   - whether a training-only loss or gradient path is added;
   - whether inference behavior changes;
   - what scientific question the variant tests.

   Use a compact comparison table with columns such as `classifier input`, `target influence`, `auxiliary branch`, and `gradient scope`.

6. **Trace gradients, not just forward tensors.**
   Explain the direction of each objective:
   - CE or task loss updates the task path normally;
   - GRL is identity in the forward pass and reverses/scales encoder gradients in backpropagation;
   - CORAL/MMD/consistency connects the listed source and target representations;
   - a frozen projector changes the discriminator input but is not fitted by target data;
   - proximal/identity terms constrain parameter or representation drift.

   State whether a branch updates the backbone, conditioning module, fusion head, discriminator, or only records diagnostics.

7. **Check code/document agreement.**
   Compare the implementation with the plan or report. Flag cases such as:
   - a target branch is computed but only used for logging;
   - a documented consistency term compares source and augmentation rather than target;
   - a loader exposes fields that the training loop ignores;
   - a module is called CAPM/GRL in prose but uses an image-only interaction in code.

8. **Conclude with claim boundaries.**
   State what the variant can establish and what it cannot establish. Do not infer biological, scanner, or batch-specific meaning from a module name or a single metric.

## UDA-specific rules

- Keep `S_train`, `S_val`, `S_test`, `T_adapt`, and `T_test` distinct.
- State checkpoint-selection data separately from final evaluation data.
- Target labels, predictions, and metrics must not enter strict-UDA adaptation or selection.
- If target covariates are used, call this target-unlabeled covariate access; if target metadata labels supervise a loss, register it as target-metadata-supervised adaptation.
- For source/target synthetic pairs, say exactly which table is used. Reusing `z_s` for a target-style image is not the same as using `z_t`.
- Keep image-only UDA, multimodal UDA, domain generalization, and target-supervised transfer as separate protocol rows.

## Recommended output structure

```markdown
# [Model] Data Flow

## Baseline
[Input contract, ordered tensor shapes, and final output]

## Variant-by-variant changes
### [Variant]
- Source flow:
- Target flow:
- Changed module/shape:
- Gradient and loss path:
- Inference path:
- Question tested:

## Comparison table
[One row per variant]

## Implementation caveats
[Verified code/document mismatches, protocol boundaries, and unimplemented proposals]
```

## Dimension notation

Use explicit notation such as `[B,1,D,H,W]`, `[B,C,D',H',W']`, `[B,F]`, and `[B,K]`. Explain spatial downsampling instead of writing only “feature map.” If a shape depends on input geometry, give the dependency and one verified example.

## Code-grounding and references

- Search with `rg` and read the relevant constructor, forward, loss, loader, and variant-registry code before explaining.
- Cite the smallest useful code location in the conversation when evidence matters.
- Do not put local absolute machine paths into experiment plans or server-run documents. Prefer module names, repository-relative paths, commit identifiers, or server-side configuration names.
- If the requested explanation concerns an existing repository, do not invent modules that are absent. Label a proposed integration as `proposed` and keep it separate from `implemented` behavior.

## Final checklist

- [ ] Baseline is defined from code.
- [ ] Every meaningful module has input and output dimensions.
- [ ] Forward, training-only, and diagnostic paths are separated.
- [ ] Target MRI, table, labels, and metrics are audited independently.
- [ ] Every variant is explained as a baseline diff.
- [ ] GRL/projector/loss gradient scopes are stated.
- [ ] Code facts, historical results, and proposals are not mixed.
- [ ] Protocol and claim boundaries are explicit.
