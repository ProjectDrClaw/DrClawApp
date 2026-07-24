import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 用户确认操作后的友好状态条
class ChatToolGuardCommandView extends StatelessWidget {
  const ChatToolGuardCommandView({
    Key? key,
    required this.isISend,
    required this.approved,
    this.scope,
  }) : super(key: key);

  final bool isISend;
  final bool approved;
  final String? scope;

  String get _title =>
      AgentCardLabels.commandAction(approved: approved, scope: scope);

  String get _hint =>
      AgentCardLabels.commandHint(approved: approved, scope: scope);

  IconData get _icon {
    if (!approved) return Icons.close_rounded;
    if (scope == 'pattern') return Icons.verified_user_outlined;
    return Icons.check_rounded;
  }

  Color get _fg {
    if (!approved) return const Color(0xFFE53935);
    if (scope == 'pattern') return const Color(0xFFFB8C00);
    return const Color(0xFF43A047);
  }

  Color get _bg {
    if (!approved) return const Color(0xFFFFF1F0);
    if (scope == 'pattern') return const Color(0xFFFFF7ED);
    return const Color(0xFFF0FDF4);
  }

  @override
  Widget build(BuildContext context) {
    final fg = isISend ? Colors.white : _fg;
    final bg = isISend ? Colors.white.withOpacity(0.18) : _bg;
    final border =
        isISend ? Colors.white.withOpacity(0.35) : _fg.withOpacity(0.22);
    final hintColor =
        isISend ? Colors.white.withOpacity(0.82) : const Color(0xFF8E9AB0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, size: 18.sp, color: fg),
          8.horizontalSpace,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                2.verticalSpace,
                Text(
                  _hint,
                  style: TextStyle(fontSize: 12.sp, color: hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
