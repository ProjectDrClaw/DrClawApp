import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:uuid/uuid.dart';

import '../../models/local_patient.dart';
import '../../services/patient_sync_service.dart';
import '../../store/workbench_store.dart';

class PatientEditLogic extends GetxController {
  late final TextEditingController nameCtrl;
  late final TextEditingController bedCtrl;
  late final TextEditingController patientIdCtrl;
  late final TextEditingController eventNoCtrl;
  late final TextEditingController deptCtrl;
  late final TextEditingController idCardCtrl;
  late final TextEditingController ageCtrl;
  late final TextEditingController remarkCtrl;

  String? editingLocalId;
  int? gender;

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    bedCtrl = TextEditingController();
    patientIdCtrl = TextEditingController();
    eventNoCtrl = TextEditingController();
    deptCtrl = TextEditingController();
    idCardCtrl = TextEditingController();
    ageCtrl = TextEditingController();
    remarkCtrl = TextEditingController();

    final args = Get.arguments as Map?;
    final localId = args?['localId'] as String?;
    if (localId != null) {
      editingLocalId = localId;
      final p = WorkbenchStore.instance.getPatient(localId);
      if (p != null) {
        nameCtrl.text = p.patientName;
        bedCtrl.text = p.bedNumber;
        patientIdCtrl.text = p.patientId;
        eventNoCtrl.text = p.eventNo;
        deptCtrl.text = p.department;
        idCardCtrl.text = p.idCard;
        ageCtrl.text = p.age?.toString() ?? '';
        remarkCtrl.text = p.remark;
        gender = p.gender;
      }
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    bedCtrl.dispose();
    patientIdCtrl.dispose();
    eventNoCtrl.dispose();
    deptCtrl.dispose();
    idCardCtrl.dispose();
    ageCtrl.dispose();
    remarkCtrl.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      IMViews.showToast('请填写患者姓名');
      return;
    }
    final pid = patientIdCtrl.text.trim();
    final eno = eventNoCtrl.text.trim();
    if (pid.isEmpty && eno.isEmpty) {
      IMViews.showToast('患者ID与就诊号至少填写一项');
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final age = int.tryParse(ageCtrl.text.trim());
    late LocalPatient toSave;
    if (editingLocalId != null) {
      final old = WorkbenchStore.instance.getPatient(editingLocalId!);
      if (old == null) {
        IMViews.showToast('患者不存在');
        return;
      }
      toSave = old.copyWith(
        patientName: name,
        bedNumber: bedCtrl.text.trim(),
        patientId: pid,
        eventNo: eno,
        department: deptCtrl.text.trim(),
        idCard: idCardCtrl.text.trim(),
        age: age,
        gender: gender,
        remark: remarkCtrl.text.trim(),
        updatedAt: now,
        syncStatus: PatientSyncStatus.dirty,
        source: old.source.isNotEmpty ? old.source : 'manual',
      );
    } else {
      toSave = LocalPatient(
        localId: const Uuid().v4(),
        patientName: name,
        bedNumber: bedCtrl.text.trim(),
        patientId: pid,
        eventNo: eno,
        department: deptCtrl.text.trim(),
        idCard: idCardCtrl.text.trim(),
        age: age,
        gender: gender,
        remark: remarkCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
        syncStatus: PatientSyncStatus.dirty,
        source: 'manual',
      );
    }
    try {
      await PatientSyncService.instance.saveAndPush(toSave);
      IMViews.showToast('已保存');
    } catch (_) {
      IMViews.showToast('已保存到本机，云端同步失败');
    }
    Get.back(result: true);
  }
}
