/// 应用运行环境配置。
///
/// 通过编译参数切换，无需改代码：
/// ```bash
/// flutter run --dart-define=ENV=dev
/// flutter run --dart-define=ENV=prod
/// flutter run --dart-define=ENV=dev --dart-define=SERVER_HOST=10.110.177.132
/// ```
class EnvConfig {
  EnvConfig._();

  /// 环境名：`dev` | `prod`
  static const String name = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// 可选：覆盖当前环境的服务端 host（IP 或域名）
  static const String serverHostOverride =
      String.fromEnvironment('SERVER_HOST', defaultValue: '');

  /// 可选：覆盖 Business 服务根地址
  static const String businessBaseUrlOverride =
      String.fromEnvironment('BUSINESS_BASE_URL', defaultValue: '');

  /// Business 对外 appId（须在 Business bootstrap-app-ids 内）
  static const String businessAppId =
      String.fromEnvironment('BUSINESS_APP_ID', defaultValue: 'mobile-app');

  /// 开发环境默认内网地址
  static const String devHost = '10.110.177.132';

  /// 生产环境默认域名（上线前修改，或用 SERVER_HOST 覆盖）
  static const String prodHost = 'your-prod-domain';

  static bool get isDev => name == 'dev';

  static bool get isProd => name == 'prod';

  /// 当前环境默认 host（应用内 DataSp 服务端配置仍可覆盖）
  static String get host {
    if (serverHostOverride.isNotEmpty) {
      return serverHostOverride;
    }
    return isProd ? prodHost : devHost;
  }
}
