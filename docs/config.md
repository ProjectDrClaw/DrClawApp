# 配置说明

- [应用标识](#应用标识)
- [服务端地址](#服务端地址)
- [Android 签名](#android-签名)
- [离线推送](#离线推送)
- [地图](#地图)

## 应用标识

| 项 | 值 |
| -- | -- |
| 展示名 | Dr.Claw |
| Dart 包名 | `drclaw` |
| Android / iOS | `com.drclaw.app` |
| 品牌色 | `#1d5db0`（与 DrClawApp 一致） |

### 图片资源

品牌图与 Expo 工程 `D:\Workspace\DrClawApp\assets\images` 对齐，源文件在 `launcher_icon/`：

| 文件 | 用途 |
| ---- | ---- |
| `app-icon.png` / `icon.svg` | 主图标（设计源为 svg） |
| `android-icon-foreground.png` | Android 自适应前景 |
| `android-icon-monochrome.png` | Android 单色图标 |
| `splash-icon.png` | 原生启动图 |

更新后执行：

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

## Android 签名

1. 复制 `android/app/key.properties.example` 为 `android/app/key.properties`
2. 使用 `keytool` 生成 `drclaw-release.jks`（或沿用本地已有 keystore）
3. 在 `key.properties` 中填写密码与别名（`key.properties` / `*.jks` 已加入 `.gitignore`，勿提交）

说明：

- **debug**：无 `key.properties` 时使用 Android 默认 debug 签名；有配置时使用 release keystore
- **release**：必须存在 `key.properties`，否则构建失败
- 本地开发机可保留自己的 `key.properties` 与 jks，勿把密码写进仓库

## 服务端地址

修改 `openim_common/lib/src/config.dart` 中的 `_host`：

```dart
static const _host = "10.110.177.132";
```

> 当前开发环境默认已指向该地址；若需切换环境，直接修改 `_host` 或通过应用内服务端配置覆盖。

默认端口（未改服务端时）：

| 用途 | 端口 / 路径（IP 模式） |
| ---- | ---------------------- |
| IM WebSocket | `10001` |
| IM API | `10002` |
| Auth | `10008` |
| Chat Token | `10009` |

也可在应用内写入服务端配置覆盖上述默认值。

## 离线推送

当前为客户端集成方案。

### 1. 中国大陆：个推（[Getui](https://getui.com/)）

按个推文档完成 iOS / Android 配置后，修改：

**iOS Key** — `openim_common/lib/src/controller/push_controller.dart`

```dart
const appID = 'your-app-id';
const appKey = 'your-app-key';
const appSecret = 'your-app-secret';
```

**Android** — `android/app/build.gradle` 中的 `manifestPlaceholders`：

```gradle
manifestPlaceholders = [
    GETUI_APPID    : "",
    XIAOMI_APP_ID  : "",
    XIAOMI_APP_KEY : "",
    MEIZU_APP_ID   : "",
    MEIZU_APP_KEY  : "",
    HUAWEI_APP_ID  : "",
    OPPO_APP_KEY   : "",
    OPPO_APP_SECRET: "",
    VIVO_APP_ID    : "",
    VIVO_APP_KEY   : "",
    HONOR_APP_ID   : "",
]
```

多厂商通道请参考个推[厂商文档](https://docs.getui.com/getui/mobile/vendor/vendor_open/)。

### 2. 海外：FCM

按 [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging) 替换：

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `openim_common/lib/src/controller/firebase_options.dart`

### 推送文案

发送消息时可设置 `OfflinePushInfo`（标题、描述等）。未自定义时，标题默认为应用名，描述默认为「你收到了一条新消息」。

## 地图

需配置高德（AMap）Key，参考 [高德开放平台](https://lbs.amap.com/)。在 `openim_common/lib/src/config.dart` 中修改：

```dart
static const webKey = 'webKey';
static const webServerKey = 'webServerKey';
```
