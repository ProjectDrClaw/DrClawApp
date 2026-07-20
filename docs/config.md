# 配置说明

- [服务端地址](#服务端地址)
- [离线推送](#离线推送)
- [地图](#地图)

## 服务端地址

修改 `openim_common/lib/src/config.dart` 中的 `_host`：

```dart
static const _host = "your-server-ip or your-domain";
```

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
