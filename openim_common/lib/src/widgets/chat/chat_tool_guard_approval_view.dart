import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/src/res/styles.dart';
import 'package:openim_common/src/widgets/chat/agent_card_labels.dart';

/// 安全确认卡片（精简美化）
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
  static const _surface = Color(0xFFFFFBF7);
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

  bool get _showAlwaysAllow =>
      widget.isGeneralized &&
      (widget.onApprovePattern != null || widget.onApprove != null);

  bool get _alwaysAllowDisabled =>
      widget.toolSource.trim().toUpperCase() == 'STRICT MODE';

  String get _friendlyTool => AgentCardLabels.tool(widget.toolName);

  String get _detail {
    if (widget.exactTarget.trim().isNotEmpty) {
      return AgentCardLabels.preview(widget.exactTarget, maxChars: 160);
    }
    if (widget.toolParams.isNotEmpty) {
      return AgentCardLabels.preview(
        jsonEncode(widget.toolParams),
        maxChars: 160,
      );
    }
    return AgentCardLabels.preview(widget.summary, maxChars: 160);
  }

  bool get _isHighRisk {
    final s = widget.severity.toUpperCase();
    return s == 'CRITICAL' || s == 'HIGH';
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

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Container(
      width: 276.w,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFE4CC)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3.w,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  bottomLeft: Radius.circular(14.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            size: 15.sp,
                            color: _accent,
                          ),
                        ),
                        8.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '需要确认',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Styles.c_0C1C33,
                                  height: 1.2,
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                _friendlyTool,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Styles.c_8E9AB0,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_pending && widget.timeoutSeconds > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFFFFE4CC),
                              ),
                            ),
                            child: Text(
                              _timerText,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: _accent,
                                fontWeight: FontWeight.w500,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (detail.isNotEmpty || _isHighRisk) ...[
                      8.verticalSpace,
                      GestureDetector(
                        onTap: () =>
                            setState(() => _moreExpanded = !_moreExpanded),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Text(
                              _moreExpanded ? '收起详情' : '查看详情',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Styles.c_0089FF,
                              ),
                            ),
                            Icon(
                              _moreExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16.sp,
                              color: Styles.c_0089FF,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_moreExpanded) ...[
                      if (detail.isNotEmpty) ...[
                        8.verticalSpace,
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            detail,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.45,
                              color: Styles.c_0C1C33,
                            ),
                          ),
                        ),
                      ],
                      if (_isHighRisk) ...[
                        8.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F0),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            AgentCardLabels.severity(widget.severity),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: _denyFg,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                    12.verticalSpace,
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (!_pending) {
      final done = widget.status == 'approved';
      return Text(
        done ? '已同意' : '已拒绝',
        style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
      );
    }
    if (!_hasActions) {
      return Text(
        '点按打开确认',
        style: TextStyle(fontSize: 12.sp, color: _accent),
      );
    }
    if (_remaining <= 0 && widget.timeoutSeconds > 0) {
      return Text(
        '已超时',
        style: TextStyle(fontSize: 12.sp, color: Styles.c_8E9AB0),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _denyButton()),
            8.horizontalSpace,
            Expanded(
              child: _primaryButton(
                _showAlwaysAllow ? '同意一次' : '同意',
                onPressed: widget.onApproveExact ?? widget.onApprove,
              ),
            ),
          ],
        ),
        if (_showAlwaysAllow) ...[
          8.verticalSpace,
          SizedBox(
            width: double.infinity,
            height: 34.h,
            child: OutlinedButton(
              onPressed: _alwaysAllowDisabled
                  ? null
                  : (widget.onApprovePattern ?? widget.onApprove),
              style: OutlinedButton.styleFrom(
                foregroundColor: Styles.c_0C1C33,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFFE4CC)),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              child: Text('以后都允许', style: TextStyle(fontSize: 13.sp)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _denyButton() {
    return SizedBox(
      height: 34.h,
      child: TextButton(
        onPressed: widget.onDeny,
        style: TextButton.styleFrom(
          backgroundColor: _denyBg,
          foregroundColor: _denyFg,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          '拒绝',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      height: 34.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
