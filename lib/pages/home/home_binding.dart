import 'package:business_workbench/business_workbench.dart';
import 'package:get/get.dart';

import '../../core/workbench/app_business_workbench_host.dart';
import '../contacts/contacts_logic.dart';
import '../conversation/conversation_logic.dart';
import '../mine/mine_logic.dart';
import 'home_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeLogic());
    Get.lazyPut(() => ConversationLogic());
    Get.lazyPut(() => ContactsLogic());
    Get.lazyPut(() => MineLogic());
    if (!Get.isRegistered<WorkbenchHost>()) {
      Get.put<WorkbenchHost>(AppBusinessWorkbenchHost(), permanent: true);
    }
  }
}
