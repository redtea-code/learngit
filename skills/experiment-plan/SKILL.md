---
name: experiment-plan
description: Create concise, implementation-grounded research experiment plans with explicit model data flow, variant diffs, UDA target access, protocol boundaries, and seed-aware result tables. Use when the user asks for 实验计划、研究计划、DS-实验设计、实验变体矩阵, or a plan that must connect model code to paper experiments.
metadata:
  display-name: 实验计划
  required-downstream-skill: experiment-submap-builder
---

# 实验计划

## Purpose

把一个研究方向收敛成可运行、可比较、可审计的实验计划。计划必须同时说明研究问题、模型数据流、变体相对于 baseline 的改变、target 的实际使用方式、实现入口和结果判定规则。

本 skill 的默认风格是“少而清楚”：先保留已经存在且有代码依据的主线，再用一个最小新变体验证新增想法；在新变体未通过门槛前，不展开组合爆炸的第二套矩阵。

## Mandatory downstream skill

使用本 skill 时，**必须先加载并遵守 `experiment-submap-builder` skill**。它负责副地图的发现流程、五段式文档结构、证据分类、指标表和索引要求；本 skill 在其上补充研究计划的收敛规则、数据流审计和实验决策门槛。

执行顺序：

1. 明确告知用户将调用 `experiment-submap-builder` 构建副地图；
2. 读取该 skill 的完整 `SKILL.md`；
3. 按其要求并行查找主地图、相关计划/报告、模型 forward/loss、loader、variant registry、checkpoint 和实际结果；
4. 用本 skill 的范围控制和数据流规则组织计划；
5. 按副地图 skill 的验证清单检查标题、表格、链接、指标和证据状态。

## Scope control

在写计划前先回答：

- 一个明确的主问题是什么？
- 哪个模型是 baseline？
- 哪些变体已经有实现或历史证据？
- 新想法需要增加几个最小实验才能被证伪？
- 哪些复杂模块明确不进入本轮？

遵守以下收敛原则：

- 变体总数只包含回答主问题所必需的行；
- 已有机制优先作为主矩阵保留，不因新模型出现而删除；
- 新模态先做一个最小可行性基线，再决定是否复制到其他变体；
- 不把 relation、CORAL、复杂 fusion、pseudo-label、entropy、multi-head GRL 等同时塞进第一轮；
- batch/scanner effect 默认是解释性假说，不把它写成主任务或成功标准；
- 研究计划是预注册设计，不把历史结果改写成新方法证据。

对于本项目的 DS-043 风格请求，默认收敛为：原有 `P0/F0/F1/F2/F3/R1/R2/R3` 八个 CAPM-GRL 变体，加一个 `P0-M` 保守多模态 source-only 基线。除非用户明确要求，不自动生成 `F1-M` 至 `R3-M`。

## Required plan content

### 1. Baseline and input contract

先从代码确定 baseline，而不是从变体名称猜测。分别写出：

- `S_train`、`S_val`、`S_test`、`T_adapt`、`T_test` 的字段和用途；
- MRI 输入、table 字段、missingness、source label、domain/environment metadata；
- target label、prediction、metric 是否被读取，以及是否影响 adaptation/selector；
- classifier output 和重要的 auxiliary output。

使用显式 tensor notation，例如 `[B,1,D,H,W]`、`[B,C,D',H',W']`、`[B,F]`、`[B,K]`。未核对的 shape 必须标为 configuration-dependent。

### 2. Data-flow-first description

计划必须包含从输入到输出的顺序数据流，并分开写：

```text
raw input -> preprocessing -> backbone -> conditioning/calibration
           -> representation -> pooling/fusion -> head -> output
```

至少区分：

- inference/classification path；
- source-supervised training path；
- unlabeled target adaptation path；
- augmentation/synthetic-control path；
- diagnostic-only path。

对每个变体，按相对于 baseline 的差异描述：

1. 新增或替换的输入；
2. 消费它的模块；
3. shape 或参数容量变化；
4. classifier path 是否变化；
5. 新增的 loss 和梯度路径；
6. 推理时是否仍保留该分支；
7. 该变体检验的科学问题。

“计算了某个 tensor”不等于“它参与了优化”。必须追踪它是否进入 loss，并说明梯度是否能回到 backbone、CAPM、fusion、classifier 或 discriminator。

### 3. CAPM-GRL baseline family

如果实验基于 CAPM-GRL，优先按以下语义解释：

```text
x_s -> ResNet -> F4 -> SpatialGate3d -> CAPM(F4,t_s)
    -> B4 -> GAP -> diagnosis classifier
```

- `P0`：source-only CAPM；不使用 target adaptation；
- `F0`：增加 source-intensity 和 target-style 控制，但无 GRL；
- `F1`：完整 `B4` 上的 domain GRL，source vs target-style；
- `F2`：完整 `B4` 上的 intensity GRL，clean source vs intensity source；
- `F3`：同时使用 domain/intensity GRL；
- `R1`：residual `R4=(I-P_task)B4` 上的 domain GRL；
- `R2`：residual `R4` 上的 intensity GRL；
- `R3`：residual `R4` 上的双 GRL。

明确说明：full/residual 主要改变 GRL 的梯度输入范围，通常不改变疾病 classifier 看到的完整 `B4`；GRL 前向是 identity，反向才反转并缩放 encoder 梯度；`P_task` 若由 source CE 梯度构造则冻结，不能用 target label 拟合。

### 4. Conservative multimodal extension

当 table 变量很少或其独立分类能力不确定时，使用保守 concat，而不是复杂多模态网络：

