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

### 5. Android 签名相关？

仓库已包含团队统一证书 `android/app/drclaw.jks` 与 `key.properties`，开发/正式构建共用。克隆后即可构建。

若提示 `INSTALL_FAILED_UPDATE_INCOMPATIBLE`，说明手机上已有其它签名的同包名应用，先卸载再安装。

### 6. 构建时 `media_kit` 从 GitHub 下载失败？

依赖会从 GitHub Releases 拉取原生 jar。网络不稳时可重试；若 `build/media_kit_libs_android_video/v1.1.7/` 下 jar 已存在且完整，通常可跳过重下。

### 7. Kotlin 报 `different roots`（C: Pub 缓存 vs D: 工程）？

工程已在 `android/gradle.properties` 关闭 Kotlin 增量编译。若仍出现，执行 `flutter clean` 后重试。

### 8. Android debug 可运行，release 白屏？

可尝试：

```bash
flutter build apk --no-shrink
```

### 9. 必须开启混淆时怎么办？

保留 OpenIM SDK 相关类，例如：

```proguard
-keep class io.openim.**{*;}
-keep class open_im_sdk.**{*;}
-keep class open_im_sdk_callback.**{*;}
```

### 10. Android 包装不到模拟器？

工程默认 `abiFilters` 含 `arm64-v8a`、`x86_64`。若仍失败，按模拟器架构调整 `android/app/build.gradle`。

### 11. iOS release / Archive 报错？

架构设为 arm64，然后：

```bash
flutter clean && flutter pub get
cd ios && rm -f Podfile.lock && rm -rf Pods && pod install
```

连接真机后再 Archive。

### 12. iOS 最低版本？

13.0

### 13. 地图或离线推送不可用？

见 [config.md](./config.md) 中对应章节；默认仍为占位配置。

### 14. 如何更新应用图标？

替换 `launcher_icon/` 下源图后执行图标与启动图生成命令，见 [config.md](./config.md#品牌资源)。

### 15. 如何打 GitHub Release APK？

在 GitHub 创建 Release，或手动运行工作流 `Release Android`。详见 [config.md](./config.md#github-release-自动打包)。
