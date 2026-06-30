---
name: auto-hiring
description: >
  简历自动匹配与评估。接收候选人 PDF 简历，解析关键信息，根据团队组员画像自动匹配最合适的岗位/方向，
  给出初步评估并推送给 HR。HR 确认通过后，自动查询飞书审批字段并创建审批实例。
  也支持通过对话管理招聘方向（增删改 JD、面试官、路由）。
  Triggers: 收到简历, 匹配岗位, 评估候选人, 提交审批, 简历分析, auto hiring, resume match, 新增方向, 修改JD, 更新面试官.
  NOT for: 招聘进度报表(用 xihu-hiring), 通用文件处理, 消息群发.
metadata:
  openclaw:
    requires:
      bins:
        - lark-cli
---

# 简历自动匹配与审批提交

接收 PDF 简历 → 解析 → 匹配团队岗位 → 评估 → HR 确认 → 创建飞书审批。

## 方向配置

所有招聘方向的元数据（名称、关键词、面试官、审批路由）集中在 `directions/_index.md`。
各方向详细 JD 存储在 `directions/<slug>.md`。

**执行匹配/审批前必须先读取 `directions/_index.md`。**

## 触发条件

### 简历匹配（流程 A/B）

用户发送 PDF 简历文件，或说以下任何一种：
- "帮我看看这个简历" / "这个人合适吗"
- "匹配一下这个候选人" / "评估这份简历"
- "提交审批" / "录入这个候选人"
- "resume match" / "auto hiring"

### 方向管理（流程 C）

- "新增方向" / "添加 JD" / "加一个方向" / "开一个新岗位"
- "修改 XXX 的 JD" / "更新 XXX 要求"
- "更新面试官" / "换面试官" / "补充 open_id"
- "删除方向" / "下线 XXX"
- 用户直接发送一段 JD 文本（含职责/要求/面试安排等招聘信息，非简历 PDF）

**不触发**：招聘进度报表（用 xihu-hiring）、通用 PDF 处理、群发消息。

## 执行流程

### 流程 A — 简历匹配与评估

当收到 PDF 简历时执行。详细步骤见 `references/match-and-evaluate.md`。

概要：
1. 解析 PDF 提取候选人信息（姓名、学历、经历、技能、方向）
2. 读取 `directions/_index.md` 获取所有方向的关键词和面试官
3. 匹配最合适的 1-3 个方向
4. 读取匹配到的方向详情 `directions/<slug>.md` 进行深度评估
5. 生成评估报告（匹配度、亮点、风险点，含方向专属加分项）
6. 推送给 HR，等待确认

### 流程 B — 审批提交

当 HR 确认候选人通过后执行。详细步骤见 `references/submit-approval.md`。

概要：
1. 上传简历 PDF 到飞书审批文件系统（专用接口，非 Drive）
2. 从简历解析结果中映射字段
3. 补充缺失字段（询问 HR）
4. 以当前对话用户身份创建审批实例
5. 从 `directions/_index.md` 获取匹配方向的 open_id，自动路由一面审批人

### 流程 C — 方向管理

当用户请求管理招聘方向时执行。详细步骤见 `references/manage-directions.md`。

概要：
1. 新增方向：创建 `directions/<slug>.md` + 在 `_index.md` 注册
2. 修改 JD：编辑对应方向文件
3. 更新面试官/路由：编辑 `_index.md` 对应行
4. 删除方向：移除注册 + 删除文件

## References 路由

| 场景 | 读取文件 |
|------|---------|
| 收到简历需要匹配评估 | `references/match-and-evaluate.md` + `directions/_index.md` |
| HR 确认后要提交审批 | `references/submit-approval.md` + `directions/_index.md` |
| 需要了解某方向详细 JD | `directions/<slug>.md`（slug 见索引） |
| 管理方向（增删改 JD） | `references/manage-directions.md` |
