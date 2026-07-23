import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../models/local_recording.dart';
import '../../services/patient_display.dart';
import '../../theme/wb_theme.dart';
import '../../widgets/wb_layout.dart';
import 'recording_detail_logic.dart';

class RecordingDetailPage extends StatelessWidget {
  const RecordingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<RecordingDetailLogic>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.back(result: logic.isDirty);
      },
      child: Scaffold(
        appBar: TitleBar.back(
          title: '录音详情',
          onTap: () => Get.back(result: logic.isDirty),
          right: WbTextAction(
            label: '删除',
            onTap: logic.delete,
            color: WbTheme.danger,
          ),
        ),
        backgroundColor: WbTheme.background,
        body: Obx(() {
          final r = logic.recording.value;
          final p = logic.patient.value;
          if (r == null) {
            return const WbEmptyView(
              icon: Icons.mic_off_outlined,
              text: '录音不存在',
            );
          }
          final statusHint = PatientDisplay.recordingStatusHint(r);
          return ListView(
            padding: EdgeInsets.only(bottom: 28.h),
            children: [
              WbGroupCard(
                marginTop: 12.h,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: WbTheme.primaryAlpha8,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.mic,
                              color: WbTheme.primary,
                              size: 24.w,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  PatientDisplay.recordingTitle(r),
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: WbTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  p == null
                                      ? '未知患者'
                                      : PatientDisplay.profileLine(p),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: WbTheme.textRegular,
                                  ),
                                ),
                                if (p != null &&
                                    PatientDisplay.listMeta(p).isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    PatientDisplay.listMeta(p),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: WbTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: logic.editTitle,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: WbTheme.primaryAlpha8,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Text(
                                '修改',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: WbTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _MetaChip(
                              icon: Icons.timer_outlined,
                              label: PatientDisplay.formatDuration(r.durationSec),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _MetaChip(
                              icon: Icons.schedule_outlined,
                              label: PatientDisplay.formatDate(r.createdAt),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _StatusBadge(recording: r),
                    ],
                  ),
                ),
              ),
              if (statusHint != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: _StatusBanner(
                    recording: r,
                    hint: statusHint,
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                child: _ActionButton(
                  label: logic.playing.value ? '停止播放' : '播放',
                  color: WbTheme.primary,
                  icon: logic.playing.value
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  onTap: logic.togglePlay,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: _ActionButton(
                  label: logic.sendButtonLabel,
                  color: r.status == RecordingStatus.failed
                      ? WbTheme.warning
                      : WbTheme.primary,
                  icon: r.status == RecordingStatus.failed
                      ? Icons.refresh_rounded
                      : Icons.send_rounded,
                  enabled: !logic.sending.value,
                  onTap: logic.sendToAgent,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.recording});

  final LocalRecording recording;

  Color get _color {
    switch (recording.status) {
      case RecordingStatus.local:
        return WbTheme.textSecondary;
      case RecordingStatus.sending:
        return WbTheme.primary;
      case RecordingStatus.sent:
        return WbTheme.success;
      case RecordingStatus.failed:
        return WbTheme.danger;
    }
  }

  IconData get _icon {
    switch (recording.status) {
      case RecordingStatus.local:
        return Icons.schedule_send_outlined;
      case RecordingStatus.sending:
        return Icons.cloud_upload_outlined;
      case RecordingStatus.sent:
        return Icons.check_circle_outline;
      case RecordingStatus.failed:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14.w, color: color),
          SizedBox(width: 4.w),
          Text(
            PatientDisplay.recordingStatusLabel(recording),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (recording.status == RecordingStatus.failed &&
              recording.contextSent) ...[
            SizedBox(width: 6.w),
            Text(
              '· 说明已发出',
              style: TextStyle(
                fontSize: 11.sp,
                color: WbTheme.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.recording,
    required this.hint,
  });

  final LocalRecording recording;
  final String hint;

  Color get _bg {
    switch (recording.status) {
      case RecordingStatus.failed:
        return WbTheme.danger.withOpacity(0.08);
      case RecordingStatus.sent:
        return WbTheme.success.withOpacity(0.08);
      case RecordingStatus.sending:
        return WbTheme.primary.withOpacity(0.08);
      case RecordingStatus.local:
        return WbTheme.inputBackground;
    }
  }

  Color get _fg {
    switch (recording.status) {
      case RecordingStatus.failed:
        return WbTheme.danger;
      case RecordingStatus.sent:
        return WbTheme.success;
      case RecordingStatus.sending:
        return WbTheme.primary;
      case RecordingStatus.local:
        return WbTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _fg.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        hint,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.4,
          color: WbTheme.textRegular,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: WbTheme.inputBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: WbTheme.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: WbTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : color.withOpacity(0.45),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 48.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.w),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
