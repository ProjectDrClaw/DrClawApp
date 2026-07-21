import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// 按住说话录音条。
class ChatVoiceRecordBar extends StatefulWidget {
  const ChatVoiceRecordBar({
    Key? key,
    required this.onCompleted,
  }) : super(key: key);

  /// 录音完成回调：时长（秒）、本地路径。
  final void Function(int duration, String path) onCompleted;

  @override
  State<ChatVoiceRecordBar> createState() => _ChatVoiceRecordBarState();
}

class _ChatVoiceRecordBarState extends State<ChatVoiceRecordBar> {
  VoiceRecord? _recorder;
  bool _recording = false;
  bool _cancelZone = false;
  Offset? _startGlobal;

  static const _maxSec = 60;
  static const _cancelOffsetY = -60.0;

  Future<void> _start(LongPressStartDetails details) async {
    _startGlobal = details.globalPosition;
    _cancelZone = false;
    Permissions.microphone(() {
      _beginRecord();
    });
  }

  Future<void> _beginRecord() async {
    _recorder = VoiceRecord(
      maxRecordSec: _maxSec,
      onInterrupt: (sec, path) {
        _finish(sec, path, interrupted: true);
      },
      onFinished: (sec, path) {
        _finish(sec, path);
      },
    );
    await _recorder!.start();
    if (!mounted) return;
    setState(() => _recording = true);
  }

  Future<void> _stop({bool cancel = false}) async {
    if (_recorder == null) return;
    if (cancel) {
      await _recorder!.stop(isInterrupt: true);
      _resetUi();
      return;
    }
    await _recorder!.stop();
  }

  void _finish(int sec, String path, {bool interrupted = false}) {
    _resetUi();
    if (interrupted) {
      // 达到上限自动发送
      if (sec >= 1) widget.onCompleted(sec, path);
      return;
    }
    if (sec < 1) {
      IMViews.showToast(StrRes.talkTooShort);
      return;
    }
    widget.onCompleted(sec, path);
  }

  void _resetUi() {
    _recorder = null;
    if (!mounted) return;
    setState(() {
      _recording = false;
      _cancelZone = false;
    });
  }

  void _onMove(LongPressMoveUpdateDetails details) {
    if (!_recording || _startGlobal == null) return;
    final dy = details.globalPosition.dy - _startGlobal!.dy;
    final inCancel = dy < _cancelOffsetY;
    if (inCancel != _cancelZone) {
      setState(() => _cancelZone = inCancel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = !_recording
        ? StrRes.holdTalk
        : (_cancelZone
            ? StrRes.liftFingerToCancelSend
            : StrRes.releaseToSendSwipeUpToCancel);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: _start,
      onLongPressMoveUpdate: _onMove,
      onLongPressEnd: (_) => _stop(cancel: _cancelZone),
      onLongPressCancel: () => _stop(cancel: true),
      child: Container(
        height: 40.h,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Styles.c_FFFFFF,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: _cancelZone ? Styles.ts_FF381F_17sp : Styles.ts_0C1C33_17sp,
        ),
      ),
    );
  }
}
