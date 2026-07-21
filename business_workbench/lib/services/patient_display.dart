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
}
