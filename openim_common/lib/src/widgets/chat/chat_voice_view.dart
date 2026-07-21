import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openim_common/openim_common.dart';

/// 语音消息气泡：点击播放 / 暂停。
class ChatVoiceView extends StatefulWidget {
  const ChatVoiceView({
    Key? key,
    required this.message,
    required this.isISend,
  }) : super(key: key);

  final Message message;
  final bool isISend;

  @override
  State<ChatVoiceView> createState() => _ChatVoiceViewState();
}

class _ChatVoiceViewState extends State<ChatVoiceView> {
  final _player = AudioPlayer();
  bool _playing = false;

  SoundElem? get _sound => widget.message.soundElem;

  int get _duration => (_sound?.duration ?? 1).clamp(1, 60);

  double get _width => (60.w + _duration * 3.w).clamp(60.w, 180.w);

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing = state.playing && state.processingState != ProcessingState.completed;
      if (_playing != playing) {
        setState(() => _playing = playing);
      }
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    try {
      final path = _sound?.soundPath;
      final url = _sound?.sourceUrl;
      if (path != null && path.isNotEmpty && File(path).existsSync()) {
        await _player.setFilePath(path);
      } else if (url != null && url.isNotEmpty) {
        await _player.setUrl(url);
      } else {
        IMViews.showToast(StrRes.unsupportedMessage);
        return;
      }
      await _player.play();
    } catch (e) {
      IMViews.showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.isISend
        ? (_playing ? ImageRes.voiceWhite : ImageRes.voiceWhite)
        : (_playing ? ImageRes.voiceBlue : ImageRes.voiceBlue);
    final textStyle =
        widget.isISend ? Styles.ts_FFFFFF_17sp : Styles.ts_0C1C33_17sp;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _togglePlay,
      child: SizedBox(
        width: _width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isISend) ...[
              icon.toImage
                ..width = 24.w
                ..height = 24.h,
              6.horizontalSpace,
            ],
            Text('$_duration"', style: textStyle),
            if (widget.isISend) ...[
              6.horizontalSpace,
              icon.toImage
                ..width = 24.w
                ..height = 24.h,
            ],
          ],
        ),
      ),
    );
  }
}
