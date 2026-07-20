# DrClawAppFlutter

Dr.Claw 客户端（Flutter）。当前基于 OpenIM Flutter Demo 改造，面向 Android / iOS。

仓库地址：https://github.com/9999-12-31/DrClawAppFlutter.git

**上游基线：** [OpenIM Flutter Demo](https://github.com/openimsdk/openim-flutter-demo) **v3.8.3+235**（对应 `flutter_openim_sdk` `^3.8.3+hotfix.12`，上游提交 `06480b8`）。

## 文档索引

| 文档 | 说明 |
| ---- | ---- |
| [docs/architecture.md](./docs/architecture.md) | 工程结构与技术栈 |
| [docs/config.md](./docs/config.md) | 服务端、推送、地图等配置 |
| [docs/faq.md](./docs/faq.md) | 常见问题 |

## 开发环境

- **Flutter**：3.32.8（建议与此版本对齐）
- **JDK**：17
- **Android**：Android Studio + minSdk 24
- **iOS**：Xcode，最低系统版本 13.0（需 macOS）
- **服务端**：需自行部署可用的 OpenIM Server（或后续 Dr.Claw 后端）

Windows 可进行 Android 开发；iOS 构建需在 macOS 完成。

## 快速开始

1. 克隆仓库

```bash
git clone https://github.com/9999-12-31/DrClawAppFlutter.git
cd DrClawAppFlutter
```

2. 安装依赖

```bash
flutter clean
flutter pub get
```

3. 配置服务端地址

编辑 `openim_common/lib/src/config.dart`：

```dart
static const _host = "your-server-ip or your-domain";
```

未改服务端默认端口时，一般只需改 `_host`。完整端口与推送/地图配置见 [配置说明](./docs/config.md)。

4. 运行

```bash
flutter run
```

## 构建

```bash
# Android
flutter build apk

# iOS（需 macOS）
flutter build ipa
```

产物位于 `build/` 目录。

## 当前能力概览

| 模块 | 说明 |
| ---- | ---- |
| 账号 | 手机/邮箱注册登录、验证码、忘记密码、资料与多语言 |
| 好友 / 黑名单 | 申请、搜索、备注、黑名单 |
| 群组 | 建群、成员管理、转让、进群审批等 |
| 消息 / 会话 | 多类型消息、置顶、免打扰、已读等 |
| 音视频 | 一对一通话（LiveKit，需服务端配置） |
| 推送 | 个推 / FCM（需自行配置 Key） |

## 授权许可

本仓库采用 [MIT License](./LICENSE)。Copyright (c) 2026 Dr.Claw。
