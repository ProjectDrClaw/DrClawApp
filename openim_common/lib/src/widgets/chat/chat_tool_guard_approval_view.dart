import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 安全确认卡片（用户友好版）
class ChatToolGuardApprovalView extends StatefulWidget {
  const ChatToolGuardApprovalView({
    Key? key,
    required this.toolName,
    required this.severity,
    required this.summary,
    required this.status,
    this.toolSource = '',
    this.findingsCount = 0,
    this.toolParams = const {},
    this.createdAt = 0,
    this.timeoutSeconds = 300,
    this.isGeneralized = false,
    this.exactTarget = '',
    this.similarTarget = '',
    this.onApproveExact,
    this.onApprovePattern,
    this.onApprove,
    this.onDeny,
  }) : super(key: key);

  final String toolName;
  final String toolSource;
  final String severity;
  final int findingsCount;
  final String summary;
  final Map<String, dynamic> toolParams;
  final double createdAt;
  final double timeoutSeconds;
  final bool isGeneralized;
  final String exactTarget;
  final String similarTarget;
  final String status;
  final VoidCallback? onApproveExact;
  final VoidCallback? onApprovePattern;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;

  @override
  State<ChatToolGuardApprovalView> createState() =>
      _ChatToolGuardApprovalViewState();
}

class _ChatToolGuardApprovalViewState extends State<ChatToolGuardApprovalView> {
  static const _accent = Color(0xFFF97316);
  static const _denyBg = Color(0xFFFFF1F0);
  static const _denyFg = Color(0xFFE53935);

  Timer? _timer;
  int _remaining = 0;
  bool _moreExpanded = false;

  bool get _pending => widget.status == 'pending' || widget.status.isEmpty;

  bool get _hasActions =>
      widget.onDeny != null ||
      widget.onApprove != null ||
      widget.onApproveExact != null ||
      widget.onApprovePattern != null;

  bool get _showScope =>
      widget.isGeneralized &&
      (widget.exactTarget.isNotEmpty || widget.similarTarget.isNotEmpty);

  bool get _alwaysAllowDisabled =>
      widget.toolSource.trim().toUpperCase() == 'STRICT MODE';

  Color get _severityColor {
    switch (widget.severity.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return const Color(0xFFE53935);
      case 'MEDIUM':
        return const Color(0xFFFB8C00);
      case 'LOW':
        return const Color(0xFF43A047);
      default:
        return _accent;
    }
  }

  String get _friendlyTool => AgentCardLabels.tool(widget.toolName);

  String get _actionPreview {
    if (widget.exactTarget.trim().isNotEmpty) {
      return AgentCardLabels.preview(widget.exactTarget, maxChars: 120);
    }
    if (widget.toolParams.isNotEmpty) {
      return AgentCardLabels.preview(
        jsonEncode(widget.toolParams),
        maxChars: 120,
      );
    }
    return AgentCardLabels.preview(widget.summary, maxChars: 120);
  }

  String get _riskHint {
    final summary = AgentCardLabels.preview(widget.summary, maxChars: 100);
    if (summary.isNotEmpty) return summary;
    if (widget.findingsCount > 0) {
      return '发现 ${widget.findingsCount} 项需要你确认的风险点';
    }
    return '该操作可能影响设备或数据，请确认后继续';
  }

