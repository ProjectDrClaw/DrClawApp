import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../host/workbench_business_host.dart';
import '../../theme/wb_theme.dart';
import '../../widgets/wb_layout.dart';
import 'platform_patient_search_logic.dart';

class PlatformPatientSearchPage extends StatelessWidget {
  const PlatformPatientSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<PlatformPatientSearchLogic>();
    return Scaffold(
      appBar: TitleBar.back(title: '从院内检索'),
      backgroundColor: WbTheme.background,
      body: Column(
        children: [
          WbSearchBar(
            controller: logic.keywordCtrl,
            hintText: '就诊号、患者ID、姓名或床号',
            onSubmitted: (_) => logic.search(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            child: SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: logic.search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WbTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  '搜索',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (logic.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!logic.searched.value) {
                return const WbEmptyView(
                  icon: Icons.search,
                  text: '输入关键词后点搜索',
                  hint: '可按就诊号、患者ID、姓名或床号查找',
                );
              }
              if (logic.rows.isEmpty) {
                return WbEmptyView(
                  icon: Icons.person_search_outlined,
                  text: logic.errorText ?? '未找到院内患者',
                  hint: '试试其他关键词',
                );
              }
              return ListView.builder(
                padding: EdgeInsets.only(top: 4.h, bottom: 24.h),
                itemCount: logic.rows.length,
                itemBuilder: (_, i) {
                  final p = logic.rows[i];
                  final added = logic.isInWorkset(p);
                  final joining =
                      logic.joiningId.value == '${p.eventNo}|${p.patientId}';
                  return _PlatformResultTile(
                    patient: p,
                    alreadyAdded: added,
                    joining: joining,
                    onTapRow: () => logic.showPreview(p),
                    onJoin: () => added ? logic.openExisting(p) : logic.join(p),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PlatformResultTile extends StatelessWidget {
  const _PlatformResultTile({
    required this.patient,
    required this.alreadyAdded,
    required this.joining,
    required this.onTapRow,
    required this.onJoin,
  });

  final PlatformPatientDto patient;
  final bool alreadyAdded;
  final bool joining;
  final VoidCallback onTapRow;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final title = _titleLine(patient);
    final meta = _metaLine(patient);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: Material(
        color: WbTheme.backgroundLight,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTapRow,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: WbTheme.border, width: 0.5),
            ),
            child: Row(
              children: [
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
                      ),
                      if (meta.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          meta,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: WbTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: joining ? null : onJoin,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        alreadyAdded ? WbTheme.textSecondary : WbTheme.primary,
                    backgroundColor: alreadyAdded
                        ? WbTheme.inputBackground
                        : WbTheme.primaryAlpha8,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    joining
                        ? '加入中…'
                        : (alreadyAdded ? '已添加' : '加入'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
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

  String _titleLine(PlatformPatientDto p) {
    final parts = <String>[];
    final bed = p.bedNumber.trim();
    if (bed.isNotEmpty) parts.add(bed);
    if (p.patientName.trim().isNotEmpty) parts.add(p.patientName.trim());
    final g = p.gender?.trim();
    if (g != null && g.isNotEmpty) parts.add(g);
    final a = p.age?.trim();
    if (a != null && a.isNotEmpty) parts.add(a);
    return parts.isEmpty ? '未命名' : parts.join(' · ');
  }

  String _metaLine(PlatformPatientDto p) {
    final parts = <String>[];
    if (p.eventNo.trim().isNotEmpty) parts.add('就诊号 ${p.eventNo}');
    if (p.patientId.trim().isNotEmpty) parts.add('患者ID ${p.patientId}');
    if (p.department.trim().isNotEmpty) parts.add(p.department);
    return parts.join(' · ');
  }
}
