import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  static Future init(Function() runApp) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      cachePath = '$path/';
      await DataSp.init();
      await Hive.initFlutter(path);
      MediaKit.ensureInitialized();
      HttpUtil.init();
    } catch (_) {}

    runApp();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var brightness = Platform.isAndroid ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
    ));

    final packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;
  }

  static late String _appName;

  static late String cachePath;
  static const uiW = 375.0;
  static const uiH = 812.0;

  static const double textScaleFactor = 1.0;

  static const discoverPageURL = 'discover';
  static const allowSendMsgNotFriend = '1';
  // amap key
  static const webKey = 'webKey';
  static const webServerKey = 'webServerKey';
  static const locationHost = 'http://location.your-domain';

  static OfflinePushInfo get offlinePushInfo => OfflinePushInfo(
        title: _appName,
        desc: StrRes.offlineMessage,
        iOSBadgeCount: true,
        iOSPushSound: 'default',
      );

  static const friendScheme = "com.drclaw.app/addFriend/";
  static const groupScheme = "com.drclaw.app/joinGroup/";

  static const _ipRegex =
      '((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)';

  static bool _isIP(String host) => RegExp(_ipRegex).hasMatch(host);

  /// 当前生效的服务端 host：应用内配置 > 编译期环境配置
  static String get serverIp {
    final server = DataSp.getServerConfig();
    final ip = server?['serverIP'] as String?;
    if (ip != null && ip.isNotEmpty) {
      return ip;
    }
    return EnvConfig.host;
  }

  static String get chatTokenUrl {
    final server = DataSp.getServerConfig();
    final url = server?['chatTokenUrl'] as String?;
    if (url != null && url.isNotEmpty) {
      return url;
    }
    final host = serverIp;
    return _isIP(host) ? "http://$host:10009" : "https://$host/chat";
  }

  static String get appAuthUrl {
    final server = DataSp.getServerConfig();
    final url = server?['authUrl'] as String?;
    if (url != null && url.isNotEmpty) {
      return url;
    }
    final host = serverIp;
    return _isIP(host) ? "http://$host:10008" : "https://$host/chat";
  }

  static String get imApiUrl {
    final server = DataSp.getServerConfig();
    final url = server?['apiUrl'] as String?;
    if (url != null && url.isNotEmpty) {
      return url;
    }
    final host = serverIp;
    return _isIP(host) ? 'http://$host:10002' : "https://$host/api";
  }

  static String get imWsUrl {
    final server = DataSp.getServerConfig();
    final url = server?['wsUrl'] as String?;
    if (url != null && url.isNotEmpty) {
      return url;
    }
    final host = serverIp;
    return _isIP(host) ? "ws://$host:10001" : "wss://$host/msg_gateway";
  }

  static int get logLevel {
    final server = DataSp.getServerConfig();
    final level = server?['logLevel'] as String?;
    // 生产环境默认少打日志
    if (level == null) {
      return EnvConfig.isProd ? 3 : 5;
    }
    return int.parse(level);
  }
}
