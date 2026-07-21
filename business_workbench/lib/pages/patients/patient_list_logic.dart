import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../models/local_patient.dart';
import '../../store/workbench_store.dart';
import '../../workbench_routes.dart';

class PatientListLogic extends GetxController {
  final patients = <LocalPatient>[].obs;
  final keyword = ''.obs;

  @override
  void onReady() {
    super.onReady();
    reload();
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

  void _reloadAfterPop(dynamic result) {
    if (result == true) {
      SchedulerBinding.instance.addPostFrameCallback((_) => reload());
    }
  }

  void toCreate() =>
      Get.toNamed(WorkbenchRoutes.patientEdit)?.then(_reloadAfterPop);

  void toDetail(LocalPatient p) => Get.toNamed(
        WorkbenchRoutes.patientDetail,
        arguments: {'localId': p.localId},
      )?.then(_reloadAfterPop);

  Future<void> deletePatient(LocalPatient p) async {
    await WorkbenchStore.instance.softDeletePatient(p.localId);
    IMViews.showToast('已删除');
    reload();
  }
}
