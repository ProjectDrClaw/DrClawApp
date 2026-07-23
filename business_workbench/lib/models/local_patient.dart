/// 本地同步状态
enum PatientSyncStatus { localOnly, synced, dirty, error }

/// 本地患者（医生工作集缓存；可与 Business 同步）
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
    this.businessWorksetId,
    this.syncStatus = PatientSyncStatus.localOnly,
    this.source = 'manual',
    this.platformSyncedAt,
  });

  final String localId;
  String patientId;
  String eventNo;
  String patientName;
  String idCard;
  /// 性别字符串（如 男/女）
  String? gender;
  /// 年龄字符串
  String? age;
  String department;
  String bedNumber;
  String remark;
  int createdAt;
  int updatedAt;
  bool deleted;

  /// Business 工作集主键
  String? businessWorksetId;
  PatientSyncStatus syncStatus;
  /// manual / from_platform
  String source;
  int? platformSyncedAt;

  bool get hasBusinessKey =>
      patientId.trim().isNotEmpty || eventNo.trim().isNotEmpty;

  /// 列表标题：姓名 · 性别 · 年龄（字段原样展示）
  String get displayTitle {
    final parts = <String>[];
    final name = patientName.trim();
    if (name.isNotEmpty) parts.add(name);
    final g = gender?.trim();
    if (g != null && g.isNotEmpty) parts.add(g);
    final a = age?.trim();
    if (a != null && a.isNotEmpty) parts.add(a);
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
        'businessWorksetId': businessWorksetId,
        'syncStatus': syncStatus.name,
        'source': source,
        'platformSyncedAt': platformSyncedAt,
      };

  factory LocalPatient.fromJson(Map<String, dynamic> json) => LocalPatient(
        localId: json['localId'] as String,
        patientId: (json['patientId'] as String?) ?? '',
        eventNo: (json['eventNo'] as String?) ?? '',
        patientName: (json['patientName'] as String?) ?? '',
        idCard: (json['idCard'] as String?) ?? '',
        gender: json['gender'] as String?,
        age: json['age'] as String?,
        department: (json['department'] as String?) ?? '',
        bedNumber: (json['bedNumber'] as String?) ?? '',
        remark: (json['remark'] as String?) ?? '',
        createdAt: (json['createdAt'] as int?) ?? 0,
        updatedAt: (json['updatedAt'] as int?) ?? 0,
        deleted: (json['deleted'] as bool?) ?? false,
        businessWorksetId: json['businessWorksetId']?.toString(),
        syncStatus: PatientSyncStatus.values.firstWhere(
          (e) => e.name == json['syncStatus'],
          orElse: () => PatientSyncStatus.localOnly,
        ),
        source: (json['source'] as String?) ?? 'manual',
        platformSyncedAt: (json['platformSyncedAt'] as int?),
      );

  LocalPatient copyWith({
    String? patientId,
    String? eventNo,
    String? patientName,
    String? idCard,
    String? gender,
    String? age,
    String? department,
    String? bedNumber,
    String? remark,
    int? updatedAt,
    bool? deleted,
    String? businessWorksetId,
    PatientSyncStatus? syncStatus,
    String? source,
    int? platformSyncedAt,
    bool clearBusinessWorksetId = false,
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
      businessWorksetId: clearBusinessWorksetId
          ? null
          : (businessWorksetId ?? this.businessWorksetId),
      syncStatus: syncStatus ?? this.syncStatus,
      source: source ?? this.source,
      platformSyncedAt: platformSyncedAt ?? this.platformSyncedAt,
    );
  }
}
