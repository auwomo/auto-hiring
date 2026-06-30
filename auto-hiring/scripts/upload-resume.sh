#!/bin/bash
# upload-resume.sh — 上传简历到飞书审批系统
# 用法: ./scripts/upload-resume.sh <pdf文件路径> <显示文件名>
# 输出: 成功时输出文件 code (UUID)，失败时输出错误并 exit 1

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "ERROR: 用法: $0 <pdf文件路径> <显示文件名>" >&2
  exit 1
fi

FILE_PATH="$1"
DISPLAY_NAME="$2"

if [ ! -f "$FILE_PATH" ]; then
  echo "ERROR: 文件不存在: $FILE_PATH" >&2
  exit 1
fi

if [[ "$DISPLAY_NAME" != *.pdf ]]; then
  DISPLAY_NAME="${DISPLAY_NAME}.pdf"
fi

# 获取 token（从环境变量或 lark-cli 配置读取凭证）
LARK_APP_ID="${LARK_APP_ID:-cli_aaa38df248785cd6}"
LARK_APP_SECRET="${LARK_APP_SECRET:-}"

if [ -z "$LARK_APP_SECRET" ]; then
  # 尝试从 lark-cli 直接获取 token
  TOKEN=$(lark-cli token 2>/dev/null | grep -oP '(?<=t-)[^\s]+' || true)
  if [ -z "$TOKEN" ]; then
    TOKEN=$(lark-cli api POST /open-apis/auth/v3/tenant_access_token/internal \
      -q '.tenant_access_token' 2>/dev/null)
  fi
else
  TOKEN=$(curl -s -X POST 'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal' \
    -H 'Content-Type: application/json' \
    -d "{\"app_id\":\"$LARK_APP_ID\",\"app_secret\":\"$LARK_APP_SECRET\"}" \
    | python3 -c "import json,sys; print(json.load(sys.stdin).get('tenant_access_token',''))" 2>/dev/null)
fi

if [ -z "$TOKEN" ]; then
  echo "ERROR: 获取 token 失败" >&2
  exit 1
fi

# 上传（关键：content 字段 + ;filename= 指定显示名）
RESP=$(curl -s -X POST 'https://open.feishu.cn/open-apis/approval/v4/files/upload' \
  -H "Authorization: Bearer $TOKEN" \
  -F 'type=attachment' \
  -F "name=${DISPLAY_NAME}" \
  -F "content=@${FILE_PATH};filename=${DISPLAY_NAME}")

# 校验返回
echo "$RESP" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    if data.get('code') != 0:
        print(f\"ERROR: API返回错误 code={data.get('code')}: {data.get('msg', 'unknown')}\", file=sys.stderr)
        sys.exit(1)
    file_code = data['data']['urls_detail'][0]['code']
    url = data['data']['urls_detail'][0].get('url', '')
    if not file_code:
        print('ERROR: 返回的 file code 为空', file=sys.stderr)
        sys.exit(1)
    print(file_code)
except (KeyError, IndexError, TypeError) as e:
    print(f'ERROR: 返回格式异常: {e}', file=sys.stderr)
    print(f'原始返回: {data}', file=sys.stderr)
    sys.exit(1)
except json.JSONDecodeError:
    print('ERROR: 返回非 JSON，可能是网络错误', file=sys.stderr)
    sys.exit(1)
"
