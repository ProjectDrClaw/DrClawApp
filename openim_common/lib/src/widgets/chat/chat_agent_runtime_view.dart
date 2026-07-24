import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';

/// Agent 运行时消息卡片：工具调用 / 工具结果 / 思考
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
    if (_isThinking) return '思考过程';
    if (_isCall) return '工具调用';
    return '工具结果';
  }

  IconData get _icon {
    if (_isThinking) return Icons.psychology_alt_outlined;
    if (_isCall) return Icons.build_circle_outlined;
    return Icons.check_circle_outline;
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

  String get _subtitle {
    if (_isThinking) return '';
    return widget.toolName.trim().isEmpty ? 'tool' : widget.toolName.trim();
  }

  Future<void> _copy() async {
    final text = _content;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    return Container(
      width: 280.w,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE8ECF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(_icon, size: 16.sp, color: _accent),
              6.horizontalSpace,
              Expanded(
                child: Text(
                  _title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Styles.c_0C1C33,
                  ),
                ),
              ),
              if (content.isNotEmpty)
                GestureDetector(
                  onTap: _copy,
                  child: Icon(Icons.copy, size: 14.sp, color: Styles.c_8E9AB0),
                ),
            ],
          ),
          if (_subtitle.isNotEmpty) ...[
            8.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Styles.c_0C1C33,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (content.isNotEmpty) ...[
            8.verticalSpace,
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 16.sp,
                      color: Styles.c_8E9AB0,
                    ),
                    4.horizontalSpace,
                    Expanded(
                      child: Text(
                        _expanded ? '收起详情' : '展开详情',
                        style:
                            TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              6.verticalSpace,
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 160.h),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.4,
                      color: Styles.c_0C1C33,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ] else ...[
              6.verticalSpace,
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.35,
                  color: Styles.c_8E9AB0,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
