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
      approved ? const Color(0xFF2F9E55) : const Color(0xFFE53935);

  Color get _bg =>
      approved ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F0);

  Color get _border =>
      approved ? const Color(0xFFCDEAD6) : const Color(0xFFFFD4D0);

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
      padding: EdgeInsets.fromLTRB(8.w, 7.h, 12.w, 7.h),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 13.sp, color: _fg),
          ),
          7.horizontalSpace,
          Flexible(
            child: Text(
              _title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: _fg,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
