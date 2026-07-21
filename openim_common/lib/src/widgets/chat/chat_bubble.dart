import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

enum BubbleType {
  send,
  receiver,
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    this.margin,
    this.constraints,
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.child,
    required this.bubbleType,
  }) : super(key: key);
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Color? backgroundColor;
  final Widget? child;
  final BubbleType bubbleType;

  bool get isISend => bubbleType == BubbleType.send;

  @override
  Widget build(BuildContext context) => Container(
        constraints: constraints,
        margin: margin,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        alignment: alignment,
        decoration: BoxDecoration(
          // 发送气泡用品牌主色，配合白色文字（旧浅蓝底+白字会「白乎乎」看不清）
          color: backgroundColor ??
              (isISend ? const Color(0xFF4A7DD9) : Styles.c_F4F5F7),
          borderRadius: borderRadius(isISend),
        ),
        child: child,
      );
}
