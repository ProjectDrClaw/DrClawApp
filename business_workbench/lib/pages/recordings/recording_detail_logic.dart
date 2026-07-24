import 'dart:io';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openim_common/openim_common.dart';

import '../../host/workbench_host.dart';
import '../../models/local_patient.dart';
import '../../models/local_recording.dart';
import '../../services/patient_context_formatter.dart';
import '../../services/patient_display.dart';
import '../../store/workbench_store.dart';
import '../../widgets/recording_title_dialog.dart';

class RecordingDetailLogic extends GetxController {
  final recording = Rxn<LocalRecording>();
  final patient = Rxn<LocalPatient>();
  final sending = false.obs;
  final playing = false.obs;

  late final String localId;
  final _player = AudioPlayer();
  bool _dirty = false;

  bool get isDirty => _dirty;

  String get sendButtonLabel {
    final r = recording.value;
    if (r == null) return '发送';
    return PatientDisplay.recordingSendButtonLabel(
      r,
      sending: sending.value,
    );
  }

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

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }

  void reload() {
    final r = WorkbenchStore.instance.getRecording(localId);
    recording.value = r;
    if (r != null) {
      patient.value = WorkbenchStore.instance.getPatient(r.patientLocalId);
    }
  }

  Future<void> togglePlay() async {
    final r = recording.value;
    if (r == null) return;
    if (!File(r.filePath).existsSync()) {
      IMViews.showToast('录音文件不存在');
      return;
    }
    if (playing.value) {
      await _player.stop();
      playing.value = false;
      return;
    }
    await _player.setFilePath(r.filePath);
    playing.value = true;
    await _player.play();
    playing.value = false;
  }

  Future<void> delete() async {
    final ok = await Get.dialog<bool>(CustomDialog(title: '删除该录音？'));
    if (ok != true) return;
    await WorkbenchStore.instance.softDeleteRecording(localId, deleteFile: true);
    IMViews.showToast('已删除');
    Get.back(result: true);
  }

  Future<void> editTitle() async {
    final r = recording.value;
    if (r == null) return;
    final existing = r.title?.trim();
    final title = await showRecordingTitleDialog(
      initialTitle: (existing != null && existing.isNotEmpty)
          ? existing
          : PatientDisplay.defaultRecordingTitle(
              DateTime.fromMillisecondsSinceEpoch(r.createdAt),
            ),
    );
    if (title == null) return;
    r.title = title;
    r.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await WorkbenchStore.instance.saveRecording(r);
    recording.refresh();
    _dirty = true;
    IMViews.showToast('标题已更新');
  }

  Future<void> sendToAgent() async {
    if (!Get.isRegistered<WorkbenchHost>()) {
      IMViews.showToast('业务模块未就绪');
      return;
    }
    final host = Get.find<WorkbenchHost>();
    if (host.currentUserId.isEmpty) {
      IMViews.showToast('请先登录');
      return;
    }
    final r = recording.value;
    final p = patient.value;
    if (r == null || p == null || p.deleted) {
      IMViews.showToast('患者或录音无效');
      return;
    }
    if (r.durationSec < 1) {
      IMViews.showToast('录音时长过短');
      return;
    }
    if (!File(r.filePath).existsSync()) {
      IMViews.showToast('录音文件不存在');
      return;
    }

    // 已发送成功后再点：确认整单重发（文本 + 文件）
    if (r.status == RecordingStatus.sent) {
      final ok = await Get.dialog<bool>(
        CustomDialog(
          title: '确定再发一次吗？聊天里可能会出现重复的患者说明和录音。',
        ),
      );
      if (ok != true) return;
    }

    // 已选过发送对象时二次确认；未选则先选好友
    final target = await host.prepareAssistantForSend();
    if (target == null || target.isEmpty) return;

    sending.value = true;
    final now = DateTime.now().millisecondsSinceEpoch;
    r.status = RecordingStatus.sending;
    r.updatedAt = now;
    await WorkbenchStore.instance.saveRecording(r);
    recording.refresh();

    try {
      await host.openAgentChat();
      // 先发文件再发患者补充文案（正文不写下载地址等技术信息）
      final fileName = PatientContextFormatter.fileNameForRecording(r);
      await host.sendFileToAgent(filePath: r.filePath, fileName: fileName);
      final text = PatientContextFormatter.wardRoundRecording(p, r);
      await host.sendTextToAgent(text);
      r.status = RecordingStatus.sent;
      r.sentAt = DateTime.now().millisecondsSinceEpoch;
      r.updatedAt = r.sentAt!;
      await WorkbenchStore.instance.saveRecording(r);
      recording.refresh();
      _dirty = true;
      IMViews.showToast('已发送');
    } catch (e) {
      r.status = RecordingStatus.failed;
      r.updatedAt = DateTime.now().millisecondsSinceEpoch;
      await WorkbenchStore.instance.saveRecording(r);
      recording.refresh();
      _dirty = true;
      IMViews.showToast('没发出去，请检查网络后重试');
    } finally {
      sending.value = false;
    }
  }
}
