import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 用户确认操作后的精简状态条
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

  IconData get _icon {
    if (!approved) return Icons.close_rounded;
    if (scope == 'pattern') return Icons.shield_outlined;
    return Icons.check_rounded;
  }

  Color get _fg {
    if (!approved) return const Color(0xFFE53935);
    if (scope == 'pattern') return const Color(0xFFEA8A1A);
    return const Color(0xFF2F9E55);
  }

  Color get _bg {
    if (!approved) return const Color(0xFFFFF1F0);
    if (scope == 'pattern') return const Color(0xFFFFF7ED);
    return const Color(0xFFF0FDF4);
  }

  Color get _border {
    if (!approved) return const Color(0xFFFFD4D0);
    if (scope == 'pattern') return const Color(0xFFFFE4C4);
    return const Color(0xFFCDEAD6);
  }

  @override
  Widget build(BuildContext context) {
    final fg = isISend ? Colors.white : _fg;
    final bg = isISend ? Colors.white.withOpacity(0.16) : _bg;
    final border = isISend ? Colors.white.withOpacity(0.28) : _border;
    final iconBg = isISend ? Colors.white.withOpacity(0.18) : Colors.white;

    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 7.h, 12.w, 7.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 13.sp, color: fg),
          ),
          7.horizontalSpace,
          Flexible(
            child: Text(
              _title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: fg,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
