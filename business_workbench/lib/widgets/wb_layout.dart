import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/wb_theme.dart';

/// 列表空态
class WbEmptyView extends StatelessWidget {
  const WbEmptyView({
    super.key,
    required this.icon,
    required this.text,
    this.hint,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 48.h, left: 40.w, right: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: WbTheme.primaryAlpha8,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34.w, color: WbTheme.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: WbTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hint != null) ...[
              SizedBox(height: 8.h),
              Text(
                hint!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: WbTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 18.h),
              Material(
                color: WbTheme.primary,
                borderRadius: BorderRadius.circular(20.r),
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 清晰可辨的搜索栏（白底 + 描边，避免叠套默认灰底 SearchBox）
class WbSearchBar extends StatefulWidget {
  const WbSearchBar({
    super.key,
    this.hintText = '搜索',
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<WbSearchBar> createState() => _WbSearchBarState();
}

class _WbSearchBarState extends State<WbSearchBar> {
  late final TextEditingController _ctrl;
  late final bool _ownCtrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ownCtrl = widget.controller == null;
    _ctrl = widget.controller ?? TextEditingController();
    _hasText = _ctrl.text.isNotEmpty;
    _ctrl.addListener(_onText);
  }

  void _onText() {
    final v = _ctrl.text.isNotEmpty;
    if (v != _hasText) setState(() => _hasText = v);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    if (_ownCtrl) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: WbTheme.background,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: WbTheme.backgroundLight,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFDCDFE6), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 20.w, color: WbTheme.textSecondary),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: WbTheme.textPrimary,
                  height: 1.2,
                ),
                cursorColor: WbTheme.primary,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: WbTheme.textHint,
                    height: 1.2,
                  ),
                ),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ),
            if (_hasText)
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  widget.onChanged?.call('');
                  setState(() => _hasText = false);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Icon(
                    Icons.cancel,
                    size: 18.w,
                    color: WbTheme.textHint,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// @Deprecated 请改用 [WbSearchBar]
class WbSearchArea extends StatelessWidget {
  const WbSearchArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: WbTheme.background,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: child,
    );
  }
}

/// 列表数量提示条
class WbListHeader extends StatelessWidget {
  const WbListHeader({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: WbTheme.textSecondary,
        ),
      ),
    );
  }
}

/// 详情页分组白卡片
class WbGroupCard extends StatelessWidget {
  const WbGroupCard({super.key, required this.child, this.marginTop});

  final Widget child;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, marginTop ?? 12.h, 16.w, 0),
      decoration: BoxDecoration(
        color: WbTheme.backgroundLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: WbTheme.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// AppBar 右侧文字按钮
class WbTextAction extends StatelessWidget {
  const WbTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color ?? WbTheme.primary,
          ),
        ),
      ),
    );
  }
}
