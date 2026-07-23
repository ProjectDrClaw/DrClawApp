import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/local_patient.dart';
import '../services/patient_display.dart';
import '../theme/wb_theme.dart';

/// 患者列表行：圆角卡片
class PatientListTile extends StatelessWidget {
  const PatientListTile({
    super.key,
    required this.patient,
    this.onTap,
    this.onLongPress,
    this.showChevron = true,
    this.cardStyle = true,
  });

  final LocalPatient patient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showChevron;
  final bool cardStyle;

  @override
  Widget build(BuildContext context) {
    final meta = PatientDisplay.listMeta(patient);
    final name = PatientDisplay.profileLine(patient);
    final initial = _initialOf(name);

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: WbTheme.textPrimary,
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    meta,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: WbTheme.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 6.h),
                _SyncChip(patient: patient),
              ],
            ),
          ),
          if (showChevron)
            Icon(Icons.chevron_right, color: WbTheme.textHint, size: 18.w),
        ],
      ),
    );

    if (!cardStyle) {
      return Material(
        color: WbTheme.backgroundLight,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: Material(
        color: WbTheme.backgroundLight,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
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
}

String _initialOf(String name) {
  final t = name.trim();
  if (t.isEmpty) return '患';
  return t.substring(0, 1);
}

class _SyncChip extends StatelessWidget {
  const _SyncChip({required this.patient});

  final LocalPatient patient;

  Color get _color {
    switch (patient.syncStatus) {
      case PatientSyncStatus.synced:
        return WbTheme.success;
      case PatientSyncStatus.dirty:
        return WbTheme.warning;
      case PatientSyncStatus.error:
        return WbTheme.danger;
      case PatientSyncStatus.localOnly:
        return WbTheme.textSecondary;
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
        PatientDisplay.patientSyncLabel(patient),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
