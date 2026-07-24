import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 过程消息精简条：思考 / 执行中 / 已完成（详情默认收起）
class ChatAgentRuntimeView extends StatefulWidget {
  const ChatAgentRuntimeView({
    Key? key,
    required this.kind,
    this.toolName = '',
    this.body = '',
    this.text = '',
  }) : super(key: key);

  /// `tool_call` | `tool_result` | `thinking`
  final String kind;
  final String toolName;
  final String body;
  final String text;

  @override
  State<ChatAgentRuntimeView> createState() => _ChatAgentRuntimeViewState();
}

class _ChatAgentRuntimeViewState extends State<ChatAgentRuntimeView> {
  bool _expanded = false;

  bool get _isThinking => widget.kind == 'thinking';
  bool get _isCall => widget.kind == 'tool_call';

  String get _title {
    if (_isThinking) return '正在思考';
    final tool = AgentCardLabels.tool(widget.toolName);
    if (_isCall) return '正在执行 · $tool';
    return '已完成 · $tool';
  }

  String get _detail {
    final raw = _isThinking ? widget.text.trim() : widget.body.trim();
    return AgentCardLabels.preview(raw, maxChars: 400);
  }

  IconData get _icon {
    if (_isThinking) return Icons.auto_awesome;
    if (_isCall) return Icons.bolt_rounded;
    return Icons.check_rounded;
  }

  Color get _accent {
    if (_isThinking) return const Color(0xFF64748B);
    if (_isCall) return const Color(0xFF2563EB);
    return const Color(0xFF16A34A);
  }

  Color get _bg {
    if (_isThinking) return const Color(0xFFF8FAFC);
    if (_isCall) return const Color(0xFFF5F8FF);
    return const Color(0xFFF3FBF6);
  }

  Color get _border {
    if (_isThinking) return const Color(0xFFE8ECF1);
    if (_isCall) return const Color(0xFFDCE7FF);
    return const Color(0xFFD8F0E0);
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final hasDetail = detail.isNotEmpty;

    return GestureDetector(
      onTap: hasDetail ? () => setState(() => _expanded = !_expanded) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: BoxConstraints(maxWidth: 260.w),
        padding: EdgeInsets.fromLTRB(10.w, 9.h, 12.w, 9.h),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: _border),
                  ),
                  child: Icon(_icon, size: 14.sp, color: _accent),
                ),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    _title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Styles.c_0C1C33,
                      height: 1.25,
                    ),
                  ),
                ),
                if (hasDetail)
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16.sp,
                    color: Styles.c_8E9AB0,
                  ),
              ],
            ),
            if (_expanded && hasDetail) ...[
              8.verticalSpace,
              Text(
                detail,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Styles.c_8E9AB0,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
