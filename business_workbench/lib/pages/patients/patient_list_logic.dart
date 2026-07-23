import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../models/local_patient.dart';
import '../../services/patient_sync_service.dart';
import '../../store/workbench_store.dart';
import '../../widgets/add_patient_sheet.dart';
import '../../workbench_routes.dart';

class PatientListLogic extends GetxController {
  final patients = <LocalPatient>[].obs;
  final keyword = ''.obs;
  final syncing = false.obs;

  @override
  void onReady() {
    super.onReady();
    reload();
    // 进入列表尝试同步（失败静默，保留本地）
    refreshFromServer(silent: true);
  }

  void reload() {
    final all = WorkbenchStore.instance.listPatients();
    final k = keyword.value.trim();
    if (k.isEmpty) {
      patients.assignAll(all);
      return;
    }
    patients.assignAll(
      all.where((p) {
        return p.patientName.contains(k) ||
            p.bedNumber.contains(k) ||
            p.patientId.contains(k) ||
            p.eventNo.contains(k) ||
            p.department.contains(k);
      }),
    );
  }

  void onSearch(String v) {
    keyword.value = v;
    reload();
  }

  Future<void> refreshFromServer({bool silent = false}) async {
    if (syncing.value) return;
    if (!PatientSyncService.instance.isAvailable) {
      if (!silent) IMViews.showToast('未登录或业务服务未配置');
      reload();
      return;
    }
    syncing.value = true;
    try {
      await PatientSyncService.instance.syncFromServer();
      reload();
      if (!silent) IMViews.showToast('已同步');
    } catch (e) {
      reload();
      if (!silent) IMViews.showToast('同步失败，已显示本地数据');
    } finally {
      syncing.value = false;
    }
  }

  void _reloadAfterPop(dynamic result) {
    if (result == true) {
      SchedulerBinding.instance.addPostFrameCallback((_) => reload());
    }
  }

  Future<void> toCreate() async {
    final action = await showAddPatientSheet();
    if (action == AddPatientAction.platformSearch) {
      toPlatformSearch();
    } else if (action == AddPatientAction.manualCreate) {
      toManualCreate();
    }
  }

  void toPlatformSearch() =>
      Get.toNamed(WorkbenchRoutes.platformSearch)?.then((_) => reload());

  void toManualCreate() =>
      Get.toNamed(WorkbenchRoutes.patientEdit)?.then(_reloadAfterPop);

  void toDetail(LocalPatient p) => Get.toNamed(
        WorkbenchRoutes.patientDetail,
        arguments: {'localId': p.localId},
      )?.then(_reloadAfterPop);

  Future<void> deletePatient(LocalPatient p) async {
    try {
      await PatientSyncService.instance.deleteAndPush(p);
      IMViews.showToast('已删除');
    } catch (_) {
      IMViews.showToast('已从本机删除');
    }
    reload();
  }
}
