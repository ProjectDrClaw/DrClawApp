import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/local_patient.dart';
import '../models/local_recording.dart';

/// 按 OpenIM userID 分库的本地存储
class WorkbenchStore {
  WorkbenchStore._();
  static final WorkbenchStore instance = WorkbenchStore._();

  String _userId = '';
  Box<String>? _patientBox;
  Box<String>? _recordingBox;

  String get userId => _userId;
  bool get isReady => _userId.isNotEmpty && _patientBox != null;

  Future<void> switchUser(String userId) async {
    final next = userId.trim();
    if (next == _userId && _patientBox != null && _recordingBox != null) {
      return;
    }
    await _patientBox?.close();
    await _recordingBox?.close();
    _patientBox = null;
    _recordingBox = null;
    _userId = next;
    if (_userId.isEmpty) return;

    _patientBox = await Hive.openBox<String>('wb_patients_$_userId');
    _recordingBox = await Hive.openBox<String>('wb_recordings_$_userId');
  }

  /// 仅统计数量，避免为刷新角标做全量反序列化。
  int countPatients({bool includeDeleted = false}) {
    final box = _patientBox;
    if (box == null) return 0;
    if (includeDeleted) return box.length;
    var n = 0;
    for (final raw in box.values) {
      if (!_isDeletedRaw(raw)) n++;
    }
    return n;
  }

  List<LocalPatient> listPatients({bool includeDeleted = false}) {
    final box = _patientBox;
    if (box == null) return [];
    final list = box.values
        .map((e) => LocalPatient.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .where((e) => includeDeleted || !e.deleted)
        .toList();
    list.sort((a, b) {
      final bedCmp = a.bedNumber.compareTo(b.bedNumber);
      if (bedCmp != 0) return bedCmp;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  /// 患者 id → 实体，供录音列表一次加载后复用。
  Map<String, LocalPatient> patientMap({bool includeDeleted = false}) {
    final map = <String, LocalPatient>{};
    for (final p in listPatients(includeDeleted: includeDeleted)) {
      map[p.localId] = p;
    }
    return map;
  }

  LocalPatient? getPatient(String localId) {
    final raw = _patientBox?.get(localId);
    if (raw == null) return null;
    return LocalPatient.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> savePatient(LocalPatient patient) async {
    final box = _patientBox;
    if (box == null) throw StateError('工作台未登录或未初始化');
    await box.put(patient.localId, jsonEncode(patient.toJson()));
  }

  Future<void> softDeletePatient(String localId, {bool cascadeRecordings = true}) async {
    final p0 = getPatient(localId);
    if (p0 == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await savePatient(p0.copyWith(deleted: true, updatedAt: now));
    if (cascadeRecordings) {
      for (final r in listRecordings(patientLocalId: localId)) {
        await softDeleteRecording(r.localId, deleteFile: true);
      }
    }
  }

  int countRecordings({bool includeDeleted = false}) {
    final box = _recordingBox;
    if (box == null) return 0;
    if (includeDeleted) return box.length;
    var n = 0;
    for (final raw in box.values) {
      if (!_isDeletedRaw(raw)) n++;
    }
    return n;
  }

  List<LocalRecording> listRecordings({String? patientLocalId, bool includeDeleted = false}) {
    final box = _recordingBox;
    if (box == null) return [];
    final list = box.values
        .map((e) => LocalRecording.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .where((e) => includeDeleted || !e.deleted)
        .where((e) => patientLocalId == null || e.patientLocalId == patientLocalId)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// 从原始 JSON 字符串快速判断 deleted，避免完整 fromJson。
  static bool _isDeletedRaw(String raw) {
    // 兼容 "deleted":true / "deleted": true
    final i = raw.indexOf('"deleted"');
    if (i < 0) return false;
    final slice = raw.substring(i, (i + 24).clamp(0, raw.length));
    return slice.contains('true');
  }

  LocalRecording? getRecording(String localId) {
    final raw = _recordingBox?.get(localId);
    if (raw == null) return null;
    return LocalRecording.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveRecording(LocalRecording recording) async {
    final box = _recordingBox;
    if (box == null) throw StateError('工作台未登录或未初始化');
    await box.put(recording.localId, jsonEncode(recording.toJson()));
  }

  Future<void> softDeleteRecording(String localId, {bool deleteFile = false}) async {
    final r = getRecording(localId);
    if (r == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    r.deleted = true;
    r.updatedAt = now;
    await saveRecording(r);
    if (deleteFile) {
      try {
        final f = File(r.filePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  /// 录音文件目录：Documents/workbench/{userId}/voice/{patientLocalId}/
  Future<Directory> voiceDirForPatient(String patientLocalId) async {
    if (_userId.isEmpty) throw StateError('未登录');
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(docs.path, 'workbench', _userId, 'voice', patientLocalId),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
