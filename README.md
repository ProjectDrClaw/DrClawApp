# DrClawAppFlutter

Dr.Claw Flutter 客户端（Android / iOS）。基于 [OpenIM Flutter Demo](https://github.com/openimsdk/openim-flutter-demo) **v3.8.3+235**（`flutter_openim_sdk` `^3.8.3+hotfix.12`，上游提交 `06480b8`）改造。

仓库：https://github.com/9999-12-31/DrClawAppFlutter.git

| 项 | 值 |
| -- | -- |
| 展示名 | Dr.Claw |
| Dart 包名 | `drclaw` |
| 应用 ID | `com.drclaw.app` |
| 版本 | `0.1.0+1` |
| 品牌色 | `#1d5db0` |

## 文档

| 文档 | 说明 |
| ---- | ---- |
| [docs/architecture.md](./docs/architecture.md) | 工程结构与技术栈 |
| [docs/config.md](./docs/config.md) | 多环境、签名、图标、推送、地图 |
| [docs/faq.md](./docs/faq.md) | 常见问题 |
| [docs/README.md](./docs/README.md) | 文档索引与上线检查清单 |

## 环境要求

- Flutter **3.32.8**、JDK **17**
- Android：minSdk **23**
- iOS：13.0+（需 macOS + Xcode）
- 可用的 OpenIM Server（开发环境默认内网地址见下方）

## 快速开始

```bash
git clone https://github.com/9999-12-31/DrClawAppFlutter.git
cd DrClawAppFlutter
flutter pub get

# 开发环境（默认 ENV=dev，host=10.110.177.132）
flutter run --dart-define=ENV=dev
```

切换生产或临时改 host：

```bash
flutter run --dart-define=ENV=prod --dart-define=SERVER_HOST=your-domain
```

Android 正式签名见 [docs/config.md](./docs/config.md)；本地需自行准备 `android/app/key.properties`（勿提交）。

## 构建

```bash
flutter build apk                                    # Android
flutter build apk --dart-define=ENV=prod             # 指定环境
flutter build ipa --dart-define=ENV=prod             # iOS，需 macOS
```

GitHub Actions **仅在发布 Release（或手动触发工作流）时**构建 Android APK，日常提交代码不会跑构建。详见 [docs/config.md](./docs/config.md#github-release-自动打包)。

## 能力概览

账号、好友/黑名单、群组、多类型消息与会话、一对一音视频（LiveKit）、推送（个推/FCM，需自备 Key）。

## 许可

[MIT License](./LICENSE)。Copyright (c) 2026 Dr.Claw。
