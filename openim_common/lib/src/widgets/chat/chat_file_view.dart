import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// 文件消息气泡。
class ChatFileView extends StatelessWidget {
  const ChatFileView({
    Key? key,
    required this.message,
    required this.isISend,
  }) : super(key: key);

  final Message message;
  final bool isISend;

  FileElem? get _file => message.fileElem;

  @override
  Widget build(BuildContext context) {
    final name = _file?.fileName ?? StrRes.file;
    final size = _file?.fileSize ?? 0;
    final icon = IMUtils.fileIcon(name);
    final nameStyle =
        isISend ? Styles.ts_FFFFFF_17sp : Styles.ts_0C1C33_17sp;
    final sizeStyle =
        isISend ? Styles.ts_FFFFFF_12sp : Styles.ts_8E9AB0_12sp;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.toImage
            ..width = 38.w
            ..height = 44.h,
          10.horizontalSpace,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: nameStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                4.verticalSpace,
                Text(IMUtils.formatBytes(size), style: sizeStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
