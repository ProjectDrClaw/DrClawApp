import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 审批回执精简条
class ChatToolGuardResultView extends StatelessWidget {
  const ChatToolGuardResultView({
    Key? key,
    required this.approved,
    this.toolName = '',
  }) : super(key: key);

  final bool approved;
  final String toolName;

  Color get _fg =>
      approved ? const Color(0xFF16A34A) : const Color(0xFFE53935);

  Color get _bg =>
      approved ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F0);

  IconData get _icon =>
      approved ? Icons.check_rounded : Icons.close_rounded;

  String get _title {
    final tool = AgentCardLabels.tool(toolName);
    if (approved) return '已同意 · $tool';
    return '已拒绝 · $tool';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 240.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 15.sp, color: _fg),
          6.horizontalSpace,
          Flexible(
            child: Text(
              _title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: _fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
