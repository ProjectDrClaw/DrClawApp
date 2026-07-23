import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:business_workbench/business_workbench.dart';

import '../../pages/chat/chat_logic.dart';
import '../../routes/app_navigator.dart';

/// 主工程 Host：对接 OpenIM 会话与发消息，以及 Business 工作集 API。
/// 助手即为普通用户，首次发送时从好友中选择并记住。
class AppBusinessWorkbenchHost implements WorkbenchHost, WorkbenchBusinessHost {
  @override
  String get assistantUserId =>
      DataSp.getWorkbenchAssistantUserId()?.trim() ?? '';

  @override
  String get currentUserId {
    try {
      return OpenIM.iMManager.userID;
    } catch (_) {
      return '';
    }
  }

  @override
  String get businessBaseUrl => Config.businessBaseUrl;

  @override
  String get businessAppId => Config.businessAppId;

  @override
  String get doctorUserId => currentUserId;

  BusinessDoctorPatientApi get _api => BusinessDoctorPatientApi(
        baseUrl: businessBaseUrl,
        appId: businessAppId,
        doctorUserId: doctorUserId,
      );

  @override
  Future<DoctorPatientPage> listMyPatients({
    int pageNum = 1,
    int pageSize = 100,
    String? keyword,
  }) {
    return _api.list(pageNum: pageNum, pageSize: pageSize, keyword: keyword);
  }

  @override
  Future<DoctorPatientDto> saveMyPatient(DoctorPatientSave input) {
    return _api.save(input);
  }

  @override
  Future<void> deleteMyPatient({required String id}) {
    return _api.delete(id: id);
  }

  @override
  Future<PlatformPatientPage> queryPlatformPatients({
    int pageNum = 1,
    int pageSize = 20,
    String? keyword,
    String? eventNo,
    String? patientId,
  }) {
    return _api.queryPlatform(
      pageNum: pageNum,
      pageSize: pageSize,
      keyword: keyword,
      eventNo: eventNo,
      patientId: patientId,
    );
  }

