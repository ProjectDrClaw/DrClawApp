import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 过程消息：调用中 / 已完成 / 正在思考
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
    if (_isCall) return '正在执行';
    return '操作已完成';
  }

  String get _subtitle {
    if (_isThinking) return '整理信息并准备下一步';
    final tool = AgentCardLabels.tool(widget.toolName);
    if (_isCall) return '进行中：$tool';
    return '已完成：$tool';
  }

  IconData get _icon {
    if (_isThinking) return Icons.lightbulb_outline;
    if (_isCall) return Icons.play_circle_outline;
    return Icons.task_alt_outlined;
  }

  Color get _accent {
    if (_isThinking) return const Color(0xFF7C3AED);
    if (_isCall) return const Color(0xFF2563EB);
    return const Color(0xFF16A34A);
  }

  String get _content {
    if (_isThinking) return widget.text.trim();
    return widget.body.trim();
  }

  String get _preview => AgentCardLabels.preview(_content, maxChars: 90);

  Future<void> _copy() async {
    if (_content.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _content));
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    return Container(
      width: 280.w,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE8ECF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(_icon, size: 16.sp, color: _accent),
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Styles.c_0C1C33,
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      _subtitle,
                      style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_preview.isNotEmpty) ...[
            10.verticalSpace,
            Text(
              _preview,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.4,
                color: Styles.c_0C1C33,
              ),
            ),
          ],
          if (content.isNotEmpty && content.length > 40) ...[
            8.verticalSpace,
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? '收起' : '查看更多',
                    style: TextStyle(fontSize: 12.sp, color: Styles.c_0089FF),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _copy,
                  child: Text(
                    '复制详情',
                    style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
                  ),
                ),
              ],
            ),
          ],
          if (_expanded && content.isNotEmpty) ...[
            8.verticalSpace,
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 150.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    color: Styles.c_0C1C33,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
