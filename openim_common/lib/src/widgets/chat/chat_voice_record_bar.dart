import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// 按住说话录音条（含录音浮层、波形与取消态）。
class ChatVoiceRecordBar extends StatefulWidget {
  const ChatVoiceRecordBar({
    super.key,
    required this.onCompleted,
  });

  /// 录音完成回调：时长（秒）、本地路径。
  final void Function(int duration, String path) onCompleted;

  @override
  State<ChatVoiceRecordBar> createState() => _ChatVoiceRecordBarState();
}

class _ChatVoiceRecordBarState extends State<ChatVoiceRecordBar>
    with SingleTickerProviderStateMixin {
  VoiceRecord? _recorder;
  bool _recording = false;
  bool _cancelZone = false;
  bool _fingerDown = false;
  Offset? _startGlobal;
  int _seconds = 0;
  double _amplitude = 0;
  OverlayEntry? _overlay;

  late final AnimationController _pulseCtrl;

  static const _maxSec = 60;
  static const _cancelOffsetY = -72.0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _removeOverlay();
    _pulseCtrl.dispose();
    _recorder?.cancel();
    super.dispose();
  }

  Future<void> _start(LongPressStartDetails details) async {
    _startGlobal = details.globalPosition;
    _cancelZone = false;
    _seconds = 0;
    _amplitude = 0;
    _fingerDown = true;
    Permissions.microphone(() {
      if (!_fingerDown || !mounted) return;
      _beginRecord();
    });
  }

  Future<void> _beginRecord() async {
    if (!_fingerDown || _recording) return;
    HapticFeedback.mediumImpact();
    _recorder = VoiceRecord(
      maxRecordSec: _maxSec,
      onInterrupt: (sec, path) {
        _finish(sec, path, interrupted: true);
      },
      onFinished: (sec, path) {
        _finish(sec, path);
      },
      onDuration: (sec) {
        if (!mounted) return;
        setState(() => _seconds = sec);
        _overlay?.markNeedsBuild();
      },
      onAmplitude: (amp) {
        if (!mounted) return;
        setState(() => _amplitude = amp);
        _overlay?.markNeedsBuild();
      },
    );
    await _recorder!.start();
    if (!mounted) return;
    // 权限弹窗期间若已松手，立即丢弃
    if (!_fingerDown) {
      await _recorder?.cancel();
      _recorder = null;
      return;
    }
    setState(() => _recording = true);
    _showOverlay();
  }

  Future<void> _stop({bool cancel = false}) async {
    _fingerDown = false;
    if (_recorder == null) return;
    if (cancel) {
      HapticFeedback.lightImpact();
      await _recorder!.cancel();
      _resetUi();
      return;
    }
    await _recorder!.stop();
  }

  void _finish(int sec, String path, {bool interrupted = false}) {
    _resetUi();
    if (interrupted) {
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
    _fingerDown = false;
    _removeOverlay();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _cancelZone = false;
      _seconds = 0;
      _amplitude = 0;
    });
  }

  void _onMove(LongPressMoveUpdateDetails details) {
    if (!_recording || _startGlobal == null) return;
    final dy = details.globalPosition.dy - _startGlobal!.dy;
    final inCancel = dy < _cancelOffsetY;
    if (inCancel != _cancelZone) {
      HapticFeedback.selectionClick();
      setState(() => _cancelZone = inCancel);
      _overlay?.markNeedsBuild();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (_) => _VoiceRecordHud(
        cancelZone: _cancelZone,
        seconds: _seconds,
        maxSec: _maxSec,
        amplitude: _amplitude,
        pulse: _pulseCtrl,
      ),
    );
    overlay.insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  String get _barText {
    if (!_recording) return StrRes.holdTalk;
    return _cancelZone
        ? StrRes.liftFingerToCancelSend
        : StrRes.releaseToSendSwipeUpToCancel;
  }

  @override
  Widget build(BuildContext context) {
    final recording = _recording;
    final cancel = _cancelZone;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: _start,
      onLongPressMoveUpdate: _onMove,
      onLongPressEnd: (_) => _stop(cancel: _cancelZone),
      onLongPressCancel: () => _stop(cancel: true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 40.h,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: !recording
              ? Styles.c_FFFFFF
              : (cancel ? Styles.c_FF381F_opacity10 : Styles.c_0089FF_opacity10),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: !recording
                ? Colors.transparent
                : (cancel ? Styles.c_FF381F : Styles.c_0089FF),
            width: recording ? 1 : 0,
          ),
        ),
        child: Text(
          _barText,
          textAlign: TextAlign.center,
          style: cancel
              ? Styles.ts_FF381F_17sp
              : (recording ? Styles.ts_0089FF_17sp : Styles.ts_0C1C33_17sp),
        ),
      ),
    );
  }
}

/// 屏幕中央录音浮层。
class _VoiceRecordHud extends StatelessWidget {
  const _VoiceRecordHud({
    required this.cancelZone,
    required this.seconds,
    required this.maxSec,
    required this.amplitude,
    required this.pulse,
  });

  final bool cancelZone;
  final int seconds;
  final int maxSec;
  final double amplitude;
  final Animation<double> pulse;

  String get _timeText {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final accent = cancelZone ? Styles.c_FF381F : Styles.c_0089FF;
    final tip = cancelZone
        ? StrRes.liftFingerToCancelSend
        : StrRes.releaseToSendSwipeUpToCancel;

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 轻遮罩，突出浮层
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                color: Colors.black.withOpacity(cancelZone ? 0.28 : 0.18),
              ),
            ),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 168.w,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: const Color(0xE61C2430),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 56.h,
                      child: cancelZone
                          ? Icon(
                              Icons.undo_rounded,
                              size: 40.w,
                              color: Styles.c_FF381F,
                            )
                          : AnimatedBuilder(
                              animation: pulse,
                              builder: (_, __) {
                                return _WaveBars(
                                  amplitude: amplitude,
                                  pulse: pulse.value,
                                  color: accent,
                                );
                              },
                            ),
                    ),
                    10.verticalSpace,
                    Text(
                      _timeText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    if (seconds >= maxSec - 10) ...[
                      4.verticalSpace,
                      Text(
                        StrRes.voiceRemainSeconds(maxSec - seconds),
                        style: TextStyle(
                          color: Styles.c_FF381F,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                    12.verticalSpace,
                    Text(
                      tip,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cancelZone
                            ? Styles.c_FF381F
                            : Colors.white.withOpacity(0.85),
                        fontSize: 13.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简易音量波形条。
class _WaveBars extends StatelessWidget {
  const _WaveBars({
    required this.amplitude,
    required this.pulse,
    required this.color,
  });

  final double amplitude;
  final double pulse;
  final Color color;

  static const _weights = [0.35, 0.55, 0.8, 1.0, 0.75, 0.5, 0.4];

  @override
  Widget build(BuildContext context) {
    final base = 0.18 + amplitude * 0.82;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_weights.length, (i) {
        final phase = math.sin((pulse * math.pi * 2) + i * 0.7);
        final hFactor = (base * _weights[i] * (0.72 + 0.28 * phase)).clamp(0.12, 1.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          width: 5.w,
          height: 48.h * hFactor,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}
