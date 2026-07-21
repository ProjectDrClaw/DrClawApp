import '../models/local_patient.dart';
import '../models/local_recording.dart';

/// 拼接到对话框的文案（对齐旧库 DrClawApp：patientDisplay / messages）
class PatientContextFormatter {
  PatientContextFormatter._();

  static const fieldEventNo = '就诊号';
  static const fieldPatientId = '患者ID';
  static const fieldPatientName = '姓名';
  static const fieldGender = '性别';
  static const fieldAge = '年龄';
  static const fieldDepartment = '科室';
  static const fieldBedNumber = '床号';
  static const fieldIdCard = '身份证';
  static const fieldRemark = '备注';

  /// 选患者预填（旧：buildPatientContextText）
  static String currentPatient(LocalPatient p) {
    return [
      '以下为患者信息，请结合这些信息回答我的问题：',
      '',
      ...buildPatientInfoLines(p),
      '',
    ].join('\n');
  }

  /// 发送录音（旧：buildRecordingMessageText）
  static String wardRoundRecording(LocalPatient p, LocalRecording r) {
    final title =
        (r.title?.trim().isNotEmpty == true) ? r.title!.trim() : '录音';
    return [
      '请根据以下患者信息和录音文件，生成病历相关内容。',
      '',
      '患者信息：',
      ...buildPatientInfoLines(p),
      '',
      '录音信息：',
      '- 录音标题：$title',
      '- 录音时长：${r.durationSec} 秒',
      '- 录音时间：${_formatRecordingTime(r.createdAt)}',
    ].join('\n');
  }

  /// 患者字段行（旧：buildPatientInfoLines，空值省略）
  static List<String> buildPatientInfoLines(LocalPatient p) {
    final lines = <String>[];
    void add(String label, String? value) {
      final v = value?.trim() ?? '';
      if (v.isEmpty) return;
      lines.add('- $label：$v');
    }

    add(fieldEventNo, p.eventNo);
    add(fieldPatientId, p.patientId);
    add(fieldPatientName, p.patientName);
    final genderLabel = _genderLabel(p.gender);
    if (genderLabel != null) {
      lines.add('- $fieldGender：$genderLabel');
    }
    if (p.age != null) {
      lines.add('- $fieldAge：${p.age}');
    }
    add(fieldDepartment, p.department);
    add(fieldBedNumber, p.bedNumber);
    add(fieldIdCard, p.idCard);
    add(fieldRemark, p.remark);
    return lines;
  }

  static String? _genderLabel(int? gender) {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return null;
    }
  }

  static String _formatRecordingTime(int ms) {
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.year}年${t.month}月${t.day}日 $hh:$mm';
  }

  static String fileNameForRecording(LocalPatient p, LocalRecording r) {
    final bed = p.bedNumber.trim().isEmpty ? '无床号' : '${p.bedNumber}床';
    final name = p.patientName.trim().isEmpty ? '患者' : p.patientName.trim();
    return '${bed}_${name}_${r.durationSec}s.m4a';
  }
}