  @override
  void initState() {
    super.initState();
    _syncRemaining();
    if (_pending && widget.timeoutSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        _syncRemaining();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChatToolGuardApprovalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.createdAt != widget.createdAt ||
        oldWidget.timeoutSeconds != widget.timeoutSeconds ||
        oldWidget.status != widget.status) {
      _syncRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncRemaining() {
    final timeout = widget.timeoutSeconds;
    if (timeout <= 0) {
      setState(() => _remaining = 0);
      return;
    }
    final created = widget.createdAt;
    final elapsed = created > 0
        ? (DateTime.now().millisecondsSinceEpoch / 1000.0) - created
        : 0.0;
    final next = (timeout - elapsed).floor().clamp(0, timeout.floor());
    setState(() => _remaining = next);
    if (next <= 0) _timer?.cancel();
  }

  String get _timerText {
    final m = _remaining ~/ 60;
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _copy(String text) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE8ECF1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F0F172A).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          12.verticalSpace,
          Text(
            '请求执行：$_friendlyTool',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Styles.c_0C1C33,
              height: 1.35,
            ),
          ),
          if (_actionPreview.isNotEmpty) ...[
            8.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _actionPreview,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: Styles.c_0C1C33,
                ),
              ),
            ),
          ],
          10.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _chip(AgentCardLabels.severity(widget.severity), _severityColor),
              _chip(AgentCardLabels.source(widget.toolSource), Styles.c_8E9AB0),
            ],
          ),
          10.verticalSpace,
          Text(
            _riskHint,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color: Styles.c_8E9AB0,
            ),
          ),
          if (_showScope) ...[
            12.verticalSpace,
            _buildScopeHint(),
          ],
          if (_hasMoreContent) ...[
            10.verticalSpace,
            _buildMore(),
          ],
          14.verticalSpace,
          _buildActions(),
        ],
      ),
    );
  }

  bool get _hasMoreContent =>
      widget.summary.trim().isNotEmpty || widget.toolParams.isNotEmpty;

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.shield_outlined, size: 16.sp, color: _accent),
        ),
        8.horizontalSpace,
        Expanded(
          child: Text(
            '需要你确认',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Styles.c_0C1C33,
            ),
          ),
        ),
        if (_pending)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 13.sp, color: Styles.c_8E9AB0),
                4.horizontalSpace,
                Text(
                  _timerText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Styles.c_8E9AB0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildScopeHint() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '你可以怎么选',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Styles.c_0C1C33,
            ),
          ),
          6.verticalSpace,
          Text(
            '• 同意一次：只放行当前这次操作\n'
            '• 以后都允许：同类操作之后可自动通过'
            '${_alwaysAllowDisabled ? '\n• 当前为严格模式，暂不支持“以后都允许”' : ''}',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: Styles.c_8E9AB0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMore() {
    final detail = widget.summary.trim().isNotEmpty
        ? widget.summary.trim()
        : jsonEncode(widget.toolParams);
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _moreExpanded = !_moreExpanded),
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              children: [
                Icon(
                  _moreExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18.sp,
                  color: Styles.c_8E9AB0,
                ),
                4.horizontalSpace,
                Text(
                  _moreExpanded ? '收起详细说明' : '查看详细说明',
                  style: TextStyle(fontSize: 12.sp, color: Styles.c_0089FF),
                ),
              ],
            ),
          ),
        ),
        if (_moreExpanded) ...[
          6.verticalSpace,
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: 140.h),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 100.h),
                  child: SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.4,
                          color: Styles.c_0C1C33,
                        ),
                      ),
                    ),
                  ),
                ),
                6.verticalSpace,
                GestureDetector(
                  onTap: () => _copy(detail),
                  child: Text(
                    '复制',
                    style: TextStyle(fontSize: 12.sp, color: Styles.c_0089FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    if (!_pending) {
      final done = widget.status == 'approved';
      return Text(
        done ? '你已同意，将继续处理' : '你已拒绝，不会执行该操作',
        style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
      );
    }
    if (!_hasActions) {
      return Text(
        '点按打开确认窗口',
        style: TextStyle(fontSize: 12.sp, color: _accent),
      );
    }
    if (_remaining <= 0 && widget.timeoutSeconds > 0) {
      return Text(
        '确认已超时，已自动拒绝',
        style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
      );
    }

    if (_showScope) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _denyButton('拒绝')),
              8.horizontalSpace,
              Expanded(
                child: _primaryButton(
                  '同意一次',
                  onPressed: widget.onApproveExact ?? widget.onApprove,
                ),
              ),
            ],
          ),
          8.verticalSpace,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _alwaysAllowDisabled
                  ? null
                  : (widget.onApprovePattern ?? widget.onApprove),
              style: OutlinedButton.styleFrom(
                foregroundColor: Styles.c_0C1C33,
                side: const BorderSide(color: Color(0xFFE8EAEF)),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                minimumSize: Size(0, 40.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text('以后都允许', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _denyButton('拒绝')),
        8.horizontalSpace,
        Expanded(
          child: _primaryButton(
            '同意',
            onPressed: widget.onApprove ?? widget.onApproveExact,
          ),
        ),
      ],
    );
  }

  Widget _denyButton(String label) {
    return TextButton(
      onPressed: widget.onDeny,
      style: TextButton.styleFrom(
        backgroundColor: _denyBg,
        foregroundColor: _denyFg,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        minimumSize: Size(0, 40.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
    );
  }

  Widget _primaryButton(String label, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        minimumSize: Size(0, 40.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
    );
  }
}
