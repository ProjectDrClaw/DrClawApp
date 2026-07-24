import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 审批回执：已同意 / 已拒绝（用户友好版）
class ChatToolGuardResultView extends StatelessWidget {
  const ChatToolGuardResultView({
    Key? key,
    required this.approved,
    this.toolName = '',
    this.detail = '',
  }) : super(key: key);

  final bool approved;
  final String toolName;
  final String detail;

  Color get _fg =>
      approved ? const Color(0xFF16A34A) : const Color(0xFFE53935);

  Color get _bg =>
      approved ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F0);

  IconData get _icon =>
      approved ? Icons.check_circle_outline : Icons.cancel_outlined;

  String get _title => approved ? '已同意，开始执行' : '已拒绝该操作';

  String get _body {
    final tool = AgentCardLabels.tool(toolName);
    if (approved) {
      final status = AgentCardLabels.preview(detail, maxChars: 40);
      if (status.isNotEmpty && status != '正在执行...') {
        return '「$tool」$status';
      }
      return '「$tool」正在处理中';
    }
    final reason = AgentCardLabels.preview(detail, maxChars: 60);
    if (reason.isNotEmpty && reason != '用户拒绝') {
      return '「$tool」未执行：$reason';
    }
    return '「$tool」未执行';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _fg.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(_icon, size: 18.sp, color: _fg),
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _fg,
                  ),
                ),
                4.verticalSpace,
                Text(
                  _body,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.4,
                    color: Styles.c_0C1C33,
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