```text
B4 [B,512,5,7,5] -> GAP -> h_M [B,512]
t=[age,sex,education] + missingness
  -> source-fitted preprocessing -> t_tilde [B,6]
concat(h_M,t_tilde) -> [B,518] -> linear head -> [B,2]
```

约束：

- age/education 使用 source-fitted scaling，sex 保持合法类别编码；
- missingness flags 要单独标明，不把它们冒充为新的生物学变量；
- 不默认使用 table MLP、attention、relation loss 或 CORAL；
- 新分类头的 MRI 权重可复制 baseline，table 权重置零，使初始行为接近 baseline；
- `P0-M` 先作为 source-only feasibility probe，不自动扩展成 `F1-M` 至 `R3-M`；
- 只有当 P0-M 在多个 seed 的 target BA/AUROC 不劣于 baseline、source preservation 未恶化时，才注册下一轮 multimodal-UDA 变体。

### 5. Target-access and protocol rules

分别写清楚 target 的：

- MRI/image 是否使用；
- table/covariates/missingness 是否使用；
- label 是否使用；
- domain/environment metadata 是否使用；
- prediction/metric 是否使用；
- checkpoint selector 是否读取 target 信息。

必须区分：

- target image 用于 style mixing；
- target feature 用于 GRL、CORAL、MMD 或 consistency；
- target table 用于 CAPM 条件化或最终 multimodal inference；
- target label 只用于冻结后的最终报告。

source/target synthetic pair 还要写明使用哪一方的 table。`CAPM(x_t*, t_s)` 不等于 `CAPM(x_t,t_t)`。

严格 UDA 中，target label、prediction、metric、confusion matrix 和模型排名不得进入 adaptation 或 selector。若使用 target covariates 但不使用 target diagnosis，标为 target-unlabeled covariate access；若 target metadata label 参与训练，单独标为 target-metadata-supervised adaptation。

### 6. Modules and implementation entries

使用 repository-relative code entry points，列出：

- backbone/CAPM；
- spatial gate；
- GRL 和 discriminator；
- task-support projector；
- frequency/augmentation generator；
- loss function；
- concat head（若为 proposed，明确标记）；
- source/target loader；
- checkpoint selector 和 artifact writer。

每个模块都标明证据状态：`implemented`、`screening`、`exploratory`、`formal`、`proposed/code ready`、`blocked/inconclusive/no-go`。源码存在不等于真实数据结果存在；文档声称“已实现”也必须核对 source 和 artifact inventory。

### 7. Result and decision design

按 `experiment-submap-builder` 的要求创建结果表：

- 表头写明 direction、task、subject-level、seed 集合和 protocol；
- 至少包含 `ACC`、`AUROC`、`BA`、`Macro-F1`、`Sensitivity`；
- 指定一个 baseline 行；
- 使用 `ΔAUROC vs baseline` 或 `ΔACC vs baseline`；
- 未运行或原始报告没有的指标写 `NR`，绝不从其它指标反推；
- 不合并不同方向、不同 split、不同 selector、不同 artifact generation。

结果解释至少覆盖：

- target 主任务方向；
- source preservation；
- seed variability；
- sensitivity/specificity 或 class-collapse trade-off；
- GRL/encoder/discriminator gradient 是否有限且非塌缩；
- discrepancy 下降是否与任务改善一致。

不要把 discriminator loss 接近 `log(2)`、单个 target point estimate 或 discrepancy 下降直接写成方法成功。

### 8. Claim boundary

结尾必须写出计划能证明什么、不能证明什么。除非有匹配 protocol、多个 seed 和相应机制证据，否则不得声称：

- 已去除 scanner/batch effect；
- CAPM 输出是纯 biological representation；
- residual 是纯 batch representation；
- table 提供了足够独立的疾病信息；
- domain/intensity GRL 已被稳定验证；
- 单个 seed 或 target 指标证明方法有效。

## Required document shape

遵循下列五个主要标题，顺序不可改变；这部分由 `experiment-submap-builder` 负责格式约束：

```markdown
# DS-XXX 研究计划/副地图：[family name]

## 1. 模型输入与输出
## 2. 模型的数据流
## 3. 涉及的模块
## 4. 每个模块的具体实现
## 5. 实验结果与分析
```

在第 5 节中，即使尚无真实结果，也要放置标明 seeds 的 `NR` 结果表，并写出预注册判定规则。

## Document hygiene

- 计划文档不写个人机器的绝对路径、用户名、盘符路径或本地临时目录；使用 repository-relative module names、server-side config names、commit ids 和 artifact schema。
- 不覆盖或重写主地图；需要注册实验时更新副地图索引。
- 不修改无关 dirty-worktree 文件。
- 明确标出 `implemented`、`historical`、`proposed` 和 `no real-data results`，不要混成一个状态。
- 在交付前运行 heading/table/link/path 检查，并查看最终 diff。

## Completion checklist

- [ ] 已加载并遵守 `experiment-submap-builder`。
- [ ] baseline 来自 constructor/forward/loss/loader 代码。
- [ ] source、target adaptation、target test 的字段和用途分开。
- [ ] 每个变体都是相对于 baseline 的数据流差异。
- [ ] 每个重要 tensor 有输入输出维度。
- [ ] GRL、projector、loss 的梯度作用范围已说明。
- [ ] 新模态先用一个最小基线，不自动产生组合矩阵。
- [ ] 结果表含 ACC、AUROC、BA、Macro-F1、Sensitivity 和 delta 列。
- [ ] 未运行指标为 `NR`，没有推算。
- [ ] 文档没有本地绝对路径。
- [ ] 结论边界与证据状态一致。
