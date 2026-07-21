import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/patient_display.dart';
import '../../theme/wb_theme.dart';
import 'recording_session_logic.dart';

/// 录音页（对齐旧库 RecordingSheet，视觉对齐工作台）
class RecordingSessionPage extends StatelessWidget {
  const RecordingSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<RecordingSessionLogic>();
    return Obx(() {
      // 必须在 Obx 顶层读取依赖，时长才会每秒刷新
      final busy = logic.isActive || logic.saving.value;
      final p = logic.patient.value;
      final phase = logic.phase.value;
      final recording = phase == 'recording';
      final paused = phase == 'paused';
      final sec = logic.durationSec.value;
      final mm = (sec ~/ 60).toString().padLeft(2, '0');
      final ss = (sec % 60).toString().padLeft(2, '0');
      final name = p == null ? '未知患者' : PatientDisplay.profileLine(p);
      final meta = p == null ? '' : PatientDisplay.listMeta(p);
      final initial =
          name.trim().isEmpty ? '患' : name.trim().substring(0, 1);

      return PopScope(
        canPop: !busy,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await logic.discard();
        },
        child: Scaffold(
          backgroundColor: WbTheme.background,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                // 顶栏
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Material(
                        color: WbTheme.backgroundLight,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: logic.discard,
                          child: SizedBox(
                            width: 40.w,
                            height: 40.w,
                            child: Icon(
                              Icons.close,
                              size: 20.w,
                              color: WbTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          recording
                              ? '正在录音'
                              : paused
                                  ? '已暂停'
                                  : '准备录音',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: WbTheme.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 40.w),
                    ],
                  ),
                ),
                // 患者卡片（时长单独一行，避免挤占姓名）
                Container(
                  margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: WbTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: WbTheme.border, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4A7DD9), Color(0xFF2657C9)],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: WbTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (meta.isNotEmpty) ...[
                                  SizedBox(height: 3.h),
                                  Text(
                                    meta,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: WbTheme.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: recording
                              ? WbTheme.primaryAlpha8
                              : WbTheme.inputBackground,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 18.w,
                              color: recording || paused
                                  ? WbTheme.primary
                                  : WbTheme.textSecondary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '录音时长',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: WbTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$mm:$ss',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: recording || paused
                                    ? WbTheme.primary
                                    : WbTheme.textPrimary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 中央麦克风
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _MicButton(
                                recording: recording,
                                paused: paused,
                                onTap: logic.toggleMic,
                              ),
                              SizedBox(height: 24.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: paused
                                      ? const Color(0xFFFDE2E2)
                                      : recording
                                          ? WbTheme.primaryAlpha8
                                          : WbTheme.inputBackground,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Text(
                                  paused
                                      ? '已暂停'
                                      : recording
                                          ? '录音中'
                                          : '待开始',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: paused
                                        ? WbTheme.danger
                                        : recording
                                            ? WbTheme.primary
                                            : WbTheme.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                paused
                                    ? '点击麦克风继续录音'
                                    : recording
                                        ? '正在录音'
                                        : '点击麦克风开始',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: WbTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 36.w),
                                child: Text(
                                  recording && !paused
                                      ? '请保持环境安静，距离麦克风 20–30 cm'
                                      : '最长 ${RecordingSessionLogic.maxSec ~/ 60} 分钟 · 完成后可修改标题',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: WbTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 底栏
                Container(
                  margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: WbTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: WbTheme.border, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FooterAction(
                        onTap: logic.discard,
                        bg: const Color(0xFFFDE2E2),
                        icon: Icons.delete_outline,
                        iconColor: WbTheme.danger,
                        label: '删除',
                        labelColor: WbTheme.textRegular,
                      ),
                      _FooterAction(
                        onTap: logic.saving.value ? null : logic.finish,
                        bg: WbTheme.primary,
                        icon: logic.saving.value
                            ? null
                            : Icons.check_rounded,
                        iconColor: Colors.white,
                        label: '完成',
                        labelColor: WbTheme.primary,
                        loading: logic.saving.value,
                        elevated: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _MicButton extends StatefulWidget {
  const _MicButton({
    required this.recording,
    required this.paused,
    required this.onTap,
  });

  final bool recording;
  final bool paused;
  final VoidCallback onTap;

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _syncAnim();
  }

  @override
  void didUpdateWidget(covariant _MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnim();
  }

  void _syncAnim() {
    if (widget.recording && !widget.paused) {
      if (!_ctrl.isAnimating) _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.recording && !widget.paused;
    final paused = widget.paused;

    return SizedBox(
      width: 168.w,
      height: 168.w,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (active) ...[
                Container(
                  width: 168.w * (0.72 + 0.28 * t),
                  height: 168.w * (0.72 + 0.28 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WbTheme.primary.withOpacity(0.08 + 0.08 * (1 - t)),
                  ),
                ),
                Container(
                  width: 140.w * (0.82 + 0.18 * t),
                  height: 140.w * (0.82 + 0.18 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WbTheme.primary.withOpacity(0.12 + 0.08 * (1 - t)),
                  ),
                ),
              ] else
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: paused
                        ? WbTheme.danger.withOpacity(0.1)
                        : WbTheme.primaryAlpha8,
                  ),
                ),
              child!,
            ],
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: paused ? WbTheme.danger : WbTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: (paused ? WbTheme.danger : WbTheme.primary)
                      .withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              paused ? Icons.mic_off_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 40.w,
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.onTap,
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    this.loading = false,
    this.elevated = false,
  });

  final VoidCallback? onTap;
  final Color bg;
  final IconData? icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final bool loading;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: elevated
                  ? [
                      BoxShadow(
                        color: WbTheme.primary.withOpacity(0.32),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: loading
                ? Padding(
                    padding: EdgeInsets.all(15.w),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, color: iconColor, size: 26.w),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
