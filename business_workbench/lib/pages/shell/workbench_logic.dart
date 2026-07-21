import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../host/workbench_host.dart';
import '../../store/workbench_store.dart';
import '../../workbench_module.dart';

class WorkbenchLogic extends GetxController {
  final patientCount = 0.obs;
  final recordingCount = 0.obs;
  final ready = false.obs;

  @override
  void onReady() {
    super.onReady();
    refreshCounts();
  }

  Future<bool> ensureLoggedIn() async {
    if (!Get.isRegistered<WorkbenchHost>()) {
      IMViews.showToast('业务模块未就绪');
      return false;
    }
    final uid = Get.find<WorkbenchHost>().currentUserId;
    if (uid.isEmpty) {
      IMViews.showToast('请先登录');
      return false;
    }
    if (!WorkbenchStore.instance.isReady ||
        WorkbenchStore.instance.userId != uid) {
      await WorkbenchModule.onUserChanged(uid);
    }
    ready.value = WorkbenchStore.instance.isReady;
    if (ready.value) refreshCounts();
    return ready.value;
  }

  void refreshCounts() {
    if (!WorkbenchStore.instance.isReady) {
      patientCount.value = 0;
      recordingCount.value = 0;
      ready.value = false;
      return;
    }
    ready.value = true;
    patientCount.value = WorkbenchStore.instance.listPatients().length;
    recordingCount.value = WorkbenchStore.instance.listRecordings().length;
  }
}
