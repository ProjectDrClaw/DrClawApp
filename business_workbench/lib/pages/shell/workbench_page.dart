import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../theme/wb_theme.dart';
import '../../workbench_routes.dart';
import 'workbench_logic.dart';

/// 工作台 Tab 根页
class WorkbenchPage extends StatelessWidget {
  WorkbenchPage({super.key});

  final logic = Get.put(WorkbenchLogic());

  Future<void> _openPatients() async {
    if (!await logic.ensureLoggedIn()) return;
    await Get.toNamed(WorkbenchRoutes.patients);
    // 轻量计数延后到帧后，避免与返回动画抢主线程
    SchedulerBinding.instance.addPostFrameCallback((_) => logic.refreshCounts());
  }

  Future<void> _openRecordings() async {
    if (!await logic.ensureLoggedIn()) return;
    await Get.toNamed(WorkbenchRoutes.recordings);
    SchedulerBinding.instance.addPostFrameCallback((_) => logic.refreshCounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.workbench(),
      backgroundColor: WbTheme.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        children: [
          _HeroBanner(),
          SizedBox(height: 16.h),
          Obx(() {
            final patients = logic.patientCount.value;
            final recordings = logic.recordingCount.value;
            return Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: '患者',
                    value: '$patients',
                    icon: Icons.people_outline,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatChip(
                    label: '录音',
                    value: '$recordings',
                    icon: Icons.graphic_eq,
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 20.h),
          Text(
            '快捷入口',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: WbTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  title: '患者',
                  subtitle: '维护我的患者',
                  icon: Icons.person_outline,
                  accent: WbTheme.primary,
                  onTap: _openPatients,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _FeatureCard(
                  title: '录音',
                  subtitle: '病情与沟通录音',
                  icon: Icons.mic_none_outlined,
                  accent: WbTheme.primaryDark,
                  onTap: _openRecordings,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const _FlowHint(),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D5DB0),
            Color(0xFF2657C9),
            Color(0xFF4A7DD9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A7DD9).withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8.w,
            top: -12.h,
            child: Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 28.w,
            bottom: -32.h,
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Dr.Claw',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                '全医疗场景',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.78),
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '医务人员专属 AI 助手',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '选患者 · 录音 · 发送生成文书',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.72),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: WbTheme.backgroundLight,
        borderRadius: WbTheme.radiusLg,
        border: Border.all(color: WbTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: WbTheme.primaryAlpha8,
              borderRadius: WbTheme.radiusSm,
            ),
            child: Icon(icon, size: 18.w, color: WbTheme.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: WbTheme.textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: WbTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WbTheme.backgroundLight,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: WbTheme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 24.w, color: accent),
              ),
              SizedBox(height: 14.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: WbTheme.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: WbTheme.textSecondary,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text(
                    '进入',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.arrow_forward_ios, size: 10.w, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowHint extends StatelessWidget {
  const _FlowHint();

  @override
  Widget build(BuildContext context) {
    final steps = ['选患者', '录音', '发送'];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: WbTheme.primaryAlpha8,
        borderRadius: WbTheme.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐流程',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: WbTheme.primaryDark,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16.w,
                      color: WbTheme.primary.withOpacity(0.45),
                    ),
                  ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: WbTheme.backgroundLight,
                      borderRadius: WbTheme.radiusSm,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: WbTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
