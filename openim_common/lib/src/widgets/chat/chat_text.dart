import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:openim_common/openim_common.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatText extends StatelessWidget {
  const ChatText({
    Key? key,
    this.isISend = false,
    required this.text,
    this.prefixSpan,
    this.patterns = const <MatchPattern>[],
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.clip,
    this.textStyle,
    this.maxLines,
    this.textScaleFactor = 1.0,
    this.model = TextModel.match,
    this.enableMarkdown = true,
    this.onVisibleTrulyText,
  }) : super(key: key);

  final bool isISend;
  final String text;
  final TextStyle? textStyle;
  final InlineSpan? prefixSpan;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final double textScaleFactor;
  final List<MatchPattern> patterns;
  final TextModel model;
  /// 聊天气泡默认开启 Markdown；截断预览等场景可关闭。
  final bool enableMarkdown;
  final Function(String? text)? onVisibleTrulyText;

  bool get _useMarkdown =>
      enableMarkdown && model == TextModel.match && maxLines == null && prefixSpan == null;

  @override
  Widget build(BuildContext context) {
    if (!_useMarkdown) {
      return MatchTextView(
        text: text,
        textStyle: textStyle ??
            (isISend ? Styles.ts_FFFFFF_17sp : Styles.ts_0C1C33_17sp),
        matchTextStyle: Styles.ts_0089FF_17sp,
        prefixSpan: prefixSpan,
        textAlign: textAlign,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        patterns: patterns,
        model: model,
        maxLines: maxLines,
        onVisibleTrulyText: onVisibleTrulyText,
      );
    }

    onVisibleTrulyText?.call(text);

    final baseStyle = textStyle ??
        (isISend ? Styles.ts_FFFFFF_17sp : Styles.ts_0C1C33_17sp);
    final linkStyle = (isISend
            ? Styles.ts_FFFFFF_17sp.copyWith(
                color: const Color(0xFFD6EBFF),
                decoration: TextDecoration.underline,
              )
            : Styles.ts_0089FF_17sp)
        .copyWith(decoration: TextDecoration.underline);
    final codeBg = isISend
        ? const Color(0x33FFFFFF)
        : const Color(0x140C1C33);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScaleFactor),
        ),
        child: MarkdownBody(
          data: prepareChatMarkdown(text),
          selectable: false,
          softLineBreak: true,
          styleSheet: MarkdownStyleSheet(
            p: baseStyle,
            a: linkStyle,
            em: baseStyle.copyWith(fontStyle: FontStyle.italic),
            strong: baseStyle.copyWith(fontWeight: FontWeight.w600),
            del: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
            code: baseStyle.copyWith(
              fontFamily: 'monospace',
              fontSize: (baseStyle.fontSize ?? 17) * 0.9,
              backgroundColor: codeBg,
            ),
            codeblockDecoration: BoxDecoration(
              color: codeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            codeblockPadding: const EdgeInsets.all(8),
            blockquote: baseStyle.copyWith(
              color: baseStyle.color?.withValues(alpha: 0.85),
            ),
            blockquoteDecoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isISend
                      ? const Color(0x99FFFFFF)
                      : Styles.c_0089FF,
                  width: 3,
                ),
              ),
            ),
            blockquotePadding: const EdgeInsets.only(left: 10),
            h1: baseStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
            h2: baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            h3: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
            h4: baseStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
            h5: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
            h6: baseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
            listBullet: baseStyle,
            tableHead: baseStyle.copyWith(fontWeight: FontWeight.w600),
            tableBody: baseStyle,
            tableBorder: TableBorder.all(
              color: isISend
                  ? const Color(0x66FFFFFF)
                  : const Color(0x330C1C33),
              width: 0.5,
            ),
            horizontalRuleDecoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isISend
                      ? const Color(0x66FFFFFF)
                      : const Color(0x330C1C33),
                ),
              ),
            ),
            blockSpacing: 8,
            listIndent: 20,
          ),
          onTapLink: (label, href, title) => _handleLinkTap(href),
        ),
      ),
    );
  }

  void _handleLinkTap(String? href) {
    final link = (href ?? '').trim();
    if (link.isEmpty) return;

    for (final pattern in patterns) {
      if (pattern.type == PatternType.url ||
          pattern.type == PatternType.email ||
          pattern.type == PatternType.mobile ||
          pattern.type == PatternType.tel) {
        pattern.onTap?.call(link, pattern.type);
        return;
      }
    }

    final uri = Uri.tryParse(link);
    if (uri == null) return;
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// 聊天气泡内保留常见换行：代码围栏外的单换行转为 Markdown 硬换行。
@visibleForTesting
String prepareChatMarkdown(String source) {
  if (source.isEmpty) return source;

  final lines = source.split('\n');
  final out = <String>[];
  var inFence = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('```')) {
      inFence = !inFence;
      out.add(line);
      continue;
    }
    if (inFence || i == lines.length - 1 || line.trim().isEmpty) {
      out.add(line);
    } else {
      out.add('$line  ');
    }
  }
  return out.join('\n');
}
