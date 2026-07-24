import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 过程消息精简条：思考 / 执行中 / 已完成
class ChatAgentRuntimeView extends StatelessWidget {
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

  bool get _isThinking => kind == 'thinking';
  bool get _isCall => kind == 'tool_call';

  String get _title {
    if (_isThinking) return '正在思考';
    final tool = AgentCardLabels.tool(toolName);
    if (_isCall) return '正在执行 · $tool';
    return '已完成 · $tool';
  }

  String get _preview {
    final raw = _isThinking ? text.trim() : body.trim();
    return AgentCardLabels.preview(raw, maxChars: 72);
  }

  IconData get _icon {
    if (_isThinking) return Icons.more_horiz;
    if (_isCall) return Icons.play_arrow_rounded;
    return Icons.check_rounded;
  }

  Color get _accent {
    if (_isThinking) return const Color(0xFF8E9AB0);
    if (_isCall) return const Color(0xFF2563EB);
    return const Color(0xFF16A34A);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return Container(
      constraints: BoxConstraints(maxWidth: 260.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8ECF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 16.sp, color: _accent),
              6.horizontalSpace,
              Flexible(
                child: Text(
                  _title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Styles.c_0C1C33,
                  ),
                ),
              ),
            ],
          ),
          if (preview.isNotEmpty) ...[
            4.verticalSpace,
            Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
            ),
          ],
        ],
      ),
    );
  }
}
