import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:uuid/uuid.dart';

import '../../host/workbench_business_host.dart';
import '../../models/local_patient.dart';
import '../../services/patient_sync_service.dart';
import '../../store/workbench_store.dart';
import '../../workbench_routes.dart';

class PlatformPatientSearchLogic extends GetxController {
  final keywordCtrl = TextEditingController();
  final rows = <PlatformPatientDto>[].obs;
  final loading = false.obs;
  final searched = false.obs;
  final joiningId = ''.obs;
  String? errorText;

  WorkbenchBusinessHost? get _host {
    if (!Get.isRegistered<WorkbenchBusinessHost>()) return null;
    return Get.find<WorkbenchBusinessHost>();
  }

  @override
  void onClose() {
    keywordCtrl.dispose();
    super.onClose();
  }

  Future<void> search() async {
    final host = _host;
    if (host == null || host.doctorUserId.isEmpty) {
      IMViews.showToast('请先登录');
      return;
    }
    loading.value = true;
    errorText = null;
    searched.value = true;
    try {
      final page = await host.queryPlatformPatients(
        keyword: keywordCtrl.text.trim(),
        pageNum: 1,
        pageSize: 50,
      );
      rows.assignAll(page.rows);
    } catch (e) {
      rows.clear();
      errorText = '暂时查不到，请检查网络后重试';
      IMViews.showToast(errorText!);
    } finally {
      loading.value = false;
    }
  }

  LocalPatient? findInWorkset(PlatformPatientDto p) {
    final eno = p.eventNo.trim();
    final pid = p.patientId.trim();
    for (final local in WorkbenchStore.instance.listPatients()) {
      final leno = local.eventNo.trim();
      final lpid = local.patientId.trim();
      if (eno.isNotEmpty && pid.isNotEmpty && leno == eno && lpid == pid) {
        return local;
      }
      if (eno.isNotEmpty && pid.isEmpty && leno == eno) return local;
      if (pid.isNotEmpty && eno.isEmpty && lpid == pid) return local;
    }
    return null;
  }

  bool isInWorkset(PlatformPatientDto p) => findInWorkset(p) != null;

  Future<void> openExisting(PlatformPatientDto p) async {
    final local = findInWorkset(p);
    if (local == null) return;
    Get.offNamed(
      WorkbenchRoutes.patientDetail,
      arguments: {'localId': local.localId},
    );
  }

  Future<void> join(PlatformPatientDto p) async {
    if (!p.hasBusinessKey) {
      IMViews.showToast('院内数据不完整，暂时无法加入');
      return;
    }
    final existing = findInWorkset(p);
    if (existing != null) {
      final ok = await Get.dialog<bool>(
        CustomDialog(title: '已在我的患者中，是否打开？'),
      );
      if (ok == true) {
        await openExisting(p);
      }
      return;
    }

    final bed = p.bedNumber.trim();
    final title = bed.isEmpty
        ? '将${p.patientName}加入我的患者？'
        : '将${p.patientName}（${bed}床）加入我的患者？';
    final ok = await Get.dialog<bool>(CustomDialog(title: title));
    if (ok != true) return;

    final key = '${p.eventNo}|${p.patientId}';
    joiningId.value = key;
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final local = LocalPatient(
        localId: const Uuid().v4(),
        patientId: p.patientId,
        eventNo: p.eventNo,
        patientName: p.patientName,
        idCard: p.idCard,
        gender: p.gender,
        age: p.age,
        department: p.department,
        bedNumber: p.bedNumber,
        createdAt: now,
        updatedAt: now,
        syncStatus: PatientSyncStatus.dirty,
        source: 'from_platform',
        platformSyncedAt: now,
      );
      final saved = await PatientSyncService.instance.saveAndPush(local);
      IMViews.showToast('已加入');
      Get.offNamed(
        WorkbenchRoutes.patientDetail,
        arguments: {'localId': saved.localId},
      );
    } catch (_) {
      IMViews.showToast('加入失败，请稍后重试');
    } finally {
      joiningId.value = '';
    }
  }

  void showPreview(PlatformPatientDto p) {
    Get.bottomSheet(
      _PlatformPreviewSheet(
        patient: p,
        alreadyAdded: isInWorkset(p),
        onJoin: () {
          Get.back();
          join(p);
        },
        onOpen: () {
          Get.back();
          openExisting(p);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _PlatformPreviewSheet extends StatelessWidget {
  const _PlatformPreviewSheet({
    required this.patient,
    required this.alreadyAdded,
    required this.onJoin,
    required this.onOpen,
  });

  final PlatformPatientDto patient;
  final bool alreadyAdded;
  final VoidCallback onJoin;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 24.h),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E7ED),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '院内信息',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF303133),
              ),
            ),
            SizedBox(height: 12.h),
            _line('姓名', patient.patientName),
            _line('床号', patient.bedNumber),
            _line('性别', _gender(patient.gender)),
            _line('年龄', patient.age?.toString() ?? ''),
            _line('就诊号', patient.eventNo),
            _line('患者ID', patient.patientId),
            _line('科室', patient.department),
            SizedBox(height: 16.h),
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: alreadyAdded ? onOpen : onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7DD9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  alreadyAdded ? '打开患者' : '加入我的患者',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    final v = value.trim();
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 64.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF909399)),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF303133)),
            ),
          ),
        ],
      ),
    );
  }

  String _gender(int? g) {
    if (g == 1) return '男';
    if (g == 2) return '女';
    return '';
  }
}
