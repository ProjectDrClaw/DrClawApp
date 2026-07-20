# 常见问题

### 1. 是否支持多语言？

支持，默认跟随系统语言（当前含中文、英文）。

### 2. 支持哪些平台？

目前支持 Android 与 iOS。

### 3. Android debug 可运行，release 白屏？

Release 默认开启混淆/压缩。可尝试：

```bash
flutter build apk --no-shrink
```

或在 `android/app/build.gradle` 的 `release` 中关闭压缩（按项目实际 Gradle 写法调整）。

### 4. 必须开启混淆时怎么办？

在混淆规则中保留 OpenIM SDK 相关类，例如：

```proguard
-keep class io.openim.**{*;}
-keep class open_im_sdk.**{*;}
-keep class open_im_sdk_callback.**{*;}
```

### 5. Android 安装包无法安装到模拟器？

工程可能过滤了部分 ABI。若需在模拟器运行，在 NDK `abiFilters` 中按需加入架构（如 `x86_64`），以 `android/app/build.gradle` 现有配置为准。

### 6. iOS release / Archive 报错？

将架构设置为 arm64，然后：

```bash
flutter clean
flutter pub get
cd ios
rm -f Podfile.lock
rm -rf Pods
pod install
```

连接真机后再 Archive。

### 7. iOS 最低版本？

13.0

### 8. 地图或离线推送不可用？

见 [配置说明](./config.md)。
