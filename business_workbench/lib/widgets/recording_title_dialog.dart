import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../services/patient_display.dart';
import '../theme/wb_theme.dart';

/// 录音标题输入弹窗（对齐旧库 RecordingSheet titleModal）
Future<String?> showRecordingTitleDialog({
  String? initialTitle,
  String confirmText = '保存',
}) {
  return Get.dialog<String>(
    PopScope(
      canPop: false,
      child: _RecordingTitleDialog(
        initialTitle: (initialTitle?.trim().isNotEmpty == true)
            ? initialTitle!.trim()
            : PatientDisplay.defaultRecordingTitle(),
        confirmText: confirmText,
      ),
    ),
    barrierDismissible: false,
  );
}

class _RecordingTitleDialog extends StatefulWidget {
  const _RecordingTitleDialog({
    required this.initialTitle,
    required this.confirmText,
  });

  final String initialTitle;
  final String confirmText;

  @override
  State<_RecordingTitleDialog> createState() => _RecordingTitleDialogState();
}

class _RecordingTitleDialogState extends State<_RecordingTitleDialog> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialTitle);
    _error = PatientDisplay.recordingTitleError(_ctrl.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() => _error = PatientDisplay.recordingTitleError(v));
  }

  void _submit() {
    if (_error != null) return;
    final t = _ctrl.text.trim();
    Get.back(
      result: t.isEmpty ? PatientDisplay.defaultRecordingTitle() : t,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.only(bottom: bottom > 0 ? 8.h : 0),
        child: Material(
          color: WbTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16.r),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '录音标题',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: WbTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _ctrl,
                  autofocus: true,
                  maxLength: 50,
                  style: TextStyle(fontSize: 15.sp, color: WbTheme.textPrimary),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '输入录音标题',
                    hintStyle:
                        TextStyle(fontSize: 15.sp, color: WbTheme.textHint),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: WbTheme.radiusMd,
                      borderSide: BorderSide(
                        color: _error != null
                            ? WbTheme.danger
                            : const Color(0xFFE4E7ED),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: WbTheme.radiusMd,
                      borderSide: BorderSide(
                        color: _error != null ? WbTheme.danger : WbTheme.primary,
                      ),
                    ),
                  ),
                  onChanged: _onChanged,
                  onSubmitted: (_) => _submit(),
                ),
                SizedBox(height: 6.h),
                Text(
                  _error ?? '可用于后续查找和区分录音',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _error != null ? WbTheme.danger : WbTheme.textHint,
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: _error != null ? null : _submit,
                  child: Opacity(
                    opacity: _error != null ? 0.4 : 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: WbTheme.primary,
                        borderRadius: WbTheme.radiusMd,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.confirmText,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
