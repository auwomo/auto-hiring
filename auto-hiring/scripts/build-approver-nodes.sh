#!/bin/bash
# build-approver-nodes.sh — 根据面试官姓名生成审批节点路由 JSON
# 用法: ./scripts/build-approver-nodes.sh --一面 "郭凯文,温霆燕" --二面 "狄尧,Tim" --三面 "温霆燕,于开丞"
# 输出: node_approver_open_id_list JSON（直接用于审批创建 API）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PEOPLE_FILE="$SCRIPT_DIR/people.json"

if [ ! -f "$PEOPLE_FILE" ]; then
  echo "ERROR: 人员注册表不存在: $PEOPLE_FILE" >&2
  exit 1
fi

# 解析参数
ROUND1=""
ROUND2=""
ROUND3=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --一面) ROUND1="$2"; shift 2 ;;
    --二面) ROUND2="$2"; shift 2 ;;
    --三面) ROUND3="$2"; shift 2 ;;
    *) echo "ERROR: 未知参数: $1" >&2; echo "用法: $0 --一面 \"人名1,人名2\" --二面 \"人名3\" --三面 \"人名4\"" >&2; exit 1 ;;
  esac
done

if [ -z "$ROUND1" ] && [ -z "$ROUND2" ] && [ -z "$ROUND3" ]; then
  echo "ERROR: 至少需要指定一轮面试官" >&2
  echo "用法: $0 --一面 \"人名1,人名2\" --二面 \"人名3\" --三面 \"人名4\"" >&2
  exit 1
fi

python3 -c "
import json, sys

with open(sys.argv[1], 'r') as f:
    people = json.load(f)

nodes = {
    '一面': ('c100320a29e913fa43107515e560b6fe', sys.argv[2]),
    '二面': ('106d5da02d8fc3e9998ebfe64e106cce', sys.argv[3]),
    '三面': ('6590285849845c2822e828e033fd7f37', sys.argv[4]),
}

result = []
errors = []

for round_name, (node_id, names_str) in nodes.items():
    if not names_str.strip():
        continue
    names = [n.strip() for n in names_str.split(',') if n.strip()]
    open_ids = []
    for name in names:
        if name in people:
            open_ids.append(people[name])
        else:
            errors.append(f'{round_name}: 找不到 \"{name}\" 的 open_id，请在 scripts/people.json 中注册')
    if open_ids:
        result.append({'key': node_id, 'value': open_ids})

if errors:
    for e in errors:
        print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)

print(json.dumps(result, ensure_ascii=False))
" "$PEOPLE_FILE" "$ROUND1" "$ROUND2" "$ROUND3"
