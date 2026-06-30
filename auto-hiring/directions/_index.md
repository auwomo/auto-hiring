# 方向索引

> Agent 在匹配和审批时**只需读取本文件**获取快速索引信息。
> 深度评估时再读取 `directions/<slug>.md` 获取完整 JD。

## 注册表

| 方向 | slug | 关键词 | 一面面试官 | 审批路由(open_id) | 优先级 |
|------|------|--------|-----------|-------------------|--------|
| 基模方向 | 基模方向 | World Model, video generation, 大规模预训练, DreamerV3, Genie | 马恩慧、张家焕 | ou_d4f8157a2fd074dd5c377a04eb3c6e08 | 急 |
| Post-training | post-training | RLHF, PPO, DPO, VLA, SFT, reward model | 马子健 | ou_2bdf98a90c2b32a72d3933376976bcba | 急 |
| Infra 加速 | infra-加速 | GPU集群, 分布式训练, 推理优化, CUDA, DeepSpeed, vLLM | 郭凯文、王天亨 | ou_9cbf85f91eaebd447e507cd9d52f3873 | 急 |
| RL 仿真 | rl-仿真 | Isaac Lab, MuJoCo, 仿真环境, sim-to-real, URDF | 李诗雯 | ou_b3ab1a70ff0be68b122f07af96af8e24 | 急 |
| 数据算法 | 数据算法 | 数据pipeline, 多模态数据, 自动标注, VLM, RLDS | 王鑫、侯志一 | ou_6735fb27a3c1dbead47eeda588c4c0f2 | 急 |
| 运维 | 运维 | 云基础设施, Docker, CI/CD, Linux, Nginx, 网络安全, Kubernetes | 郭凯文、温霆燕 | ou_9cbf85f91eaebd447e507cd9d52f3873 | 急 |

## 共同面试官

| 姓名 | open_id | 关联方向 |
|------|---------|---------|
| 张家焕 | ou_5279900e45aaa01e4a26b1ed20fd7f2d | 基模方向 |
| 王天亨 | ou_08f0c3207e3c111d552b1ef5afde271d | Infra 加速 |
| 侯志一 | ou_ac481eea7263439aef215c7a57f6c0d6 | 数据算法 |
| 温霆燕 | ou_2a93a2a3b8b68e300af65a902147a047 | 运维 |

## 使用说明

- **匹配简历时**：读取注册表的"关键词"列进行初步匹配
- **创建审批时**：读取注册表的"审批路由(open_id)"列获取一面审批人
- **深度评估时**：根据 slug 读取 `directions/<slug>.md` 获取完整 JD 和加分规则
- **管理方向时**：参见 `references/manage-directions.md`
