# 配置说明

- [多环境服务端](#多环境服务端)
- [Android 签名](#android-签名)
- [品牌资源](#品牌资源)
- [离线推送](#离线推送)
- [地图](#地图)
- [iOS 补充](#ios-补充)

## 多环境服务端

配置文件：`openim_common/lib/src/env_config.dart`。默认 `ENV=dev`。

| 环境 | 默认 host | 示例 |
| ---- | --------- | ---- |
| `dev` | `10.110.177.132` | `flutter run --dart-define=ENV=dev` |
| `prod` | `your-prod-domain`（需改） | `flutter run --dart-define=ENV=prod` |

临时覆盖 host：

```bash
flutter run --dart-define=ENV=dev --dart-define=SERVER_HOST=10.110.177.132
```

优先级：**应用内 DataSp 服务端配置** > `SERVER_HOST` > 环境默认 host。

IP 模式默认端口：

| 用途 | 端口 |
| ---- | ---- |
| IM WebSocket | `10001` |
| IM API | `10002` |
| Auth | `10008` |
| Chat Token | `10009` |

域名模式：`https` / `wss`，路径 `/api`、`/chat`、`/msg_gateway`。

> 开发机与 `10.110.177.132` 不在同一网络时端口会不可达，联调时请自行切换网络。

## Android 签名

开发版（debug/profile）与正式版（release）**使用同一套正式证书**，避免覆盖安装时签名不一致。

| 项 | 值 |
| -- | -- |
| 证书文件 | `android/app/drclaw.jks`（已入库，团队共用） |
| 配置文件 | `android/app/key.properties`（已入库，团队共用） |
| 别名 | `drclaw` |
| 算法 | RSA 2048 / SHA256withRSA / PKCS12 |
| 有效期 | 36500 天 |
| SHA-1 | `1B:2F:F2:61:16:9F:D1:30:3E:80:99:5D:FD:9C:96:0C:18:D4:7B:2E` |
| SHA-256 | `20:B8:D0:A4:32:7C:B9:83:46:C7:07:38:E4:A5:F2:5C:65:33:CA:BF:DC:16:E6:21:B8:52:60:D1:AF:25:D4:F5` |

克隆仓库后即可直接 `flutter run` / `flutter build apk`，开发与正式构建使用同一签名。

> **安全：** 证书与密码随仓库分发，仓库必须保持**私有**。若曾公开过，请立即轮换证书。仍建议另地备份 `drclaw.jks`。

### GitHub Release 自动打包

工作流 [`.github/workflows/release-android.yml`](../.github/workflows/release-android.yml)：

- **触发：** 发布 GitHub Release，或 Actions 里手动 Run workflow  
- **日常 push/PR 不执行**
- **签名：** 直接使用仓库内 `drclaw.jks` + `key.properties`（无需再配 Secrets）
- **产物：** 上传为 Actions Artifact；若由 Release 触发，同时附加到该 Release

手动触发时可选择 `ENV=prod|dev`。

## 品牌资源

与 Expo 工程 **DrClawApp** 的 `assets/images` 对齐。源文件目录：`launcher_icon/`。

| 文件 | 用途 |
| ---- | ---- |
| `icon.svg` | 设计源 |
| `app-icon.png` | 主图标 |
| `android-icon-foreground.png` | Android 自适应前景 |
| `android-icon-monochrome.png` | Android 单色图标 |
| `splash-icon.png` | 原生启动图 |

品牌色：`#1d5db0`。

更新图标 / 启动图后执行：

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

应用内登录/启动 Logo：`openim_common/assets/images/ic_login_logo.webp`、`ic_splash_logo.webp`。

## 离线推送

需换成自有账号后方可正式使用。

### 中国大陆：个推

按 [Getui](https://getui.com/) 文档配置后修改：

- iOS Key：`openim_common/lib/src/controller/push_controller.dart`
- Android：`android/app/build.gradle` 中 `manifestPlaceholders`（个推及各厂商通道）

多厂商见个推[厂商文档](https://docs.getui.com/getui/mobile/vendor/vendor_open/)。

### 海外：FCM

替换：

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `openim_common/lib/src/controller/firebase_options.dart`

未自定义时，离线推送标题为应用名，描述为「你收到了一条新消息」。

## 地图

高德 Key：在 `openim_common/lib/src/config.dart` 修改 `webKey`、`webServerKey`。参考 [高德开放平台](https://lbs.amap.com/)。

## iOS 补充

- Bundle ID：`com.drclaw.app`
- App Group：`group.com.drclaw.app.rtc`（需在苹果开发者后台创建）
- 推送需配置对应证书与描述文件
