/// 本地患者（医生工作集缓存；P2 再与 Business 同步）
class LocalPatient {
  LocalPatient({
    required this.localId,
    this.patientId = '',
    this.eventNo = '',
    required this.patientName,
    this.idCard = '',
    this.gender,
    this.age,
    this.department = '',
    this.bedNumber = '',
    this.remark = '',
    required this.createdAt,
    required this.updatedAt,
    this.deleted = false,
  });

  final String localId;
  String patientId;
  String eventNo;
  String patientName;
  String idCard;
  int? gender;
  int? age;
  String department;
  String bedNumber;
  String remark;
  int createdAt;
  int updatedAt;
  bool deleted;

  bool get hasBusinessKey =>
      patientId.trim().isNotEmpty || eventNo.trim().isNotEmpty;

  /// 列表标题：姓名 · 性别 · 年龄（与 PatientDisplay.profileLine 一致）
  String get displayTitle {
    final parts = <String>[];
    final name = patientName.trim();
    if (name.isNotEmpty) parts.add(name);
    if (gender == 1) {
      parts.add('男');
    } else if (gender == 2) {
      parts.add('女');
    }
    if (age != null) parts.add('$age岁');
    if (parts.isEmpty) return '未命名患者';
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'patientId': patientId,
        'eventNo': eventNo,
        'patientName': patientName,
        'idCard': idCard,
        'gender': gender,
        'age': age,
        'department': department,
        'bedNumber': bedNumber,
        'remark': remark,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deleted': deleted,
      };

  factory LocalPatient.fromJson(Map<String, dynamic> json) => LocalPatient(
        localId: json['localId'] as String,
        patientId: (json['patientId'] as String?) ?? '',
        eventNo: (json['eventNo'] as String?) ?? '',
        patientName: (json['patientName'] as String?) ?? '',
        idCard: (json['idCard'] as String?) ?? '',
        gender: json['gender'] as int?,
        age: json['age'] as int?,
        department: (json['department'] as String?) ?? '',
        bedNumber: (json['bedNumber'] as String?) ?? '',
        remark: (json['remark'] as String?) ?? '',
        createdAt: (json['createdAt'] as int?) ?? 0,
        updatedAt: (json['updatedAt'] as int?) ?? 0,
        deleted: (json['deleted'] as bool?) ?? false,
      );

  LocalPatient copyWith({
    String? patientId,
    String? eventNo,
    String? patientName,
    String? idCard,
    int? gender,
    int? age,
    String? department,
    String? bedNumber,
    String? remark,
    int? updatedAt,
    bool? deleted,
  }) {
    return LocalPatient(
      localId: localId,
      patientId: patientId ?? this.patientId,
      eventNo: eventNo ?? this.eventNo,
      patientName: patientName ?? this.patientName,
      idCard: idCard ?? this.idCard,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      department: department ?? this.department,
      bedNumber: bedNumber ?? this.bedNumber,
      remark: remark ?? this.remark,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }
}
