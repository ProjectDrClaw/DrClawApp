import 'package:get/get.dart';

import 'host/workbench_host.dart';
import 'store/workbench_store.dart';
import 'workbench_routes.dart';

/// 业务工作台模块：初始化、用户切换、路由。
class WorkbenchModule {
  WorkbenchModule._();

  /// 主工程进入 Home 时调用。Hive 已由主工程 Config 初始化。
  static Future<void> init({WorkbenchHost? host}) async {
    if (host != null) {
      if (Get.isRegistered<WorkbenchHost>()) {
        Get.replace<WorkbenchHost>(host);
      } else {
        Get.put<WorkbenchHost>(host, permanent: true);
      }
    }
    final h = Get.isRegistered<WorkbenchHost>() ? Get.find<WorkbenchHost>() : null;
    final uid = h?.currentUserId ?? '';
    await WorkbenchStore.instance.switchUser(uid);
  }

  /// 登录态变化时切换本地分库
  static Future<void> onUserChanged(String? userId) async {
    await WorkbenchStore.instance.switchUser(userId ?? '');
  }

  static List<GetPage> get routes => WorkbenchRoutes.pages;
}
