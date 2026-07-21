import 'package:get/get.dart';

import '../../models/local_patient.dart';
import '../../models/local_recording.dart';
import '../../store/workbench_store.dart';
import '../../workbench_routes.dart';

class PatientDetailLogic extends GetxController {
  final patient = Rxn<LocalPatient>();
  final recordings = <LocalRecording>[].obs;

  late final String localId;

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

  void toEdit() {
    Get.toNamed(WorkbenchRoutes.patientEdit, arguments: {'localId': localId})
        ?.then((_) => reload());
  }

  void startRecording() {
    Get.toNamed(
      WorkbenchRoutes.recordingSession,
      arguments: {'patientLocalId': localId},
    )?.then((_) => reload());
  }

  void openRecording(LocalRecording r) {
    Get.toNamed(
      WorkbenchRoutes.recordingDetail,
      arguments: {'localId': r.localId},
    )?.then((_) => reload());
  }
}
