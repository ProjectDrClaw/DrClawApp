import 'package:get/get.dart';

import 'pages/patients/patient_detail_logic.dart';
import 'pages/patients/patient_detail_page.dart';
import 'pages/patients/patient_edit_logic.dart';
import 'pages/patients/patient_edit_page.dart';
import 'pages/patients/patient_list_logic.dart';
import 'pages/patients/patient_list_page.dart';
import 'pages/recordings/recording_detail_logic.dart';
import 'pages/recordings/recording_detail_page.dart';
import 'pages/recordings/recording_list_logic.dart';
import 'pages/recordings/recording_list_page.dart';
import 'pages/recordings/recording_session_logic.dart';
import 'pages/recordings/recording_session_page.dart';

class WorkbenchRoutes {
  WorkbenchRoutes._();

  static const patients = '/workbench/patients';
  static const patientEdit = '/workbench/patients/edit';
  static const patientDetail = '/workbench/patients/detail';
  static const recordings = '/workbench/recordings';
  static const recordingDetail = '/workbench/recordings/detail';
  static const recordingSession = '/workbench/recordings/session';

  static final pages = <GetPage>[
    GetPage(
      name: patients,
      page: () => const PatientListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PatientListLogic())),
    ),
    GetPage(
      name: patientEdit,
      page: () => const PatientEditPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PatientEditLogic())),
    ),
    GetPage(
      name: patientDetail,
      page: () => const PatientDetailPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PatientDetailLogic())),
    ),
    GetPage(
      name: recordings,
      page: () => const RecordingListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => RecordingListLogic())),
    ),
    GetPage(
      name: recordingDetail,
      page: () => const RecordingDetailPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => RecordingDetailLogic())),
    ),
    GetPage(
      name: recordingSession,
      page: () => const RecordingSessionPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => RecordingSessionLogic())),
    ),
  ];
}
