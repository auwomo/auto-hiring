# 审批提交流程

HR 确认候选人通过后，通过 lark-cli 创建飞书审批实例。

## Step 1 — 查询审批模板字段

获取目标审批模板的字段定义：

```bash
lark-cli api GET /open-apis/approval/v4/approvals/:approval_code \
  --params '{"locale":"zh-CN"}' \
  --as bot --format json
```

其中 `approval_code` 为人事审批模板编码（见下方常量）。

从返回的 `data.form` 中解析字段列表，每个字段包含：
- `id` — 字段唯一标识
- `name` — 字段显示名
- `type` — 字段类型（input/textarea/date/select/...）
- `required` — 是否必填
- `option` — 选项列表（select 类型）

## Step 2 — 实际模板字段（审批码: 57E726C3-EA5E-4422-A2F3-ACED3A75F8D2）

| 字段 ID | 字段名 | 类型 | 必填 | 来源 |
|---------|--------|------|------|------|
| widget16510687659170001 | 姓名 | input | ✅ | 简历解析.姓名 |
| widget17782207135510001 | 简历来源 | input | ✅ | 固定值"Auwomo 自动匹配"或询问 HR |
| widget16510687945600001 | 手机号 | input | ✅ | 简历解析.联系方式.手机 |
| widget16510687997020001 | 邮箱 | input | ✅ | 简历解析.联系方式.邮箱 |
| widget17682115238860001 | 毕业院校 | input | ✅ | 简历解析.学历.院校 |
| widget17682115896530001 | 曾经任职 | input | ✅ | 简历解析.工作经历（最近一家） |
| widget17760471107320001 | 申请职位 | input | ✅ | 匹配结果.推荐方向 |
| widget17682115396360001 | 优势 | textarea | ✅ | 评估报告.亮点（自动填入） |
| widget17682115506100001 | 劣势 | textarea | ✅ | 评估报告.风险点（自动填入） |
| widget16941367008630001 | cv | attachmentV2 | ✅ | 候选人原始 PDF 简历附件 |

**注意事项：**
- `cv` 字段类型为 `attachmentV2`，需先上传简历文件到飞书再填入文件 token。
- `简历来源` 默认填入 "Auwomo 自动匹配"，用户可覆盖。
- `优势`/`劣势` 从评估报告中自动提取，用户确认后填入。

## Step 3 — 补充缺失字段

对于无法从简历中自动提取的必填字段（如简历中无手机号、无邮箱等），询问 HR：

```
以下字段需要您补充：
- {字段名1}（{字段类型}）
- {字段名2}（{字段类型}）

请提供，或输入"跳过"使用默认值。
```

对于 `cv` 附件字段，将候选人原始 PDF 上传到飞书后获取 file_id 填入。

## Step 4 — 创建审批实例

组装请求 body 并提交：

```bash
lark-cli api POST /open-apis/approval/v4/instances \
  --data '{
    "approval_code": "<approval_code>",
    "open_id": "<发起人open_id>",
    "form": "<form_json_string>",
    "node_approver_open_id_list": [...]
  }' \
  --as bot --format json
```

### form 字段格式

`form` 是 JSON 字符串，格式为数组：

```json
[
  {"id": "widget1", "type": "input", "value": "张三"},
  {"id": "widget2", "type": "input", "value": "算法工程师"},
  {"id": "widget3", "type": "input", "value": "13800138000"}
]
```

## Step 5 — 确认结果

提交成功后输出：

```
✅ 审批已创建
- 实例编号：{instance_code}
- 候选人：{姓名}
- 申请职位：{职位}
- 当前状态：待审批

审批流程已启动，后续进度可通过飞书审批查看。
```

如果提交失败，输出错误信息并建议排查方向。

## 常量

- **审批 approval_code:** `57E726C3-EA5E-4422-A2F3-ACED3A75F8D2`（人事 - 西湖数智）
- **发起人 open_id:** `ou_9cbf85f91eaebd447e507cd9d52f3873`（郭凯文）
- **审批节点顺序：** 发起 → 简历筛查 → 一面 → 二面 → 终面 → 办理 → 结束

## 权限要求

此流程需要 Bot-Hiring 应用具备以下飞书权限：
- `approval:approval` — 审批应用
- `approval:approval:readonly` — 读取审批定义
- `approval:instance` — 创建/读取审批实例
