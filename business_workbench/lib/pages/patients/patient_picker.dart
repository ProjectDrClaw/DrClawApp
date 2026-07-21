import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../host/workbench_host.dart';
import '../../models/local_patient.dart';
import '../../services/patient_context_formatter.dart';
import '../../store/workbench_store.dart';
import '../../theme/wb_theme.dart';
import '../../widgets/patient_list_tile.dart';
import '../../widgets/wb_layout.dart';
import '../../workbench_module.dart';
import '../../workbench_routes.dart';

/// 将患者格式化为对话上下文（旧库 buildPatientContextText）
String formatPatientContext(LocalPatient p) =>
    PatientContextFormatter.currentPatient(p);

/// 展示患者选择器；取消返回 null
Future<LocalPatient?> showPatientPicker(
  BuildContext context, {
  String? title,
  bool allowCreate = true,
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

  return Get.bottomSheet<LocalPatient>(
    _PatientPickerSheet(
      title: title ?? '选择患者',
      allowCreate: allowCreate,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _PatientPickerSheet extends StatefulWidget {
  const _PatientPickerSheet({
    required this.title,
    required this.allowCreate,
  });

  final String title;
  final bool allowCreate;

  @override
  State<_PatientPickerSheet> createState() => _PatientPickerSheetState();
}

class _PatientPickerSheetState extends State<_PatientPickerSheet> {
  final _keyword = TextEditingController();
  List<LocalPatient> _all = [];
  List<LocalPatient> _filtered = [];

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
    _all = WorkbenchStore.instance.listPatients();
    _applyFilter(_keyword.text);
  }

  void _applyFilter(String raw) {
    final k = raw.trim();
    setState(() {
      if (k.isEmpty) {
        _filtered = List.of(_all);
      } else {
        _filtered = _all
            .where((p) =>
                p.patientName.contains(k) ||
                p.bedNumber.contains(k) ||
                p.patientId.contains(k) ||
                p.eventNo.contains(k) ||
                p.department.contains(k))
            .toList();
      }
    });
  }

  Future<void> _create() async {
    Get.back();
    await Get.toNamed(WorkbenchRoutes.patientEdit);
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
                if (widget.allowCreate)
                  TextButton(
                    onPressed: _create,
                    child: Text(
                      '新建',
                      style: TextStyle(fontSize: 17.sp, color: WbTheme.primary),
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
            hintText: '搜索姓名、就诊号、床号…',
            controller: _keyword,
            onChanged: _applyFilter,
            onSubmitted: _applyFilter,
          ),
          Expanded(
            child: _filtered.isEmpty
                ? WbEmptyView(
                    icon: Icons.person_outline,
                    text: '暂无患者',
                    hint: widget.allowCreate ? '可点击右上角新建' : null,
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Container(
                      height: 0.5,
                      color: WbTheme.inputBackground,
                      margin: EdgeInsets.only(left: 64.w, right: 16.w),
                    ),
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      return PatientListTile(
                        patient: p,
                        showChevron: false,
                        cardStyle: false,
                        onTap: () => Get.back(result: p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
