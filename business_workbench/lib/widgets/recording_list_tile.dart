import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/local_patient.dart';
import '../models/local_recording.dart';
import '../services/patient_display.dart';
import '../theme/wb_theme.dart';

/// 录音列表行
/// [embedded] true：嵌在详情白卡片内（边框条）
class RecordingListTile extends StatelessWidget {
  const RecordingListTile({
    super.key,
    required this.recording,
    this.patient,
    this.onTap,
    this.showChevron = false,
    this.cardStyle = false,
    this.embedded = false,
  });

  final LocalRecording recording;
  final LocalPatient? patient;
  final VoidCallback? onTap;
  final bool showChevron;

  /// 列表页独立卡片
  final bool cardStyle;

  /// 详情页内嵌条（兼容旧参数名 cardStyle 语义）
  final bool embedded;

  bool get _asCard => cardStyle || embedded;

  @override
  Widget build(BuildContext context) {
    final title = PatientDisplay.recordingTitle(recording);
    final meta = embedded
        ? PatientDisplay.formatDate(recording.createdAt)
        : PatientDisplay.recordingMeta(patient, recording);

    final content = Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: WbTheme.primaryAlpha8,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.mic, color: WbTheme.primary, size: 22.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: WbTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  meta,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: WbTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recording.status != RecordingStatus.local) ...[
                  SizedBox(height: 6.h),
                  _StatusChip(recording: recording),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: WbTheme.primaryAlpha8,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              PatientDisplay.formatDuration(recording.durationSec),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: WbTheme.primaryDark,
              ),
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right, color: WbTheme.textHint, size: 18.w),
          ],
        ],
      ),
    );

    if (embedded) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Material(
          color: WbTheme.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: content,
          ),
        ),
      );
    }

    if (cardStyle || _asCard) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        child: Material(
          color: WbTheme.backgroundLight,
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: WbTheme.border, width: 0.5),
              ),
              child: content,
            ),
          ),
        ),
      );
    }

    return Material(
      color: WbTheme.backgroundLight,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.recording});

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

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        PatientDisplay.recordingStatusLabel(recording),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
