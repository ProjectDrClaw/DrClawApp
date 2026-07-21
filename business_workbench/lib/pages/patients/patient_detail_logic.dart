import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../models/local_patient.dart';
import '../../models/local_recording.dart';
import '../../store/workbench_store.dart';
import '../../workbench_routes.dart';

class PatientDetailLogic extends GetxController {
  final patient = Rxn<LocalPatient>();
  final recordings = <LocalRecording>[].obs;

  late final String localId;
  bool _dirty = false;

  @override
  void onInit() {
    super.onInit();
    localId = (Get.arguments as Map?)?['localId'] as String? ?? '';
  }

  @override
  void onReady() {
    super.onReady();
    reload();
  }

  void reload() {
    patient.value = WorkbenchStore.instance.getPatient(localId);
    recordings.assignAll(
      WorkbenchStore.instance.listRecordings(patientLocalId: localId),
    );
  }

  void _reloadIfDirty(dynamic result) {
    if (result == true) {
      _dirty = true;
      SchedulerBinding.instance.addPostFrameCallback((_) => reload());
    }
  }

  /// 供返回列表时判断是否需要刷新。
  bool get isDirty => _dirty;

  void toEdit() {
    Get.toNamed(WorkbenchRoutes.patientEdit, arguments: {'localId': localId})
        ?.then(_reloadIfDirty);
  }

  void startRecording() {
    Get.toNamed(
      WorkbenchRoutes.recordingSession,
      arguments: {'patientLocalId': localId},
    )?.then(_reloadIfDirty);
  }

  void openRecording(LocalRecording r) {
    Get.toNamed(
      WorkbenchRoutes.recordingDetail,
      arguments: {'localId': r.localId},
    )?.then(_reloadIfDirty);
  }
}
