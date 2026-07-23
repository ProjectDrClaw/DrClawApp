# 文档索引

| 文档 | 说明 |
| ---- | ---- |
| [architecture.md](./architecture.md) | 工程结构、技术栈、启动流程 |
| [config.md](./config.md) | 多环境、签名、品牌资源、推送、地图、Actions 手动打包 |
| [faq.md](./faq.md) | 常见问题 |
| [message_types_alignment.md](./message_types_alignment.md) | 与 Agent 对齐语音/视频/文件/@文本的实施计划 |
| [business_workbench_design.md](./business_workbench_design.md) | 业务工作台：患者/录音、聊天选患者；**§15 含 P2 实施细则** |
| [../README.md](../README.md) | 项目总览与快速开始 |

相关工程：Expo 客户端 `DrClawApp`（品牌图与应用 ID 已对齐）。

## 上线前检查

- [ ] 生产 `prodHost` / `SERVER_HOST` 已配置
- [ ] 联调网络可访问 OpenIM 服务端口
- [ ] 仓库保持**私有**（含团队签名证书）
- [ ] 另地备份 `android/app/drclaw.jks` 与 `key.properties`
- [ ] Firebase / 个推已换成自有项目
- [ ] 高德 Key（若使用位置消息）
- [ ] iOS：证书、描述文件、App Group `group.com.drclaw.app.rtc`
