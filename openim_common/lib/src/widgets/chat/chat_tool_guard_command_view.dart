import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';

/// 用户发出的 `/approval` 命令在聊天气泡中的友好渲染
class ChatToolGuardCommandView extends StatelessWidget {
  const ChatToolGuardCommandView({
    Key? key,
    required this.isISend,
    required this.approved,
    this.scope,
  }) : super(key: key);

  final bool isISend;
  final bool approved;

  /// `exact` | `pattern` | null
  final String? scope;

  String get _title {
    if (!approved) return '已拒绝';
    if (scope == 'pattern') return '总是允许';
    if (scope == 'exact') return '仅本次批准';
    return '已批准';
  }

  IconData get _icon {
    if (!approved) return Icons.close_rounded;
    if (scope == 'pattern') return Icons.all_inclusive;
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
    final border = isISend
        ? Colors.white.withOpacity(0.35)
        : _fg.withOpacity(0.25);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 15.sp, color: fg),
          6.horizontalSpace,
          Icon(_icon, size: 15.sp, color: fg),
          4.horizontalSpace,
          Flexible(
            child: Text(
              _title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
