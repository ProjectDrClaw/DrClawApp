import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../host/workbench_host.dart';
import '../../models/local_patient.dart';
import '../../models/local_recording.dart';
import '../../services/patient_context_formatter.dart';
import '../../store/workbench_store.dart';
import '../../theme/wb_theme.dart';
import '../../widgets/recording_list_tile.dart';
import '../../widgets/wb_layout.dart';
import '../../workbench_module.dart';
import '../../workbench_routes.dart';

/// 聊天工具箱选中的查房录音（含所属患者）
class RecordingPickResult {
  RecordingPickResult({required this.recording, required this.patient});

  final LocalRecording recording;
  final LocalPatient patient;

  String get contextText =>
      PatientContextFormatter.wardRoundRecording(patient, recording);

  String get fileName =>
      PatientContextFormatter.fileNameForRecording(patient, recording);
}

/// 展示查房录音选择器；取消返回 null
Future<RecordingPickResult?> showRecordingPicker(
  BuildContext context, {
  String? title,
  String? patientLocalId,
}) async {
  if (!Get.isRegistered<WorkbenchHost>()) {
    IMViews.showToast('业务模块未就绪');
    return null;
  }
  final host = Get.find<WorkbenchHost>();
  final uid = host.currentUserId;
  if (uid.isEmpty) {
    IMViews.showToast('请先登录');
    return null;
  }
  if (!WorkbenchStore.instance.isReady ||
      WorkbenchStore.instance.userId != uid) {
    await WorkbenchModule.onUserChanged(uid);
  }
  if (!context.mounted) return null;

  return Get.bottomSheet<RecordingPickResult>(
    _RecordingPickerSheet(
      title: title ?? '选择录音',
      patientLocalId: patientLocalId,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _RecordingPickerSheet extends StatefulWidget {
  const _RecordingPickerSheet({
    required this.title,
    this.patientLocalId,
  });

  final String title;
  final String? patientLocalId;

  @override
  State<_RecordingPickerSheet> createState() => _RecordingPickerSheetState();
}

class _RecordingPickerSheetState extends State<_RecordingPickerSheet> {
  final _keyword = TextEditingController();
  List<({LocalRecording recording, LocalPatient? patient})> _all = [];
  List<({LocalRecording recording, LocalPatient? patient})> _filtered = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  void _reload() {
    final list = WorkbenchStore.instance.listRecordings(
      patientLocalId: widget.patientLocalId,
    );
    _all = list
        .map((r) => (
              recording: r,
              patient: WorkbenchStore.instance.getPatient(r.patientLocalId),
            ))
        .where((e) => e.patient != null && !e.patient!.deleted)
        .where((e) => File(e.recording.filePath).existsSync())
        .toList();
    _applyFilter(_keyword.text);
  }

  void _applyFilter(String raw) {
    final k = raw.trim();
    setState(() {
      if (k.isEmpty) {
        _filtered = List.of(_all);
        return;
      }
      _filtered = _all.where((e) {
        final p = e.patient!;
        return p.patientName.contains(k) ||
            p.bedNumber.contains(k) ||
            p.patientId.contains(k) ||
            p.eventNo.contains(k);
      }).toList();
    });
  }

  Future<void> _goRecord() async {
    Get.back();
    await Get.toNamed(WorkbenchRoutes.patients);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.75.sh),
      decoration: BoxDecoration(
        color: WbTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: WbTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: WbTheme.textSecondary),
                ),
              ],
            ),
          ),
          WbSearchBar(
            hintText: '搜索患者姓名、就诊号…',
            controller: _keyword,
            onChanged: _applyFilter,
            onSubmitted: _applyFilter,
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_none_outlined,
                            size: 48.w, color: WbTheme.textHint),
                        SizedBox(height: 16.h),
                        Text('暂无录音', style: WbTheme.body14Hint),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: _goRecord,
                          child: Text(
                            '去工作台录制',
                            style: TextStyle(
                                fontSize: 16.sp, color: WbTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Container(
                      height: 0.5,
                      color: WbTheme.inputBackground,
                      margin: EdgeInsets.only(left: 64.w, right: 16.w),
                    ),
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final r = item.recording;
                      final p = item.patient!;
                      return RecordingListTile(
                        recording: r,
                        patient: p,
                        showChevron: false,
                        cardStyle: false,
                        onTap: () => Get.back(
                          result: RecordingPickResult(
                            recording: r,
                            patient: p,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
