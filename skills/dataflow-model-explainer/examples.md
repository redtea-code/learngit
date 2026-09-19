# Example: CAPM and GRL variants

Use this pattern when explaining a CAPM-conditioned MRI model with source labels and unlabeled target images.

## Baseline flow

```text
x_s [B,1,160,196,160]
  -> ResNet feature extractor
  -> F4 [B,512,5,7,5]
  -> CAPM(F4, z_s=[age,sex,education])
  -> B_s [B,512,5,7,5]
  -> GAP [B,512]
  -> classifier [B,2]
```

## Variant diff examples

| Variant | New branch | Classifier path | Target influence | Adversarial input |
|---|---|---|---|---|
| P0 | none | `B_s -> classifier` | none | none |
| F1 | `x_s+x_t -> x_t* -> B_t` | unchanged | target-style domain loss | full `B_s,B_t` |
| F2 | `x_s -> x_i -> B_i` | source and intensity CE | no target-domain loss | full `B_s,B_i` |
| R1 | frozen `P_task`, `R=(I-P_task)B` | unchanged, still full `B` | target-style domain loss | residual `R_s,R_t` |

The key distinction is that F1/R1 add a target-dependent gradient, while F2 only adds a source-intensity contrast. R1 changes the GRL input, not the diagnosis classifier input.

## Caveat pattern

If the implementation computes `B_t` but only uses it for mean-shift diagnostics when the GRL coefficient is zero, say so explicitly: the target branch is present in the forward trace but absent from the optimization path.
