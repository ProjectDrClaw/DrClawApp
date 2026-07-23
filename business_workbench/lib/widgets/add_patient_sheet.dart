import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/wb_theme.dart';

enum AddPatientAction { platformSearch, manualCreate }

/// 添加患者动作面板：院内检索（推荐）/ 手动填写
Future<AddPatientAction?> showAddPatientSheet() {
  return Get.bottomSheet<AddPatientAction>(
    const _AddPatientSheet(),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class _AddPatientSheet extends StatelessWidget {
  const _AddPatientSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 24.h),
      decoration: BoxDecoration(
        color: WbTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '添加患者',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: WbTheme.textPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              _ActionTile(
                icon: Icons.search,
                title: '从院内检索',
                subtitle: '按就诊号、床号等查找院内档案',
                badge: '推荐',
                onTap: () => Get.back(result: AddPatientAction.platformSearch),
              ),
              SizedBox(height: 10.h),
              _ActionTile(
                icon: Icons.edit_outlined,
                title: '手动填写',
                subtitle: '院内暂无档案或仅床旁备注时使用',
                onTap: () => Get.back(result: AddPatientAction.manualCreate),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: WbTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WbTheme.inputBackground,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: WbTheme.primaryAlpha8,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: WbTheme.primary, size: 22.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: WbTheme.textPrimary,
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: WbTheme.primaryAlpha8,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: WbTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: WbTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: WbTheme.textHint, size: 18.w),
            ],
          ),
        ),
      ),
    );
  }
}
