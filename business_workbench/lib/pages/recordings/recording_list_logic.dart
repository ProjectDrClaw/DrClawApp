import 'package:get/get.dart';

import '../../models/local_patient.dart';
import '../../models/local_recording.dart';
import '../../store/workbench_store.dart';
import '../../workbench_routes.dart';

class RecordingListLogic extends GetxController {
  final items = <({LocalRecording recording, LocalPatient? patient})>[].obs;
  final keyword = ''.obs;

  @override
  void onReady() {
    super.onReady();
    reload();
  }

  void reload() {
    final list = WorkbenchStore.instance.listRecordings();
    final mapped = list
        .map((r) => (
              recording: r,
              patient: WorkbenchStore.instance.getPatient(r.patientLocalId),
            ))
        .toList();
    final k = keyword.value.trim();
    if (k.isEmpty) {
      items.assignAll(mapped);
      return;
    }
    items.assignAll(
      mapped.where((e) {
        final p = e.patient;
        final title = e.recording.title ?? '';
        return title.contains(k) ||
            (p?.patientName.contains(k) ?? false) ||
            (p?.bedNumber.contains(k) ?? false) ||
            (p?.patientId.contains(k) ?? false) ||
            (p?.eventNo.contains(k) ?? false);
      }),
    );
  }

  void onSearch(String v) {
    keyword.value = v;
    reload();
  }

  void openDetail(LocalRecording r) {
    Get.toNamed(
      WorkbenchRoutes.recordingDetail,
      arguments: {'localId': r.localId},
    )?.then((_) => reload());
  }
}
