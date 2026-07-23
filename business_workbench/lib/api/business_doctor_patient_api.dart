import 'package:dio/dio.dart';

import '../host/workbench_business_host.dart';

/// DrClawBusiness doctor-patient 客户端（响应 code==200）
class BusinessDoctorPatientApi {
  BusinessDoctorPatientApi({
    required this.baseUrl,
    required this.appId,
    required this.doctorUserId,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl.replaceAll(RegExp(r'/+$'), ''),
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  final String baseUrl;
  final String appId;
  final String doctorUserId;
  final Dio _dio;

  Options get _opts => Options(headers: {
        'appId': appId,
        'doctorUserId': doctorUserId,
      });

  Future<DoctorPatientPage> list({
    int pageNum = 1,
    int pageSize = 100,
    String? keyword,
  }) async {
    final data = await _post(
      '/api/business/doctor-patient/list',
      body: {
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      },
      query: {'pageNum': pageNum, 'pageSize': pageSize},
    );
    final map = data as Map<String, dynamic>? ?? {};
    final rows = (map['rows'] as List? ?? [])
        .map((e) => _dtoFromJson(e as Map<String, dynamic>))
        .toList();
    return DoctorPatientPage(
      rows: rows,
      pageNum: (map['pageNum'] as num?)?.toInt() ?? pageNum,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? pageSize,
      total: (map['total'] as num?)?.toInt() ?? rows.length,
    );
  }

  Future<DoctorPatientDto> save(DoctorPatientSave input) async {
    final data = await _post(
      '/api/business/doctor-patient/save',
      body: {
        if (input.id != null && input.id!.isNotEmpty) 'id': int.tryParse(input.id!),
        'eventNo': input.eventNo,
        'patientId': input.patientId,
        'patientName': input.patientName,
        'idCard': input.idCard,
        'gender': input.gender,
        'age': input.age,
        'department': input.department,
        'bedNumber': input.bedNumber,
        'remark': input.remark,
        'source': input.source,
      },
    );
    return _dtoFromJson(data as Map<String, dynamic>);
  }

  Future<void> delete({required String id}) async {
    final nid = int.tryParse(id);
    if (nid == null) {
      throw StateError('无效的工作集 id');
    }
    await _post(
      '/api/business/doctor-patient/delete',
      body: {'id': nid},
    );
  }

  Future<PlatformPatientPage> queryPlatform({
    int pageNum = 1,
    int pageSize = 20,
    String? keyword,
    String? eventNo,
    String? patientId,
  }) async {
    final data = await _post(
      '/api/business/platform-patient/query',
      body: {
        if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
        if (eventNo != null && eventNo.trim().isNotEmpty) 'eventNo': eventNo.trim(),
        if (patientId != null && patientId.trim().isNotEmpty)
          'patientId': patientId.trim(),
      },
      query: {'pageNum': pageNum, 'pageSize': pageSize},
    );
    final map = data as Map<String, dynamic>? ?? {};
    final rows = (map['rows'] as List? ?? [])
        .map((e) => _platformFromJson(e as Map<String, dynamic>))
        .toList();
    return PlatformPatientPage(
      rows: rows,
      pageNum: (map['pageNum'] as num?)?.toInt() ?? pageNum,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? pageSize,
      total: (map['total'] as num?)?.toInt() ?? rows.length,
    );
  }

  Future<dynamic> _post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        path,
        data: body ?? {},
        queryParameters: query,
        options: _opts,
      );
      final root = res.data ?? {};
      final code = root['code'];
      if (code == 200) {
        return root['data'];
      }
      final msg = (root['message'] as String?)?.trim();
      throw StateError(msg?.isNotEmpty == true ? msg! : '业务请求失败($code)');
    } on DioException catch (e) {
      throw StateError(e.message ?? '网络异常');
    }
  }

  static DoctorPatientDto _dtoFromJson(Map<String, dynamic> json) {
    return DoctorPatientDto(
      id: '${json['id']}',
      eventNo: (json['eventNo'] as String?) ?? '',
      patientId: (json['patientId'] as String?) ?? '',
      patientName: (json['patientName'] as String?) ?? '',
      idCard: (json['idCard'] as String?) ?? '',
      gender: json['gender'] as String?,
      age: json['age'] as String?,
      department: (json['department'] as String?) ?? '',
      bedNumber: (json['bedNumber'] as String?) ?? '',
      remark: (json['remark'] as String?) ?? '',
      source: (json['source'] as String?) ?? 'manual',
      platformSnapshotAtMs: _parseTimeMs(json['platformSnapshotAt']),
      createTimeMs: _parseTimeMs(json['createTime']),
      updateTimeMs: _parseTimeMs(json['updateTime']),
    );
  }

  static PlatformPatientDto _platformFromJson(Map<String, dynamic> json) {
    return PlatformPatientDto(
      eventNo: (json['eventNo'] as String?) ?? '',
      patientId: (json['patientId'] as String?) ?? '',
      patientName: (json['patientName'] as String?) ?? '',
      idCard: (json['idCard'] as String?) ?? '',
      gender: json['gender'] as String?,
      age: json['age'] as String?,
      department: (json['department'] as String?) ?? '',
      bedNumber: (json['bedNumber'] as String?) ?? '',
    );
  }

  static int? _parseTimeMs(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    return dt?.millisecondsSinceEpoch;
  }
}
