/// 本地查房录音
enum RecordingStatus { local, sending, sent, failed }

class LocalRecording {
  LocalRecording({
    required this.localId,
    required this.patientLocalId,
    required this.filePath,
    required this.durationSec,
    this.fileSize = 0,
    this.mime = 'audio/mp4',
    this.ext = '.m4a',
    this.title,
    this.status = RecordingStatus.local,
    this.sentAt,
    this.openimClientMsgId,
    required this.createdAt,
    required this.updatedAt,
    this.deleted = false,
    this.contextSent = false,
  });

  final String localId;
  final String patientLocalId;
  String filePath;
  int durationSec;
  int fileSize;
  String mime;
  String ext;
  /// 录音标题（对齐旧库 Recording.title；可空，发送文案默认「录音」）
  String? title;
  RecordingStatus status;
  int? sentAt;
  String? openimClientMsgId;
  int createdAt;
  int updatedAt;
  bool deleted;

  /// 文本上下文已发出、仅文件失败时可标 true，便于重试只补发文件
  bool contextSent;

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'patientLocalId': patientLocalId,
        'filePath': filePath,
        'durationSec': durationSec,
        'fileSize': fileSize,
        'mime': mime,
        'ext': ext,
        'title': title,
        'status': status.name,
        'sentAt': sentAt,
        'openimClientMsgId': openimClientMsgId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deleted': deleted,
        'contextSent': contextSent,
      };

  factory LocalRecording.fromJson(Map<String, dynamic> json) => LocalRecording(
        localId: json['localId'] as String,
        patientLocalId: json['patientLocalId'] as String,
        filePath: (json['filePath'] as String?) ?? '',
        durationSec: (json['durationSec'] as int?) ?? 0,
        fileSize: (json['fileSize'] as int?) ?? 0,
        mime: (json['mime'] as String?) ?? 'audio/mp4',
        ext: (json['ext'] as String?) ?? '.m4a',
        title: json['title'] as String?,
        status: RecordingStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RecordingStatus.local,
        ),
        sentAt: json['sentAt'] as int?,
        openimClientMsgId: json['openimClientMsgId'] as String?,
        createdAt: (json['createdAt'] as int?) ?? 0,
        updatedAt: (json['updatedAt'] as int?) ?? 0,
        deleted: (json['deleted'] as bool?) ?? false,
        contextSent: (json['contextSent'] as bool?) ?? false,
      );
}
