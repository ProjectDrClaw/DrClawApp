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

1. 复制 `android/app/key.properties.example` → `android/app/key.properties`
2. 准备 `drclaw-release.jks`（或自有 keystore）
3. 填写别名与密码

`key.properties` 与 `*.jks` 已加入 `.gitignore`，**勿提交**。

| 构建类型 | 行为 |
| -------- | ---- |
| debug | 无 `key.properties` 时用 Android 默认 debug 签名 |
| release | 必须有 `key.properties`，否则构建失败 |

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
