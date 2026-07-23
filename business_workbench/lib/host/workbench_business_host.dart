/// Business API Host：由主工程实现，业务包不直连拼 URL。
abstract class WorkbenchBusinessHost {
  String get businessBaseUrl;
  String get businessAppId;

  /// 当前医生 OpenIM userID（请求头 doctorUserId）
  String get doctorUserId;

  Future<DoctorPatientPage> listMyPatients({
    int pageNum = 1,
    int pageSize = 100,
    String? keyword,
  });

  Future<DoctorPatientDto> saveMyPatient(DoctorPatientSave input);

  Future<void> deleteMyPatient({required String id});

  /// P2b：院内患者库只读查询
  Future<PlatformPatientPage> queryPlatformPatients({
    int pageNum = 1,
    int pageSize = 20,
    String? keyword,
    String? eventNo,
    String? patientId,
  });
}

class DoctorPatientPage {
  DoctorPatientPage({
    required this.rows,
    required this.pageNum,
    required this.pageSize,
    required this.total,
  });

  final List<DoctorPatientDto> rows;
  final int pageNum;
  final int pageSize;
  final int total;
}

class PlatformPatientPage {
  PlatformPatientPage({
    required this.rows,
    required this.pageNum,
    required this.pageSize,
    required this.total,
  });

  final List<PlatformPatientDto> rows;
  final int pageNum;
  final int pageSize;
  final int total;
}

class PlatformPatientDto {
  PlatformPatientDto({
    this.eventNo = '',
    this.patientId = '',
    required this.patientName,
    this.idCard = '',
    this.gender,
    this.age,
    this.department = '',
    this.bedNumber = '',
  });

  final String eventNo;
  final String patientId;
  final String patientName;
  final String idCard;
  final int? gender;
  final int? age;
  final String department;
  final String bedNumber;

  bool get hasBusinessKey =>
      eventNo.trim().isNotEmpty || patientId.trim().isNotEmpty;
}

class DoctorPatientDto {
  DoctorPatientDto({
    required this.id,
    this.eventNo = '',
    this.patientId = '',
    required this.patientName,
    this.idCard = '',
    this.gender,
    this.age,
    this.department = '',
    this.bedNumber = '',
    this.remark = '',
    this.source = 'manual',
    this.platformSnapshotAtMs,
    this.createTimeMs,
    this.updateTimeMs,
  });

  final String id;
  final String eventNo;
  final String patientId;
  final String patientName;
  final String idCard;
  /// App 侧：1 男 / 2 女；空未知
  final int? gender;
  final int? age;
  final String department;
  final String bedNumber;
  final String remark;
  final String source;
  final int? platformSnapshotAtMs;
  final int? createTimeMs;
  final int? updateTimeMs;
}

class DoctorPatientSave {
  DoctorPatientSave({
    this.id,
    this.eventNo = '',
    this.patientId = '',
    required this.patientName,
    this.idCard = '',
    this.gender,
    this.age,
    this.department = '',
    this.bedNumber = '',
    this.remark = '',
    this.source = 'manual',
  });

  final String? id;
  final String eventNo;
  final String patientId;
  final String patientName;
  final String idCard;
  final int? gender;
  final int? age;
  final String department;
  final String bedNumber;
  final String remark;
  final String source;
}
