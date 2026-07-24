/// 对话卡片文案：把技术字段转成用户可读中文
class AgentCardLabels {
  AgentCardLabels._();

  static String tool(String? raw) {
    final name = (raw ?? '').trim();
    if (name.isEmpty) return '未知操作';
    switch (name.toLowerCase()) {
      case 'bash':
      case 'shell':
      case 'execute_shell_command':
      case 'shell_exec':
        return '执行命令';
      case 'read_file':
        return '读取文件';
      case 'write_file':
        return '写入文件';
      case 'edit_file':
        return '编辑文件';
      case 'append_file':
        return '追加文件';
      case 'grep_search':
        return '搜索内容';
      case 'glob_search':
        return '查找文件';
      case 'browser_use':
        return '浏览网页';
      case 'web_search':
        return '联网搜索';
      case 'web_fetch':
        return '获取网页';
      case 'view_image':
        return '查看图片';
      case 'view_video':
        return '查看视频';
      case 'desktop_screenshot':
        return '截取屏幕';
      case 'send_file_to_user':
        return '发送文件';
      case 'get_current_time':
        return '获取时间';
      default:
        return name;
    }
  }

  static String severity(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'CRITICAL':
        return '极高风险';
      case 'HIGH':
        return '高风险';
      case 'MEDIUM':
        return '中风险';
      case 'LOW':
        return '低风险';
      case 'INFO':
      case '':
        return '需确认';
      default:
        return raw!.trim();
    }
  }

  static String source(String? raw) {
    final source = (raw ?? '').trim();
    if (source.isEmpty || source == 'builtin') return '系统安全策略';
    if (source.toUpperCase() == 'STRICT MODE') return '严格模式';
    if (source == 'No rule hit') return '安全策略';
    return source;
  }

  static String preview(String? raw, {int maxChars = 80}) {
    var text = (raw ?? '').trim();
    if (text.isEmpty) return '';
    // 去掉常见 markdown / 代码围栏噪音
    text = text
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        .replaceAll(RegExp(r'`([^`]*)`'), r'$1')
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}…';
  }

  static String commandAction({required bool approved, String? scope}) {
    if (!approved) return '已拒绝这次操作';
    if (scope == 'pattern') return '已设为以后都允许';
    if (scope == 'exact') return '已同意这次操作';
    return '已同意';
  }

  static String commandHint({required bool approved, String? scope}) {
    if (!approved) return '该操作将不会执行';
    if (scope == 'pattern') return '同类操作之后可自动通过';
    return '将继续执行该操作';
  }

  /// 会话列表摘要
  static String conversationSummary({
    required String kind,
    String? toolName,
    bool? approved,
    String? scope,
  }) {
    switch (kind) {
      case 'approval':
        return '[需要你确认] ${tool(toolName)}';
      case 'approval_result':
        return approved == true ? '[已同意操作]' : '[已拒绝操作]';
      case 'command':
        return '[${commandAction(approved: approved == true, scope: scope)}]';
      case 'tool_call':
        return '[正在执行] ${tool(toolName)}';
      case 'tool_result':
        return '[已完成] ${tool(toolName)}';
      case 'thinking':
        return '[正在思考]';
      default:
        return '[消息]';
    }
  }
}
