import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';

/// Agent Tool Guard 审批卡片（对齐 Console ApprovalCard）
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

  /// 仅本次（--exact）
  final VoidCallback? onApproveExact;

  /// 总是允许（--pattern）
  final VoidCallback? onApprovePattern;

  /// 非泛化场景的单一批准
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
  bool _paramsExpanded = false;
  bool _detailsExpanded = false;

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
        return Styles.c_8E9AB0;
    }
  }

  String get _displaySource {
    final source = widget.toolSource.trim();
    if (source.isEmpty || source == 'builtin') return '内置';
    return source;
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
    if (next <= 0) {
      _timer?.cancel();
    }
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
        borderRadius: BorderRadius.circular(12.r),
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
          _infoRow('工具', widget.toolName, code: true),
          8.verticalSpace,
          _infoRow('来源', _displaySource, code: true),
          8.verticalSpace,
          _infoRow(
            '严重性',
            widget.severity.isEmpty ? 'INFO' : widget.severity.toUpperCase(),
            tagColor: _severityColor,
          ),
          8.verticalSpace,
          _infoRow('发现', '${widget.findingsCount}'),
          if (_showScope) ...[
            12.verticalSpace,
            _buildScopeSection(),
          ],
          if (widget.toolParams.isNotEmpty) ...[
            10.verticalSpace,
            _buildExpandable(
              title: '参数',
              expanded: _paramsExpanded,
              onToggle: () => setState(() => _paramsExpanded = !_paramsExpanded),
              body: jsonEncode(widget.toolParams),
            ),
          ],
          if (widget.summary.trim().isNotEmpty) ...[
            8.verticalSpace,
            _buildExpandable(
              title: '详细信息',
              expanded: _detailsExpanded,
              onToggle: () =>
                  setState(() => _detailsExpanded = !_detailsExpanded),
              body: widget.summary.trim(),
              showInfoIcon: true,
            ),
          ],
          12.verticalSpace,
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.shield_outlined, size: 16.sp, color: _accent),
        6.horizontalSpace,
        Expanded(
          child: Text(
            '安全审批',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Styles.c_0C1C33,
            ),
          ),
        ),
        if (_pending)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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

  Widget _infoRow(
    String label,
    String value, {
    bool code = false,
    Color? tagColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52.w,
          child: Text(
            '$label：',
            style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
          ),
        ),
        Expanded(
          child: tagColor != null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: tagColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : code
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Styles.c_0C1C33,
                          fontFamily: 'monospace',
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(fontSize: 12.sp, color: Styles.c_0C1C33),
                    ),
        ),
      ],
    );
  }

  Widget _buildScopeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '批准范围：',
          style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
        ),
        6.verticalSpace,
        if (widget.exactTarget.isNotEmpty)
          _scopeItem('仅本次', widget.exactTarget),
        if (widget.similarTarget.isNotEmpty) ...[
          6.verticalSpace,
          _scopeItem(
            '总是允许',
            widget.similarTarget,
            warn: _alwaysAllowDisabled,
          ),
        ],
      ],
    );
  }

  Widget _scopeItem(String label, String value, {bool warn = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label：',
          style: TextStyle(fontSize: 11.sp, color: Styles.c_8E9AB0),
        ),
        4.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Styles.c_0C1C33,
              fontFamily: 'monospace',
              height: 1.35,
            ),
          ),
        ),
        if (warn) ...[
          4.verticalSpace,
          Row(
            children: [
              Icon(Icons.error_outline, size: 14.sp, color: _denyFg),
              4.horizontalSpace,
              Expanded(
                child: Text(
                  '该来源不支持总是允许',
                  style: TextStyle(fontSize: 11.sp, color: _denyFg),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildExpandable({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required String body,
    bool showInfoIcon = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 16.sp,
                  color: Styles.c_8E9AB0,
                ),
                if (showInfoIcon) ...[
                  2.horizontalSpace,
                  Icon(Icons.info_outline, size: 12.sp, color: Styles.c_8E9AB0),
                ],
                4.horizontalSpace,
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12.sp, color: Styles.c_0C1C33),
                  ),
                ),
                if (expanded)
                  GestureDetector(
                    onTap: () => _copy(body),
                    child: Icon(Icons.copy, size: 14.sp, color: Styles.c_8E9AB0),
                  ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          6.verticalSpace,
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: 140.h),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: SingleChildScrollView(
              child: Text(
                body,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.4,
                  color: Styles.c_0C1C33,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    if (!_pending) {
      return Text(
        widget.status == 'approved'
            ? '已批准'
            : (widget.status == 'denied' ? '已拒绝' : widget.status),
        style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
      );
    }
    if (!_hasActions) {
      return Text(
        '点击处理审批',
        style: TextStyle(fontSize: 12.sp, color: _accent),
      );
    }
    if (_remaining <= 0 && widget.timeoutSeconds > 0) {
      return Text(
        '已超时，自动拒绝',
        style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
      );
    }

    if (_showScope) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _denyButton()),
              8.horizontalSpace,
              Expanded(
                child: _primaryButton(
                  '仅本次',
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
                padding: EdgeInsets.symmetric(vertical: 8.h),
                minimumSize: Size(0, 34.h),
              ),
              child: Text('总是允许', style: TextStyle(fontSize: 13.sp)),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _denyButton()),
        8.horizontalSpace,
        Expanded(
          child: _primaryButton(
            '批准',
            onPressed: widget.onApprove ?? widget.onApproveExact,
          ),
        ),
      ],
    );
  }

  Widget _denyButton() {
    return TextButton(
      onPressed: widget.onDeny,
      style: TextButton.styleFrom(
        backgroundColor: _denyBg,
        foregroundColor: _denyFg,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        minimumSize: Size(0, 34.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.close, size: 14.sp),
          4.horizontalSpace,
          Text('拒绝', style: TextStyle(fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        minimumSize: Size(0, 34.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check, size: 14.sp),
          4.horizontalSpace,
          Text(label, style: TextStyle(fontSize: 13.sp)),
        ],
      ),
    );
  }
}
