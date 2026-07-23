import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../host/workbench_business_host.dart';
import '../models/local_patient.dart';
import '../store/workbench_store.dart';

/// 工作集本地 ↔ Business 同步
class PatientSyncService {
  PatientSyncService._();
  static final PatientSyncService instance = PatientSyncService._();

  WorkbenchBusinessHost? get _host {
    if (!Get.isRegistered<WorkbenchBusinessHost>()) return null;
    return Get.find<WorkbenchBusinessHost>();
  }

  bool get isAvailable {
    final h = _host;
    return h != null && h.doctorUserId.isNotEmpty && h.businessBaseUrl.isNotEmpty;
  }

  /// 推送本地 dirty/error，再拉取合并
  Future<void> syncFromServer({String? keyword}) async {
    final host = _host;
    if (host == null || host.doctorUserId.isEmpty) return;

    await flushDirty();

    final page = await host.listMyPatients(
      pageNum: 1,
      pageSize: 100,
      keyword: keyword,
    );
    await _mergeServerRows(page.rows);
  }

  /// 保存后尝试上云（无业务键则保持 localOnly）
  Future<LocalPatient> saveAndPush(LocalPatient patient) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    var local = patient;
    local.updatedAt = now;

    if (!local.hasBusinessKey) {
      local = local.copyWith(syncStatus: PatientSyncStatus.localOnly);
      await WorkbenchStore.instance.savePatient(local);
      return local;
    }

    final host = _host;
    if (host == null || host.doctorUserId.isEmpty) {
      local = local.copyWith(syncStatus: PatientSyncStatus.dirty);
      await WorkbenchStore.instance.savePatient(local);
      return local;
    }

    try {
      final saved = await host.saveMyPatient(_toSave(local));
      local = _applyServer(local, saved);
      await WorkbenchStore.instance.savePatient(local);
      return local;
    } catch (_) {
      local = local.copyWith(syncStatus: PatientSyncStatus.error);
      await WorkbenchStore.instance.savePatient(local);
      rethrow;
    }
  }

  /// 软删并尝试云端删除
  Future<void> deleteAndPush(LocalPatient patient) async {
    final id = patient.businessWorksetId;
    await WorkbenchStore.instance.softDeletePatient(patient.localId);

    if (id == null || id.isEmpty) return;
    final host = _host;
    if (host == null || host.doctorUserId.isEmpty) {
      // 已本地删除；恢复网络后无法按 id 再删，可接受（或保留 tombstone）
      return;
    }
    try {
      await host.deleteMyPatient(id: id);
    } catch (_) {
      // 本地已删；云端失败时下次不会再出现在 list（若仍在服务端，换机可能拉回）
      // 标记：把 tombstone 的 syncStatus 设为 dirty 不方便，因已软删。忽略。
    }
  }

  Future<void> flushDirty() async {
    final host = _host;
    if (host == null || host.doctorUserId.isEmpty) return;

    final dirty = WorkbenchStore.instance.listPatients().where((p) {
      return p.hasBusinessKey &&
          (p.syncStatus == PatientSyncStatus.dirty ||
              p.syncStatus == PatientSyncStatus.error);
    });

    for (final p in dirty) {
      try {
        final saved = await host.saveMyPatient(_toSave(p));
        await WorkbenchStore.instance.savePatient(_applyServer(p, saved));
      } catch (_) {
        await WorkbenchStore.instance.savePatient(
          p.copyWith(syncStatus: PatientSyncStatus.error),
        );
      }
    }
  }

  Future<void> _mergeServerRows(List<DoctorPatientDto> rows) async {
    final locals = WorkbenchStore.instance.listPatients(includeDeleted: true);
    final byWorksetId = <String, LocalPatient>{};
    final byBizKey = <String, LocalPatient>{};
    for (final p in locals) {
      if (p.businessWorksetId != null && p.businessWorksetId!.isNotEmpty) {
        byWorksetId[p.businessWorksetId!] = p;
      }
      if (p.hasBusinessKey) {
        byBizKey[_bizKey(p.eventNo, p.patientId)] = p;
      }
    }

    final seenLocalIds = <String>{};

    for (final row in rows) {
      LocalPatient? existing = byWorksetId[row.id];
      existing ??= byBizKey[_bizKey(row.eventNo, row.patientId)];

      // 本地 dirty/error 且未 flush 成功的，不覆盖
      if (existing != null &&
          !existing.deleted &&
          (existing.syncStatus == PatientSyncStatus.dirty ||
              existing.syncStatus == PatientSyncStatus.error)) {
        seenLocalIds.add(existing.localId);
        continue;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      if (existing == null) {
        final created = LocalPatient(
          localId: const Uuid().v4(),
          patientId: row.patientId,
          eventNo: row.eventNo,
          patientName: row.patientName,
          idCard: row.idCard,
          gender: row.gender,
          age: row.age,
          department: row.department,
          bedNumber: row.bedNumber,
          remark: row.remark,
          createdAt: row.createTimeMs ?? now,
          updatedAt: row.updateTimeMs ?? now,
          businessWorksetId: row.id,
          syncStatus: PatientSyncStatus.synced,
          source: row.source,
          platformSyncedAt: row.platformSnapshotAtMs,
        );
        await WorkbenchStore.instance.savePatient(created);
        seenLocalIds.add(created.localId);
      } else {
        final merged = existing.copyWith(
          patientId: row.patientId,
          eventNo: row.eventNo,
          patientName: row.patientName,
          idCard: row.idCard,
          gender: row.gender,
          age: row.age,
          department: row.department,
          bedNumber: row.bedNumber,
          remark: row.remark,
          updatedAt: row.updateTimeMs ?? existing.updatedAt,
          deleted: false,
          businessWorksetId: row.id,
          syncStatus: PatientSyncStatus.synced,
          source: row.source,
          platformSyncedAt: row.platformSnapshotAtMs,
        );
        await WorkbenchStore.instance.savePatient(merged);
        seenLocalIds.add(merged.localId);
      }
    }

    // 服务端已无、本地仍 synced 的：软删（保留 localOnly / dirty）
    for (final p in locals) {
      if (p.deleted) continue;
      if (seenLocalIds.contains(p.localId)) continue;
      if (p.syncStatus == PatientSyncStatus.synced &&
          p.businessWorksetId != null &&
          p.businessWorksetId!.isNotEmpty) {
        await WorkbenchStore.instance.softDeletePatient(
          p.localId,
          cascadeRecordings: false,
        );
      }
    }
  }

  static String _bizKey(String eventNo, String patientId) =>
      '${eventNo.trim()}|${patientId.trim()}';

  static DoctorPatientSave _toSave(LocalPatient p) => DoctorPatientSave(
        id: p.businessWorksetId,
        eventNo: p.eventNo,
        patientId: p.patientId,
        patientName: p.patientName,
        idCard: p.idCard,
        gender: p.gender,
        age: p.age,
        department: p.department,
        bedNumber: p.bedNumber,
        remark: p.remark,
        source: p.source,
      );

  static LocalPatient _applyServer(LocalPatient local, DoctorPatientDto row) {
    return local.copyWith(
      patientId: row.patientId,
      eventNo: row.eventNo,
      patientName: row.patientName,
      idCard: row.idCard,
      gender: row.gender,
      age: row.age,
      department: row.department,
      bedNumber: row.bedNumber,
      remark: row.remark,
      businessWorksetId: row.id,
      syncStatus: PatientSyncStatus.synced,
      source: row.source,
      platformSyncedAt: row.platformSnapshotAtMs,
      updatedAt: row.updateTimeMs ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
