# 工程结构与技术栈

## 应用标识

| 标识 | 值 |
| ---- | -- |
| 展示名 | Dr.Claw |
| Dart 包名 | `drclaw` |
| Android / iOS 应用 ID | `com.drclaw.app` |
| 版本 | `0.1.0+1` |

## 技术栈

| 类别 | 选型 |
| ---- | ---- |
| 框架 | Flutter / Dart（SDK `>=3.6.0 <4.0.0`） |
| 状态管理 / 路由 | GetX |
| IM SDK | `flutter_openim_sdk` |
| 网络 | Dio |
| 本地存储 | Hive、SharedPreferences |
| 音视频 | LiveKit（`openim_live`） |
| 推送 | 个推 / FCM |

页面按 GetX 约定拆分为 `*_view.dart` / `*_logic.dart` / `*_binding.dart`。

## 目录结构

```
DrClawAppFlutter/
├── lib/                 # 主应用：页面、路由、IM 控制器
├── openim_common/       # 公共层：Config、API、组件、多语言、推送
├── openim_live/         # 一对一音视频通话
├── local_plugin/        # 本地插件（如来电提醒）
├── android/ / ios/      # 原生工程
└── docs/                # 项目文档
```

### `lib/` 主要模块

| 路径 | 作用 |
| ---- | ---- |
| `main.dart` / `app.dart` | 入口与 `ChatApp` 初始化 |
| `core/` | `IMController`、`AppController` 等 |
| `routes/` | 路由表与导航封装 |
| `pages/splash/` | 启动与自动登录 |
| `pages/login/`、`register/`、`forget_password/` | 账号流程 |
| `pages/home/` | 首页 Tab 壳 |
| `pages/conversation/` | 会话列表 |
| `pages/chat/` | 聊天与群设置 |
| `pages/contacts/` | 通讯录、好友/群 |
| `pages/mine/` | 我的、设置 |
| `pages/global_search/` | 全局搜索 |

## 启动流程

1. `main.dart` → `Config.init`（存储、Hive、Http 等）
2. `ChatApp` 注入 `IMController` / `PushController` / `CacheController`
3. 启动页根据本地 token 自动登录或进入登录页
4. 登录成功后进入首页（会话 / 通讯录 / 我的）

## 相关配置

服务端地址、推送与地图 Key 见 [config.md](./config.md)。
