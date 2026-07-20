# 常见问题

### 1. 是否支持多语言？

支持，默认跟随系统语言（中文、英文）。

### 2. 支持哪些平台？

目前支持 Android 与 iOS。

### 3. 如何切换开发 / 生产环境？

```bash
flutter run --dart-define=ENV=dev
flutter run --dart-define=ENV=prod --dart-define=SERVER_HOST=your-domain
```

详见 [config.md](./config.md#多环境服务端)。

### 4. 连不上 `10.110.177.132`？

确认本机已切换到可访问该内网的网络，且服务端已监听 `10001/10002/10008/10009`。

### 5. Android release 构建报缺少 key.properties？

按 [config.md](./config.md#android-签名) 配置本地签名；`key.properties` 不要提交到 Git。

### 6. Android debug 可运行，release 白屏？

可尝试：

```bash
flutter build apk --no-shrink
```

或按 `android/app/build.gradle` 中 release 配置关闭压缩。

### 7. 必须开启混淆时怎么办？

保留 OpenIM SDK 相关类，例如：

```proguard
-keep class io.openim.**{*;}
-keep class open_im_sdk.**{*;}
-keep class open_im_sdk_callback.**{*;}
```

### 8. Android 包装不到模拟器？

工程默认 `abiFilters` 含 `arm64-v8a`、`x86_64`。若仍失败，按模拟器架构调整 `android/app/build.gradle`。

### 9. iOS release / Archive 报错？

架构设为 arm64，然后：

```bash
flutter clean && flutter pub get
cd ios && rm -f Podfile.lock && rm -rf Pods && pod install
```

连接真机后再 Archive。

### 10. iOS 最低版本？

13.0

### 11. 地图或离线推送不可用？

见 [config.md](./config.md) 中对应章节；默认仍为占位配置。

### 12. 如何更新应用图标？

替换 `launcher_icon/` 下源图后执行图标与启动图生成命令，见 [config.md](./config.md#品牌资源)。
