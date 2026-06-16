---
name: auto-hiring
description: >
  简历自动匹配与评估。接收候选人 PDF 简历，解析关键信息，根据团队组员画像自动匹配最合适的岗位/方向，
  给出初步评估并推送给 HR。HR 确认通过后，自动查询飞书审批字段并创建审批实例。
  Triggers: 收到简历, 匹配岗位, 评估候选人, 提交审批, 简历分析, auto hiring, resume match.
  NOT for: 招聘进度报表(用 xihu-hiring), 通用文件处理, 消息群发.
metadata:
  openclaw:
    requires:
      bins:
        - lark-cli
---

# 简历自动匹配与审批提交

接收 PDF 简历 → 解析 → 匹配团队岗位 → 评估 → HR 确认 → 创建飞书审批。

当前团队 5 个方向：

| 方向 | 一面 | 关键词 |
|------|------|--------|
| 基模方向 | 马恩慧、张家焕 | World Model, video generation, 大规模预训练 |
| Post-training | 马子健 | RLHF, PPO, DPO, VLA, reward model |
| Infra 加速 | 郭凯文、王天亨 | GPU集群, 分布式训练, 推理优化, CUDA |
| RL 仿真 | 李诗雯 | Isaac Lab, MuJoCo, sim-to-real, URDF |
| 数据算法 | 王鑫、侯志一 | 数据pipeline, 多模态数据, VLM标注, RLDS |

## 触发条件

用户发送 PDF 简历文件，或说以下任何一种：
- "帮我看看这个简历" / "这个人合适吗"
- "匹配一下这个候选人" / "评估这份简历"
- "提交审批" / "录入这个候选人"
- "resume match" / "auto hiring"

**不触发**：招聘进度报表（用 xihu-hiring）、通用 PDF 处理、群发消息。

## 组员画像配置

团队成员画像存储在 `references/team-profiles.md`，包含每个方向的面试官、JD、要求和审批路由。
匹配前**必须读取此文件**获取最新信息。

## 执行流程

### 流程 A — 简历匹配与评估

当收到 PDF 简历时执行。详细步骤见 `references/match-and-evaluate.md`。

概要：
1. 解析 PDF 提取候选人信息（姓名、学历、经历、技能、方向）
2. 读取 `references/team-profiles.md` 获取团队画像（5 方向 + 一面面试官）
3. 匹配最合适的 1-3 个方向/组员
4. 生成评估报告（匹配度、亮点、风险点，含方向专属加分项）
5. 推送给 HR，等待确认

### 流程 B — 审批提交

当 HR 确认候选人通过后执行。详细步骤见 `references/submit-approval.md`。

概要：
1. 上传简历 PDF 到飞书审批文件系统（专用接口，非 Drive）
2. 从简历解析结果中映射字段
3. 补充缺失字段（询问 HR）
4. 以当前对话用户身份创建审批实例
5. 根据匹配方向自动路由一面审批人（见 team-profiles.md）

## References 路由

| 场景 | 读取文件 |
|------|---------|
| 收到简历需要匹配评估 | `references/match-and-evaluate.md` |
| HR 确认后要提交审批 | `references/submit-approval.md` |
| 需要了解团队方向和需求 | `references/team-profiles.md` |
