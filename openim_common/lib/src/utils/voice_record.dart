import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

typedef RecordFc = Function(int sec, String path);

class VoiceRecord {
  static const _dir = "voice";
  static const _ext = ".m4a";
  late String _path;
  int _startTimestamp = 0;
  final int _tag;
  final RecordFc onFinished;
  final RecordFc onInterrupt;
  final int maxRecordSec;
  final Function(int duration)? onDuration;
  final Function(double amplitude)? onAmplitude;
  final _audioRecorder = AudioRecorder();
  Timer? _timer;
  StreamSubscription<Amplitude>? _ampSub;
  bool _stopped = false;

  VoiceRecord({
    required this.maxRecordSec,
    required this.onInterrupt,
    required this.onFinished,
    this.onDuration,
    this.onAmplitude,
  }) : _tag = _now();

  Future<void> start() async {
    if (!await _audioRecorder.hasPermission()) return;

    final path = (await getApplicationDocumentsDirectory()).path;
    _path = '$path/$_dir/$_tag$_ext';
    final file = File(_path);
    if (!(await file.exists())) {
      await file.create(recursive: true);
    }

    await _audioRecorder.start(const RecordConfig(), path: _path);
    _startTimestamp = _now();
    _stopped = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final duration = ((_now() - _startTimestamp) ~/ 1000);
      onDuration?.call(duration);
      if (duration >= maxRecordSec) {
        await stop(isInterrupt: true);
        onInterrupt(maxRecordSec, _path);
      }
    });

    await _ampSub?.cancel();
    if (onAmplitude != null) {
      _ampSub = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 80))
          .listen((amp) {
        // dB 约 -160~0，映射到 0~1 供波形使用
        final norm = ((amp.current + 50) / 50).clamp(0.0, 1.0);
        onAmplitude!(norm);
      });
    }
  }

  Future<void> stop({bool isInterrupt = false}) async {
    if (_stopped) return;
    _stopped = true;
    _timer?.cancel();
    _timer = null;
    await _ampSub?.cancel();
    _ampSub = null;

    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
      if (isInterrupt) {
        await _disposeRecorder();
        return;
      }
      onFinished((_now() - _startTimestamp) ~/ 1000, _path);
    }
    await _disposeRecorder();
  }

  /// 取消录音并丢弃文件。
  Future<void> cancel() async {
    if (_stopped) return;
    _stopped = true;
    _timer?.cancel();
    _timer = null;
    await _ampSub?.cancel();
    _ampSub = null;

    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.cancel();
      }
    } catch (_) {
      try {
        await _audioRecorder.stop();
      } catch (_) {}
      try {
        final f = File(_path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    await _disposeRecorder();
  }

  Future<void> _disposeRecorder() async {
    try {
      await _audioRecorder.dispose();
    } catch (_) {}
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;
}
