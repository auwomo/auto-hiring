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
- `type` — 字段类型（input/textarea/date/select/attachmentV2/...）
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

## Step 3 — 上传简历到审批系统

使用封装脚本上传，**禁止自己拼 curl 命令**（历史上多次因参数组装错误导致 unknown-file）：

```bash
./scripts/upload-resume.sh <简历PDF路径> "<候选人姓名>-简历.pdf"
```

示例：
```bash
./scripts/upload-resume.sh ./lark-im-resources/abc123.pdf "张三-简历.pdf"
```

**输出：**
- 成功：输出一行文件 code（UUID 格式，如 `AE127506-AECC-4BFF-8934-3CE7E4D56512`），用于 Step 5 的 attachmentV2 value
- 失败：输出 `ERROR:` 开头的错误信息，退出码非零 → **停止流程，不要继续创建审批**

**注意事项：**
- 脚本会自动获取 token、设置正确的 Content-Disposition filename、校验返回
- 如果显示名不以 `.pdf` 结尾，脚本会自动补充
- 每次只能上传一个文件，附件大小限制 50 MB

## Step 4 — 补充缺失字段

对于无法从简历中自动提取的必填字段（如简历中无手机号、无邮箱等），询问 HR：

```
以下字段需要您补充：
- {字段名1}（{字段类型}）
- {字段名2}（{字段类型}）

请提供，或输入"跳过"使用默认值。
```

## Step 5 — 组装 form 并创建审批实例

### form 字段格式

`form` 是 JSON 字符串，格式为数组：

```json
[
  {"id": "widget16510687659170001", "type": "input", "value": "张三"},
  {"id": "widget17782207135510001", "type": "input", "value": "Auwomo 自动匹配"},
  {"id": "widget16510687945600001", "type": "input", "value": "13800138000"},
  {"id": "widget16510687997020001", "type": "input", "value": "test@example.com"},
  {"id": "widget17682115238860001", "type": "input", "value": "清华大学"},
  {"id": "widget17682115896530001", "type": "input", "value": "字节跳动 - 算法工程师"},
  {"id": "widget17760471107320001", "type": "input", "value": "基模方向"},
  {"id": "widget17682115396360001", "type": "textarea", "value": "有顶会论文，world model经验丰富"},
  {"id": "widget17682115506100001", "type": "textarea", "value": "缺少大规模分布式训练实际落地经验"},
  {"id": "widget16941367008630001", "type": "attachmentV2", "value": ["文件上传返回的code"]}
]
```

**`attachmentV2` 格式要点（易错！！）：**
- `value` 是**字符串数组** `["CODE"]`，其中 CODE 是 Step 3 返回的 UUID
- ❌ 错误：`"value": "CODE"` （字符串）
- ❌ 错误：`"value": [{"code": "CODE"}]` （对象数组）
- ❌ 错误：`"value": ["https://..."]` （URL）
- ✅ 正确：`"value": ["AE127506-AECC-4BFF-8934-3CE7E4D56512"]`

### 发起人身份

API 必须指定一个真实飞书用户作为审批发起人（Bot 没有用户身份，不能以 Bot 名义发起）。

**规则：当前与 Agent 对话的用户即为发起人。** 从对话上下文中获取用户的 `open_id`。

### 面试官路由（一面/二面/三面）

⚠️ **面试官每次由 HR 指定，不是固定的。** 创建审批前必须向 HR 确认各轮面试官。

#### Step 5.1 — 确认面试官

向 HR 确认（以方向文件中的面试安排为默认推荐）：

```
请确认本次各轮面试官：
- 一面：{从方向文件推荐}
- 二面：{从方向文件推荐}
- 三面：{从方向文件推荐}

需要调整吗？确认后我将创建审批。
```

#### Step 5.2 — 生成路由 JSON

HR 确认后，使用脚本生成 `node_approver_open_id_list`，**禁止自己组装 JSON**：

```bash
./scripts/build-approver-nodes.sh --一面 "人名1,人名2" --二面 "人名3,人名4" --三面 "人名5"
```

示例：
```bash
./scripts/build-approver-nodes.sh --一面 "郭凯文,温霆燕" --二面 "狄尧,Tim" --三面 "温霆燕,于开丞"
```

**输出：** 完整的 `node_approver_open_id_list` JSON 数组，直接用于创建审批请求。

**注意：**
- 人名必须与 `scripts/people.json` 中注册的名字完全一致
- 支持每轮多人（逗号分隔）
- 可以只传部分轮次（如只传 `--一面`，其余不指定）
- 如果人名找不到会报错，此时停止流程，检查 people.json

#### Step 5.3 — 创建审批（含路由）

将脚本输出的 JSON 作为 `node_approver_open_id_list` 传入：

```bash
lark-cli api POST /open-apis/approval/v4/instances \
  --data '{
    "approval_code": "57E726C3-EA5E-4422-A2F3-ACED3A75F8D2",
    "open_id": "<当前对话用户的open_id>",
    "form": "<form_json_string>",
    "node_approver_open_id_list": <脚本输出的JSON>
  }' \
  --as bot --format json
```

## Step 6 — 确认结果

提交成功后输出：

```
✅ 审批已创建
- 实例编号：{instance_code}
- 候选人：{姓名}
- 申请职位：{方向}
- 一面面试官：{面试官}
- 发起人：{当前用户}
- 当前状态：待审批

审批流程已启动，后续进度可通过飞书审批查看。
```

如果提交失败，输出错误信息并建议排查方向。

## 常量

- **审批 approval_code:** `57E726C3-EA5E-4422-A2F3-ACED3A75F8D2`（人事 - 西湖数智）
- **发起人 open_id:** 动态 — 当前对话用户的 open_id
- **审批节点：**

| 节点名 | node_id | 类型 | 需指定审批人 |
|--------|---------|------|-------------|
| 发起 | b078ffd28db767c502ac367053f6e0ac | AND | 否 |
| 简历筛查 | 195995043844a471d88ce4a273579a51 | OR | 否（固定） |
| 一面 | c100320a29e913fa43107515e560b6fe | OR | 是（自选） |
| 二面 | 106d5da02d8fc3e9998ebfe64e106cce | OR | 是（自选） |
| 终面 | 6590285849845c2822e828e033fd7f37 | AND | 否（固定） |
| 办理 | 94effe9deb0bfac1ef1ced4d4d344c75 | AND | 否（固定） |
| 结束 | b1a326c06d88bf042f73d70f50197905 | AND | 否 |

## Step 0 — 获取简历 PDF 文件

用户发来的 PDF 简历需要先下载到本地：

```bash
lark-cli im +messages-mget --message-ids "<message_id>" --download-resources --as bot
```

文件会下载到 `./lark-im-resources/<file_key>.<ext>`，后续步骤使用该本地路径。

## 操作注意事项（必读）

1. **lark-cli `--file` 和 `--data @file` 都只接受相对路径** — 必须先 `cd` 到文件所在目录，再用 `./filename`
2. **审批附件上传接口** — `/open-apis/approval/v4/files/upload?type=attachment`，不是 Drive 上传
3. **attachmentV2 value 是字符串数组** — `["CODE"]` 不是对象数组
4. **发起人必须是真实用户 open_id** — Bot 不能发起审批
5. **一面节点需指定审批人** — 根据匹配方向从 `team-profiles.md` 获取对应一面面试官
6. **二面/终面节点审批人可不填** — 等审批流转到时由发起人手动选择
