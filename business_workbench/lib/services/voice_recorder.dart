import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:record/record.dart';

/// 业务工作台长录音（默认最长 30 分钟；支持暂停/恢复）
class WorkbenchVoiceRecorder {
  WorkbenchVoiceRecorder({
    this.maxRecordSec = 30 * 60,
    this.onDuration,
    this.onMaxReached,
  });

  final int maxRecordSec;
  final void Function(int durationSec)? onDuration;
  final void Function()? onMaxReached;

  final _audioRecorder = AudioRecorder();
  Timer? _timer;
  String? _path;
  bool _running = false;
  bool _paused = false;

  /// 已累计有效录音秒数（不含当前片段）
  int _accumulatedSec = 0;
  /// 当前片段开始墙钟毫秒
  int _segmentStartMs = 0;

  bool get isRecording => _running && !_paused;
  bool get isPaused => _running && _paused;
  bool get isActive => _running;

  Future<bool> hasPermission() => _audioRecorder.hasPermission();

  Future<void> start(String filePath) async {
    if (_running) return;
    final file = File(filePath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    _path = filePath;
    _accumulatedSec = 0;
    _paused = false;
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );
    _segmentStartMs = DateTime.now().millisecondsSinceEpoch;
    _running = true;
    _startTicker();
  }

  Future<void> pause() async {
    if (!_running || _paused) return;
    _accumulatedSec = _elapsedSec();
    await _audioRecorder.pause();
    _paused = true;
    _timer?.cancel();
    _timer = null;
    onDuration?.call(_accumulatedSec);
  }

  Future<void> resume() async {
    if (!_running || !_paused) return;
    await _audioRecorder.resume();
    _paused = false;
    _segmentStartMs = DateTime.now().millisecondsSinceEpoch;
    _startTicker();
  }

  /// 停止并返回 (时长秒, 路径)；未在录制返回 null
  Future<({int durationSec, String path})?> stop() async {
    _timer?.cancel();
    _timer = null;
    if (!_running) return null;
    final duration = _elapsedSec();
    _running = false;
    _paused = false;
    final path = _path;
    await _audioRecorder.stop();
    _path = null;
    if (path == null || path.isEmpty) return null;
    return (durationSec: duration, path: path);
  }

  Future<void> cancel() async {
    _timer?.cancel();
    _timer = null;
    if (!_running) return;
    _running = false;
    _paused = false;
    final path = _path;
    await _audioRecorder.stop();
    _path = null;
    if (path != null) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    // 已 stop 时只释放原生资源，勿再走 cancel（避免误删文件）
    if (_running) {
      await cancel();
    }
    try {
      await _audioRecorder.dispose();
    } catch (_) {}
  }

  void _startTicker() {
    _timer?.cancel();
    onDuration?.call(_elapsedSec());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = _elapsedSec();
      onDuration?.call(duration);
      if (duration >= maxRecordSec) {
        _timer?.cancel();
        _timer = null;
        // 由页面 finish() 负责 stop，避免重复停止
        onMaxReached?.call();
      }
    });
  }

  int _elapsedSec() {
    if (!_running) return _accumulatedSec;
    if (_paused) return _accumulatedSec;
    final segment =
        (DateTime.now().millisecondsSinceEpoch - _segmentStartMs) ~/ 1000;
    return _accumulatedSec + segment;
  }

  static String suggestFileName(String recordingLocalId) =>
      '$recordingLocalId.m4a';

  static String joinPath(String dir, String name) => p.join(dir, name);
}
