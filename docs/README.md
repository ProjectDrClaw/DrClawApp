# 文档索引

| 文档 | 说明 |
| ---- | ---- |
| [architecture.md](./architecture.md) | 工程结构、技术栈、启动流程 |
| [config.md](./config.md) | 多环境、签名、品牌资源、推送、地图 |
| [faq.md](./faq.md) | 常见问题 |
| [../README.md](../README.md) | 项目总览与快速开始 |

相关工程：Expo 客户端 `DrClawApp`（品牌图与应用 ID 已对齐）。

## 上线前检查

- [ ] 生产 `prodHost` / `SERVER_HOST` 已配置
- [ ] 本机可访问对应 OpenIM 服务端口
- [ ] Android：`key.properties` + release keystore 已备份
- [ ] Firebase / 个推已换成自有项目
- [ ] 高德 Key（若使用位置消息）
- [ ] iOS：证书、描述文件、App Group `group.com.drclaw.app.rtc`
