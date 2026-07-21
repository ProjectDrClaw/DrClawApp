import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatToolBox extends StatelessWidget {
  const ChatToolBox({
    super.key,
    this.onTapAlbum,
    this.onTapFile,
    this.onTapCall,
    this.onTapPatient,
    this.onTapWardRecording,
  });
  final Function()? onTapAlbum;
  final Function()? onTapFile;
  final Function()? onTapCall;
  final Function()? onTapPatient;
  final Function()? onTapWardRecording;

  /// 与工具箱切图主色接近的石板蓝灰
  static const _glyphColor = Color(0xFF5C6B86);

  @override
  Widget build(BuildContext context) {
    final items = <ToolboxItemInfo>[
      ToolboxItemInfo(
        text: StrRes.toolboxAlbum,
        icon: ImageRes.toolboxAlbum,
        onTap: () => Permissions.photos(onTapAlbum),
      ),
      if (onTapFile != null)
        ToolboxItemInfo(
          text: StrRes.toolboxFile,
          icon: ImageRes.toolboxFile,
          onTap: onTapFile,
        ),
      if (onTapPatient != null)
        ToolboxItemInfo(
          text: StrRes.toolboxPatient,
          icon: ImageRes.toolboxCard,
          onTap: onTapPatient,
        ),
      if (onTapWardRecording != null)
        ToolboxItemInfo(
          text: StrRes.toolboxWardRecording,
          // 无现成 toolbox 切图，用同尺寸白底圆角 + 实心麦，与其它按钮视觉对齐
          iconBuilder: (onTap) => _toolboxStyleIcon(
            icon: Icons.mic_rounded,
            onTap: onTap,
          ),
          onTap: onTapWardRecording,
        ),
      if (onTapCall != null)
        ToolboxItemInfo(
          text: StrRes.toolboxCall,
          icon: ImageRes.toolboxCall,
          onTap: () => Permissions.cameraAndMicrophone(onTapCall),
        ),
    ];

    return Container(
      color: Styles.c_F0F2F6,
      height: 224.h,
      child: GridView.builder(
        itemCount: items.length,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 6.h,
          bottom: 6.h,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 78.w / 105.h,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 2.h,
        ),
        itemBuilder: (_, index) {
          final item = items.elementAt(index);
          return _buildItemView(item);
        },
      ),
    );
  }

  Widget _toolboxStyleIcon({
    required IconData icon,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 58.w,
          height: 58.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 28.w, color: _glyphColor),
        ),
      );

  Widget _buildItemView(ToolboxItemInfo item) {
    final iconView = item.iconBuilder?.call(item.onTap) ??
        (item.icon!.toImage
          ..width = 58.w
          ..height = 58.h
          ..onTap = item.onTap);

    return Column(
      children: [
        iconView,
        10.verticalSpace,
        item.text.toText..style = Styles.ts_0C1C33_12sp,
      ],
    );
  }
}

class ToolboxItemInfo {
  String text;
  String? icon;
  Widget Function(Function()? onTap)? iconBuilder;
  Function()? onTap;

  ToolboxItemInfo({
    required this.text,
    this.icon,
    this.iconBuilder,
    this.onTap,
  });
}
