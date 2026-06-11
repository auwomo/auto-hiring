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

## Step 2 — 映射字段

从简历解析结果中自动映射已知字段：

| 审批字段 | 来源 |
|---------|------|
| 姓名 | 简历解析.姓名 |
| 申请职位 | 匹配结果.推荐方向 |
| 手机号 | 简历解析.联系方式.手机 |
| 邮箱 | 简历解析.联系方式.邮箱 |
| 毕业院校 | 简历解析.学历.院校 |
| 曾经任职 | 简历解析.工作经历（最近一家） |

## Step 3 — 补充缺失字段

对于无法从简历中提取的必填字段，询问 HR：

```
以下字段需要您补充：
- {字段名1}（{字段类型}）
- {字段名2}（{字段类型}）

请提供，或输入"跳过"使用默认值。
```

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

- **审批 approval_code:** 待确认（需要 HR 提供具体的审批模板编码）
- **发起人 open_id:** 待配置（HR 的飞书 open_id）

## 权限要求

此流程需要 Bot-Hiring 应用具备以下飞书权限：
- `approval:approval` — 审批应用
- `approval:approval:readonly` — 读取审批定义
- `approval:instance` — 创建/读取审批实例
