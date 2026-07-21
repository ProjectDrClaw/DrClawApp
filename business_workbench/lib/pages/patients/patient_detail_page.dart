import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../services/patient_display.dart';
import '../../theme/wb_theme.dart';
import '../../widgets/recording_list_tile.dart';
import '../../widgets/wb_layout.dart';
import 'patient_detail_logic.dart';

class PatientDetailPage extends StatelessWidget {
  const PatientDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<PatientDetailLogic>();
    return Scaffold(
      appBar: TitleBar.back(
        title: '患者详情',
        right: WbTextAction(label: '编辑', onTap: logic.toEdit),
      ),
      backgroundColor: WbTheme.background,
      body: Obx(() {
        final p = logic.patient.value;
        if (p == null || p.deleted) {
          return const WbEmptyView(
            icon: Icons.person_off_outlined,
            text: '患者不存在',
          );
        }
        final meta = PatientDisplay.listMeta(p);
        final name = PatientDisplay.profileLine(p);
        final initial = name.trim().isEmpty ? '患' : name.trim().substring(0, 1);
        final hasExtra =
            p.idCard.trim().isNotEmpty || p.remark.trim().isNotEmpty;

        return ListView(
          padding: EdgeInsets.only(bottom: 28.h),
          children: [
            WbGroupCard(
              marginTop: 12.h,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          WbTheme.primaryAlpha8,
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52.w,
                          height: 52.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4A7DD9), Color(0xFF2657C9)],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: WbTheme.textPrimary,
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
                                    height: 1.35,
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
                  ),
                  if (hasExtra) ...[
                    Divider(height: 0.5, color: WbTheme.border),
                    if (p.idCard.trim().isNotEmpty)
                      _infoRow('身份证', p.idCard.trim()),
                    if (p.remark.trim().isNotEmpty)
                      _infoRow('备注', p.remark.trim(), maxLines: 4),
                  ],
                ],
              ),
            ),
            WbGroupCard(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '录音记录',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: WbTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                logic.recordings.isEmpty
                                    ? '尚未录制'
                                    : '共 ${logic.recordings.length} 条',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: WbTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: WbTheme.primary,
                          borderRadius: BorderRadius.circular(20.r),
                          child: InkWell(
                            onTap: logic.startRecording,
                            borderRadius: BorderRadius.circular(20.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.mic_none,
                                      color: Colors.white, size: 16.w),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '开始录音',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (logic.recordings.isEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
                      child: Column(
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: WbTheme.primaryAlpha8,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mic_none_outlined,
                              size: 28.w,
                              color: WbTheme.primary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '暂无录音',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: WbTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '点击「开始录音」记录病情与沟通内容',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: WbTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                      child: Column(
                        children: logic.recordings
                            .map(
                              (r) => RecordingListTile(
                                recording: r,
                                patient: p,
                                embedded: true,
                                onTap: () => logic.openRecording(r),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: WbTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: WbTheme.textPrimary,
                height: 1.35,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
