import '../models/local_patient.dart';
import '../models/local_recording.dart';
import 'patient_display.dart';

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

  /// 查房录音配套文案：只补充录音里没有的患者基本信息，标明对应哪位患者。
  /// 音频本身由文件消息投递，正文不写下载地址、文件名等技术字段。
  static String wardRoundRecording(LocalPatient p, LocalRecording r) {
    final title = PatientDisplay.recordingTitle(r);
    final lines = <String>[
      '以下为该录音对应的患者信息，请结合录音内容生成病历相关材料。',
      '',
      ...buildPatientInfoLines(p),
    ];
    // 自定义标题便于多条录音时区分，非技术元数据
    if (title != '录音') {
      lines.add('- 录音标题：$title');
    }
    return lines.join('\n');
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
    add(fieldGender, p.gender);
    add(fieldAge, p.age);
    add(fieldDepartment, p.department);
    add(fieldBedNumber, p.bedNumber);
    add(fieldIdCard, p.idCard);
    add(fieldRemark, p.remark);
    return lines;
  }

  /// 上传用文件名：直接用录音标题（仅剔除路径非法字符，保留中文）。
  static String fileNameForRecording(LocalRecording r) {
    var title = PatientDisplay.recordingTitle(r)
        .replaceAll(PatientDisplay.invalidTitleChars, '_')
        .trim();
    if (title.isEmpty) title = '录音';
    return '$title.m4a';
  }
}
