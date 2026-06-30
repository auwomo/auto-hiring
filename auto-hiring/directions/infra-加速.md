# Infra 加速（训练/推理基础设施）

## 面试安排

- **一面:** 郭凯文、王天亨
- **二面:** 待补充
- **三面:** 待补充

## 职责

- 负责支撑 LLM 与 World Model 训练的大规模 GPU 集群基础设施，保障高可用与稳定性
- 优化分布式训练框架（数据/模型/流水线并行），识别并解决通信、显存、IO 等性能瓶颈
- 构建高吞吐、低延迟推理服务，覆盖量化、KV Cache 优化、Continuous Batching 等核心技术
- 与算法团队协作，支持训练/推理快速实验迭代，评估并引入新型硬件与软件栈

## 要求

- 5 年以上基础设施或系统工程经验，有大规模分布式训练/推理实际落地经验优先
- 深入理解 GPU 体系结构，熟悉 CUDA、NCCL 及性能 profiling 工具链
- 熟练掌握至少一种主流训练框架（Megatron-LM、DeepSpeed、PyTorch FSDP）的源码级调优
- 熟悉推理优化方法：PagedAttention、Speculative Decoding、Continuous Batching 等
- 具备 Kubernetes、容器化部署及 InfiniBand/RoCE 高速网络配置经验
- 扎实的 Python / C++ 编程能力，能独立阅读并修改框架底层代码

## 加分项

- 有 World Model（视频生成/物理模拟）训练或推理系统建设经验
- 深度参与过 vLLM、TensorRT-LLM、SGLang 等开源推理框架开发
- 在 MLSys、OSDI、SOSP、SC 等顶会发表过相关论文

## 匹配加分规则

- 有大规模分布式训练/推理落地经验 → +1 档
- 熟练 CUDA/NCCL profiling → +0.5 档
- 深度参与过 vLLM/TensorRT-LLM/SGLang → +0.5 档
- 有 MLSys/OSDI/SOSP/SC 顶会论文 → +0.5 档
