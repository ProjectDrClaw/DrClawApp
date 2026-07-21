/// IM 侧 Host：由主工程实现，业务包不直接依赖 ChatLogic / OpenIM SDK。
///
/// OpenIM 中助手与普通用户无异，投递目标就是某个 userID（通常先加为好友）。
abstract class WorkbenchHost {
  /// 当前选定的助手 OpenIM userID；未选则为空
  String get assistantUserId;

  /// 当前登录用户 OpenIM userID（本地分库）；未登录为空
  String get currentUserId;

  /// 从好友中选择/更换助手，成功返回 userID
  Future<String?> pickAssistantUser();

  /// 发送前准备目标：未选则选好友；已选则弹窗确认（可更换）。取消返回 null
  Future<String?> prepareAssistantForSend();

  /// 打开与助手的单聊并进入聊天页（P0：发送前调用）
  /// 若尚未选择助手，会先引导选择
  Future<void> openAgentChat();

  /// 向当前助手会话发送文本
  Future<void> sendTextToAgent(String text);

  /// 向当前助手会话发送本地文件（长录音 contentType=105）
  Future<void> sendFileToAgent({
    required String filePath,
    required String fileName,
  });
}
