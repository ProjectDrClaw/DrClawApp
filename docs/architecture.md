# 工程结构与技术栈

## 技术栈

| 类别 | 选型 |
| ---- | ---- |
| 框架 | Flutter / Dart（SDK `>=3.6.0 <4.0.0`） |
| 状态管理 / 路由 | GetX（`*_view` / `*_logic` / `*_binding`） |
| IM SDK | `flutter_openim_sdk` |
| 网络 | Dio |
| 本地存储 | Hive、SharedPreferences |
| 音视频 | LiveKit（`openim_live`） |
| 推送 | 个推 / FCM |
| 多环境 | `--dart-define=ENV` / `SERVER_HOST`（`EnvConfig`） |

本地模块名仍为 `openim_common` / `openim_live`（与 SDK 命名一致，暂不重命名）。

## 目录结构

```
DrClawApp/
├── lib/                 # 主应用：IM 壳、路由装配、BusinessWorkbench Host 实现
├── openim_common/       # 公共层：EnvConfig、Config、API、组件、多语言、推送
├── openim_live/         # 一对一音视频
├── business_workbench/  # 业务工作台：与 DrClawBusiness 对齐的患者/录音等（与 IM 壳解耦）
├── local_plugin/        # 本地插件（来电提醒等）
├── launcher_icon/       # 品牌图标 / 启动图源文件
├── android/             # 含团队统一签名 drclaw.jks
├── ios/
├── docs/
└── .github/workflows/   # 仅手动触发时打 APK
```

### 主应用 `lib/`

| 路径 | 作用 |
| ---- | ---- |
| `main.dart` / `app.dart` | 入口与 `ChatApp` |
| `core/` | `IMController`、`AppController` |
| `routes/` | 路由与导航（合并 `WorkbenchPages`） |
| `pages/splash/` | 启动与自动登录 |
| `pages/login/`、`register/`、`forget_password/` | 账号 |
| `pages/home/` | 首页 Tab（挂载业务工作台壳） |
| `pages/conversation/` | 会话 |
| `pages/chat/` | 聊天与群设置 |
| `pages/contacts/` | 通讯录 |
| `pages/mine/` | 我的 |
| `pages/global_search/` | 全局搜索 |
| `business_workbench/`（主工程侧） | 仅 `AppBusinessWorkbenchHost` 等适配，无业务页面 |

### 业务包 `business_workbench/`

与 **DrClawBusiness** 对齐的业务域：**医生工作集**（落库、按医生私有）+ **底座只读查询**（院内患者库/检验检查）、查房录音、本地 Hive；详见 [business_workbench_design.md](./business_workbench_design.md) §14。

### 公共模块要点

| 路径 | 作用 |
| ---- | ---- |
| `openim_common/.../env_config.dart` | 环境与默认 host |
| `openim_common/.../config.dart` | 运行时 URL、推送文案、地图 Key 等 |
| `openim_common/.../apis.dart` | REST API |

## 启动流程

1. `main` → `Config.init`（存储、Hive、Http 等）
2. `WorkbenchModule.init` + 注入 `WorkbenchHost`
3. `ChatApp` 注入 `IMController` / `PushController` / `CacheController`
4. 启动页：有 token 则自动登录，否则进登录页
5. 首页：会话 / 通讯录 / **业务工作台** / 我的

## 相关文档

配置细节见 [config.md](./config.md)；问题排查见 [faq.md](./faq.md)；业务工作台设计见 [business_workbench_design.md](./business_workbench_design.md)。