  @override
  Future<String?> pickAssistantUser() async {
    List<FriendInfo> friends = [];
    try {
      for (var offset = 0;;) {
        final page = await OpenIM.iMManager.friendshipManager.getFriendListPage(
          offset: offset,
          count: 1000,
          filterBlack: true,
        );
        friends.addAll(page);
        if (page.length < 1000) break;
        offset += page.length;
      }
    } catch (e) {
      IMViews.showToast('获取好友失败');
      return null;
    }
    if (friends.isEmpty) {
      IMViews.showToast('请先添加好友');
      return null;
    }

    final selected = await Get.bottomSheet<FriendInfo>(
      _AssistantPickerSheet(friends: friends),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    final uid = selected?.userID?.trim();
    if (uid == null || uid.isEmpty) return null;
    await DataSp.putWorkbenchAssistantUserId(uid);
    return uid;
  }

  Future<({String name, String? faceURL})> _assistantProfile(String userId) async {
    try {
      final list = await OpenIM.iMManager.userManager.getUsersInfo(
        userIDList: [userId],
      );
      if (list.isNotEmpty) {
        final u = list.first;
        final name = u.nickname?.trim();
        return (
          name: (name != null && name.isNotEmpty) ? name : '好友',
          faceURL: u.faceURL,
        );
      }
    } catch (_) {}
    return (name: '好友', faceURL: null);
  }

  @override
  Future<String?> prepareAssistantForSend() async {
    var id = assistantUserId;
    if (id.isEmpty) {
      // 首次：选好友即确认，不再二次弹窗
      return pickAssistantUser();
    }
    final profile = await _assistantProfile(id);
    final ok = await Get.dialog<bool>(
      _SendConfirmDialog(
        nickname: profile.name,
        faceURL: profile.faceURL,
      ),
      barrierColor: Colors.black.withOpacity(0.45),
    );
    if (ok == true) return id;
    if (ok == false) {
      // 更换发送对象
      return pickAssistantUser();
    }
    return null; // 关闭弹窗
  }

  Future<String> _ensureAssistantUserId() async {
    var id = assistantUserId;
    if (id.isEmpty) {
      id = (await pickAssistantUser())?.trim() ?? '';
    }
    if (id.isEmpty) {
      throw StateError('未选择发送对象');
    }
    return id;
  }

  @override
  Future<void> openAgentChat() async {
    final target = await _ensureAssistantUserId();
    final conv = await OpenIM.iMManager.conversationManager.getOneConversation(
      sourceID: target,
      sessionType: ConversationType.single,
    );
    // 不 await 路由 Future（否则会阻塞到离开聊天页）
    unawaited(
      AppNavigator.startChat(
        conversationInfo: conv,
        offUntilHome: true,
      ),
    );
    await _waitChatLogic();
  }

  Future<void> _waitChatLogic() async {
    for (var i = 0; i < 40; i++) {
      if (_chatLogic != null) return;
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  ChatLogic? get _chatLogic {
    final tag = GetTags.chat;
    if (tag == null) return null;
    if (!Get.isRegistered<ChatLogic>(tag: tag)) return null;
    return Get.find<ChatLogic>(tag: tag);
  }

  @override
  Future<void> sendTextToAgent(String text) async {
    final chat = _chatLogic;
    if (chat != null) {
      await chat.sendForwardRemarkMsg(text);
      return;
    }
    final target = await _ensureAssistantUserId();
    final message = await OpenIM.iMManager.messageManager.createTextMessage(
      text: text,
    );
    await OpenIM.iMManager.messageManager.sendMessage(
      message: message,
      userID: target,
      offlinePushInfo: Config.offlinePushInfo,
    );
  }

  @override
  Future<void> sendFileToAgent({
    required String filePath,
    required String fileName,
  }) async {
    final chat = _chatLogic;
    if (chat != null) {
      await chat.sendFile(path: filePath, fileName: fileName);
      return;
    }
    final target = await _ensureAssistantUserId();
    final message =
        await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(
      filePath: filePath,
      fileName: fileName,
    );
    await OpenIM.iMManager.messageManager.sendMessage(
      message: message,
      userID: target,
      offlinePushInfo: Config.offlinePushInfo,
    );
  }
}

/// 选择发送对象底部列表（只展示昵称）
class _AssistantPickerSheet extends StatelessWidget {
  const _AssistantPickerSheet({required this.friends});

  final List<FriendInfo> friends;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.7.sh),
      decoration: BoxDecoration(
        color: WbTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10.h),
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: WbTheme.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '选择发送对象',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: WbTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: WbTheme.textSecondary),
                ),
              ],
            ),
          ),
          Divider(height: 0.5, color: WbTheme.inputBackground),
          Expanded(
            child: ListView.separated(
              itemCount: friends.length,
              separatorBuilder: (_, __) => Container(
                height: 0.5,
                color: WbTheme.inputBackground,
                margin: EdgeInsets.only(left: 68.w),
              ),
              itemBuilder: (_, i) {
                final f = friends[i];
                final name = (f.nickname?.trim().isNotEmpty == true)
                    ? f.nickname!.trim()
                    : '未命名';
                return Material(
                  color: WbTheme.backgroundLight,
                  child: InkWell(
                    onTap: () => Get.back(result: f),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          AvatarView(
                            url: f.faceURL,
                            text: name,
                            width: 40.w,
                            height: 40.w,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: WbTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: WbTheme.textHint,
                            size: 20.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 确认发送弹窗：突出好友昵称
class _SendConfirmDialog extends StatelessWidget {
  const _SendConfirmDialog({
    required this.nickname,
    this.faceURL,
  });

  final String nickname;
  final String? faceURL;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 300.w,
          margin: EdgeInsets.symmetric(horizontal: 36.w),
          decoration: BoxDecoration(
            color: WbTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
                child: Column(
                  children: [
                    Text(
                      '确认发送给',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: WbTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: WbTheme.primaryAlpha20,
                          width: 2,
                        ),
                      ),
                      child: AvatarView(
                        url: faceURL,
                        text: nickname,
                        width: 56.w,
                        height: 56.w,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      nickname,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: WbTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Divider(height: 0.5, color: WbTheme.inputBackground),
              SizedBox(
                height: 52.h,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.back(result: false),
                        child: Center(
                          child: Text(
                            '更换',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: WbTheme.textRegular,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: 52.h,
                      color: WbTheme.inputBackground,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.back(result: true),
                        child: Center(
                          child: Text(
                            '发送',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: WbTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
