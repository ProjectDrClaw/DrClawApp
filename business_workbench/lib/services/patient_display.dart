import '../models/local_patient.dart';
import '../models/local_recording.dart';

/// 列表/详情展示文案（对齐旧库 patientDisplay.ts / 录音行 formatDate·formatDuration）
class PatientDisplay {
  PatientDisplay._();

  static const fieldEventNo = '就诊号';
  static const fieldPatientId = '患者ID';
  static const fieldBedNumber = '床号';

  /// 删除确认（对齐旧库 getPatientDeleteConfirmMessage 本地自建文案）
  static const deletePatientConfirm = '确定删除该患者吗？手机里的录音也会一并删除。';

  /// 标题行：姓名 · 性别 · 年龄（旧 formatPatientProfileLine）
  static String profileLine(LocalPatient p) {
    final parts = <String>[];
    final name = p.patientName.trim();
    if (name.isNotEmpty) parts.add(name);
    final g = genderLabel(p.gender);
    if (g != null) parts.add(g);
    if (p.age != null) parts.add('${p.age}岁');
    if (parts.isEmpty) return '未命名患者';
    return parts.join(' · ');
  }

  /// 副标题：就诊号 · 患者ID · 科室 · 床号（旧 formatPatientListMeta）
  static String listMeta(LocalPatient p) {
    final parts = <String>[];
    final eno = p.eventNo.trim();
    if (eno.isNotEmpty) parts.add('$fieldEventNo $eno');
    final pid = p.patientId.trim();
    if (pid.isNotEmpty) parts.add('$fieldPatientId $pid');
    final dept = p.department.trim();
    if (dept.isNotEmpty) parts.add(dept);
    final bed = p.bedNumber.trim();
    if (bed.isNotEmpty) parts.add('$fieldBedNumber $bed');
    return parts.join(' · ');
  }

  static String? genderLabel(int? gender) {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return null;
    }
  }

  /// 录音标题展示
  static String recordingTitle(LocalRecording r) {
    final t = r.title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return '录音';
  }

  /// 默认标题：`M月D日HH时mm分`（对齐旧库 getDefaultTitle）
  static String defaultRecordingTitle([DateTime? at]) {
    final d = at ?? DateTime.now();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}月${d.day}日$hh时$mm分';
  }

  /// 标题不可用于文件名的字符（对齐旧库 INVALID_PATH_CHARS）
  static final invalidTitleChars = RegExp(r'[/\\:*?"<>|]');

  static String? recordingTitleError(String title) {
    if (invalidTitleChars.hasMatch(title)) {
      return '标题包含不能用于文件名的字符：/ \\ : * ? " < > |';
    }
    return null;
  }

  /// 旧 formatDuration：`m分s秒` / `s秒`
  static String formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return m > 0 ? '$m分$s秒' : '$s秒';
  }

  /// 旧 formatDate：`M月D日 HH:mm`（本地毫秒时间戳）
  static String formatDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}月${d.day}日 $hh:$mm';
  }

  /// 录音列表副标题：患者资料行 · 时间
  static String recordingMeta(LocalPatient? patient, LocalRecording r) {
    final who = patient == null ? '未知患者' : profileLine(patient);
    return '$who · ${formatDate(r.createdAt)}';
  }

  /// 发送状态短标签（列表角标）
  static String recordingStatusLabel(LocalRecording r) {
    switch (r.status) {
      case RecordingStatus.local:
        return '未发送';
      case RecordingStatus.sending:
        return '发送中';
      case RecordingStatus.sent:
        return '已发送';
      case RecordingStatus.failed:
        return '发送失败';
    }
  }

  /// 患者同步状态短标签
  static String patientSyncLabel(LocalPatient p) {
    switch (p.syncStatus) {
      case PatientSyncStatus.localOnly:
        return '仅本机';
      case PatientSyncStatus.synced:
        return '已同步';
      case PatientSyncStatus.dirty:
        return '待同步';
      case PatientSyncStatus.error:
        return '同步失败';
    }
  }

  /// 详情页状态说明（失败时提示重试策略）
  static String? recordingStatusHint(LocalRecording r) {
    switch (r.status) {
      case RecordingStatus.local:
        return null;
      case RecordingStatus.sending:
        return '正在发送，请稍候…';
      case RecordingStatus.sent:
        return r.sentAt != null
            ? '已于 ${formatDate(r.sentAt!)} 发送'
            : '发送成功';
      case RecordingStatus.failed:
        return '刚才没发出去。点下方按钮会重新发送患者说明和录音。';
    }
  }

  /// 详情页主按钮文案
  static String recordingSendButtonLabel(LocalRecording r, {required bool sending}) {
    if (sending) return '发送中…';
    switch (r.status) {
      case RecordingStatus.failed:
        return '再试一次';
      case RecordingStatus.sent:
        return '再发一次';
      case RecordingStatus.sending:
        return '发送中…';
      case RecordingStatus.local:
        return '发送';
    }
  }
}
