import 'dart:io';

import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../models/local_patient.dart';
import '../../models/local_recording.dart';
import '../../services/patient_display.dart';
import '../../services/voice_recorder.dart';
import '../../store/workbench_store.dart';
import '../../widgets/recording_title_dialog.dart';

/// 查房录音会话（对齐旧库 RecordingSheet：暂停/继续 + 完成时改标题）
class RecordingSessionLogic extends GetxController {
  late final String patientLocalId;
  final patient = Rxn<LocalPatient>();
  final durationSec = 0.obs;
  /// idle | recording | paused | saving
  final phase = 'idle'.obs;
  final saving = false.obs;

  WorkbenchVoiceRecorder? _recorder;
  String? _recordingLocalId;
  String? _filePath;
  bool _finishing = false;

  static const maxSec = 30 * 60;

  bool get isRecording => phase.value == 'recording';
  bool get isPaused => phase.value == 'paused';
  bool get isActive => isRecording || isPaused;

  @override
  void onInit() {
    super.onInit();
    patientLocalId =
        (Get.arguments as Map?)?['patientLocalId'] as String? ?? '';
    patient.value = WorkbenchStore.instance.getPatient(patientLocalId);
  }

  @override
  void onClose() {
    _recorder?.dispose();
    super.onClose();
  }

  /// 中间麦克风：未开始→开始；录音中→暂停；已暂停→继续
  Future<void> toggleMic() async {
    if (saving.value || _finishing) return;
    if (phase.value == 'idle') {
      await _start();
    } else if (phase.value == 'recording') {
      await _pause();
    } else if (phase.value == 'paused') {
      await _resume();
    }
  }

  Future<void> _start() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      IMViews.showToast('需要麦克风权限');
      return;
    }
    final p = WorkbenchStore.instance.getPatient(patientLocalId);
    patient.value = p;
    if (p == null || p.deleted) {
      IMViews.showToast('患者无效');
      return;
    }

    _recordingLocalId = const Uuid().v4();
    final dir = await WorkbenchStore.instance.voiceDirForPatient(patientLocalId);
    _filePath = WorkbenchVoiceRecorder.joinPath(
      dir.path,
      WorkbenchVoiceRecorder.suggestFileName(_recordingLocalId!),
    );

    _recorder = WorkbenchVoiceRecorder(
      maxRecordSec: maxSec,
      onDuration: (d) {
        if (durationSec.value != d) {
          durationSec.value = d;
        }
      },
      onMaxReached: () {
        if (!_finishing) {
          finish();
        }
      },
    );
    try {
      durationSec.value = 0;
      await _recorder!.start(_filePath!);
      phase.value = 'recording';
    } catch (e) {
      await _recorder?.dispose();
      _recorder = null;
      phase.value = 'idle';
      IMViews.showToast('开始录音失败：$e');
    }
  }

  Future<void> _pause() async {
    await _recorder?.pause();
    phase.value = 'paused';
  }

  Future<void> _resume() async {
    await _recorder?.resume();
    phase.value = 'recording';
  }

  /// 完成录音：停止 → 编辑标题 → 保存
  Future<void> finish() async {
    if (_finishing || saving.value) return;
    if (!isActive && phase.value != 'idle') return;
    if (phase.value == 'idle') {
      IMViews.showToast('请先开始录音');
      return;
    }

    _finishing = true;
    try {
      final result = await _recorder?.stop();
      await _recorder?.dispose();
      _recorder = null;
      phase.value = 'idle';

      if (result == null || result.durationSec < 1) {
        IMViews.showToast('录音过短，未保存');
        _cleanupFile(result?.path ?? _filePath);
        return;
      }

      final title = await showRecordingTitleDialog(
        initialTitle: PatientDisplay.defaultRecordingTitle(),
      );
      if (title == null) {
        // 取消标题 → 丢弃本次录音
        _cleanupFile(result.path);
        durationSec.value = 0;
        return;
      }

      saving.value = true;
      final now = DateTime.now().millisecondsSinceEpoch;
      final file = File(result.path);
      final size = await file.exists() ? await file.length() : 0;
      final rec = LocalRecording(
        localId: _recordingLocalId!,
        patientLocalId: patientLocalId,
        filePath: result.path,
        durationSec: result.durationSec,
        fileSize: size,
        title: title,
        createdAt: now,
        updatedAt: now,
      );
      await WorkbenchStore.instance.saveRecording(rec);
      IMViews.showToast('录音已保存');
      Get.back(result: true);
    } catch (e) {
      IMViews.showToast('保存录音失败：$e');
    } finally {
      saving.value = false;
      _finishing = false;
    }
  }

  Future<void> discard() async {
    if (saving.value) return;
    if (isActive) {
      final ok = await Get.dialog<bool>(
        CustomDialog(title: '删除本次录音？'),
      );
      if (ok != true) return;
      await _recorder?.cancel();
      await _recorder?.dispose();
      _recorder = null;
      phase.value = 'idle';
      durationSec.value = 0;
    }
    Get.back();
  }

  Future<void> cancel() => discard();

  void _cleanupFile(String? path) {
    if (path == null || path.isEmpty) return;
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }
}
