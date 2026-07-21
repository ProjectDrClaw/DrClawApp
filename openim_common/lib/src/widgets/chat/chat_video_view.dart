import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// 视频消息气泡：封面 + 播放图标。
class ChatVideoView extends StatelessWidget {
  const ChatVideoView({
    Key? key,
    required this.message,
    required this.isISend,
  }) : super(key: key);

  final Message message;
  final bool isISend;

  VideoElem? get _video => message.videoElem;

  @override
  Widget build(BuildContext context) {
    final snapshotPath = _video?.snapshotPath;
    final snapshotUrl = _video?.snapshotUrl;
    final w = videoWidth;
    final h = videoWidth * 4 / 3;

    Widget cover;
    if (snapshotPath != null &&
        snapshotPath.isNotEmpty &&
        File(snapshotPath).existsSync()) {
      cover = ImageUtil.fileImage(
        file: File(snapshotPath),
        width: w,
        height: h,
        fit: BoxFit.cover,
      );
    } else if (IMUtils.isNotNullEmptyStr(snapshotUrl)) {
      cover = ImageUtil.networkImage(
        url: snapshotUrl!,
        width: w,
        height: h,
        fit: BoxFit.cover,
      );
    } else {
      cover = Container(
        width: w,
        height: h,
        color: Styles.c_E8EAEF,
        alignment: Alignment.center,
        child: Text(StrRes.video, style: Styles.ts_8E9AB0_14sp),
      );
    }

    final duration = (_video?.duration ?? 0).clamp(0, 9999);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: cover,
          ),
          ImageRes.videoPause.toImage
            ..width = 40.w
            ..height = 40.h,
          if (duration > 0)
            Positioned(
              right: 6.w,
              bottom: 4.h,
              child: Text(
                _formatDuration(duration),
                style: Styles.ts_FFFFFF_12sp,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
