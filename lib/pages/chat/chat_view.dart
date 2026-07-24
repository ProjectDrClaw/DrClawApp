import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  final logic = Get.find<ChatLogic>(tag: GetTags.chat);

  ChatPage({super.key});

  Widget _buildItemView(Message message) => ChatItemView(
        key: logic.itemKey(message),
        message: message,
        textScaleFactor: logic.scaleFactor.value,
        allAtMap: logic.getAtMapping(message),
        timelineStr: logic.getShowTime(message),
        sendStatusSubject: logic.sendStatusSub,
        leftNickname: logic.getNewestNickname(message),
        leftFaceUrl: logic.getNewestFaceURL(message),
        rightNickname: logic.senderName,
        rightFaceUrl: OpenIM.iMManager.userInfo.faceURL,
        showLeftNickname: !logic.isSingleChat,
        showRightNickname: !logic.isSingleChat,
        onFailedToResend: () => logic.failedResend(message),
        onClickItemView: () => logic.parseClickEvent(message),
        onLongPress: () => logic.onLongPressMessage(message),
        visibilityChange: (msg, visible) {
          logic.markMessageAsRead(message, visible);
        },
        onLongPressRightAvatar: () {},
        onTapLeftAvatar: () {
          logic.onTapLeftAvatar(message);
        },
        onVisibleTrulyText: (text) {
          logic.copyTextMap[message.clientMsgID] = text;
        },
        customTypeBuilder: _buildCustomTypeItemView,
        patterns: <MatchPattern>[
          MatchPattern(
            type: PatternType.email,
            onTap: logic.clickLinkText,
          ),
          MatchPattern(
            type: PatternType.url,
            onTap: logic.clickLinkText,
          ),
          MatchPattern(
            type: PatternType.mobile,
            onTap: logic.clickLinkText,
          ),
          MatchPattern(
            type: PatternType.tel,
            onTap: logic.clickLinkText,
          ),
        ],
        mediaItemBuilder: (context, message) {
          return _buildMediaItem(context, message);
        },
        onTapUserProfile: handleUserProfileTap,
      );

  void handleUserProfileTap(({String userID, String name, String? faceURL, String? groupID}) userProfile) {
    final userInfo = UserInfo(userID: userProfile.userID, nickname: userProfile.name, faceURL: userProfile.faceURL);
    logic.viewUserInfo(userInfo);
  }

  Widget? _buildMediaItem(BuildContext context, Message message) {
    if (message.contentType != MessageType.picture && message.contentType != MessageType.video) {
      return null;
    }

    return GestureDetector(
      onTap: () async {
        try {
          IMUtils.previewMediaFile(
              context: context,
              message: message,
              onAutoPlay: (index) {
                return !logic.playOnce;
              },
              muted: logic.rtcIsBusy,
              onPageChanged: (index) {
                logic.playOnce = true;
              }).then((value) {
            logic.playOnce = false;
          });
        } catch (e) {
          IMViews.showToast(e.toString());
        }
      },
      child: Hero(
        tag: message.clientMsgID!,
        child: _buildMediaContent(message),
        placeholderBuilder: (BuildContext context, Size heroSize, Widget child) => child,
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    final isOutgoing = message.sendID == OpenIM.iMManager.userID;

    if (message.isVideoType) {
      return ChatVideoView(
        isISend: isOutgoing,
        message: message,
      );
    }
    return ChatPictureView(
      isISend: isOutgoing,
      message: message,
    );
  }

  CustomTypeInfo? _buildCustomTypeItemView(_, Message message) {
    final data = IMUtils.parseCustomMessage(message);
    if (null != data) {
      final viewType = data['viewType'];
      if (viewType == CustomMessageType.call) {
        final type = data['type'];
        final content = data['content'];
        final view = ChatCallItemView(type: type, content: content);
        return CustomTypeInfo(view);
      } else if (viewType == CustomMessageType.deletedByFriend || viewType == CustomMessageType.blockedByFriend) {
        final view = ChatFriendRelationshipAbnormalHintView(
          name: logic.nickname.value,
          onTap: logic.sendFriendVerification,
          blockedByFriend: viewType == CustomMessageType.blockedByFriend,
          deletedByFriend: viewType == CustomMessageType.deletedByFriend,
        );
        return CustomTypeInfo(view, false, false);
      } else if (viewType == CustomMessageType.removedFromGroup) {
        return CustomTypeInfo(
          StrRes.removedFromGroupHint.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.groupDisbanded) {
        return CustomTypeInfo(
          StrRes.groupDisbanded.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.toolGuardApproval) {
        final status = '${data['status'] ?? 'pending'}';
        final toolParams = <String, dynamic>{};
        final rawParams = data['toolParams'];
        if (rawParams is Map) {
          rawParams.forEach((k, v) => toolParams['$k'] = v);
        }
        // 对话内展示完整卡片摘要；操作在弹窗中完成
        final view = ChatToolGuardApprovalView(
          toolName: '${data['toolName'] ?? 'tool'}',
          toolSource: '${data['toolSource'] ?? ''}',
          severity: '${data['severity'] ?? ''}',
          findingsCount: data['findingsCount'] is int
              ? data['findingsCount'] as int
              : int.tryParse('${data['findingsCount'] ?? 0}') ?? 0,
          summary: '${data['summary'] ?? ''}',
          toolParams: toolParams,
          createdAt: data['createdAt'] is num
              ? (data['createdAt'] as num).toDouble()
              : double.tryParse('${data['createdAt'] ?? 0}') ?? 0,
          timeoutSeconds: data['timeoutSeconds'] is num
              ? (data['timeoutSeconds'] as num).toDouble()
              : double.tryParse('${data['timeoutSeconds'] ?? 300}') ?? 300,
          isGeneralized: data['isGeneralized'] == true,
          exactTarget: '${data['exactTarget'] ?? ''}',
          similarTarget: '${data['similarTarget'] ?? ''}',
          status: status,
        );
        return CustomTypeInfo(view, false);
      } else if (viewType == CustomMessageType.toolCall ||
          viewType == CustomMessageType.toolResult ||
          viewType == CustomMessageType.thinking) {
        final view = ChatAgentRuntimeView(
          kind: '${data['kind'] ?? ''}',
          toolName: '${data['toolName'] ?? ''}',
          body: '${data['body'] ?? ''}',
          text: '${data['text'] ?? ''}',
        );
        return CustomTypeInfo(view, false);
      }
    }
    return null;
  }

  Widget? get _groupCallHintView => null;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: logic.willPop(),
      child: Obx(() {
        return Scaffold(
            backgroundColor: Styles.c_F0F2F6,
            appBar: TitleBar.chat(
              title: logic.nickname.value,
              member: logic.memberStr,
              onCloseMultiModel: logic.exit,
              onClickMoreBtn: logic.chatSetup,
              // LiveKit 未部署前关闭音视频入口
              showCallBtn: false,
            ),
            body: SafeArea(
              child: WaterMarkBgView(
                text: '',
                path: logic.background.value,
                backgroundColor: Styles.c_FFFFFF,
                floatView: _groupCallHintView,
                bottomView: ChatInputBox(
                  forceCloseToolboxSub: logic.forceCloseToolbox,
                  controller: logic.inputCtrl,
                  focusNode: logic.focusNode,
                  isNotInGroup: logic.isInvalidGroup,
                  directionalText: logic.directionalText(),
                  onCloseDirectional: logic.onClearDirectional,
                  onSend: (v) => logic.sendTextMsg(),
                  toolbox: ChatToolBox(
                    onTapAlbum: logic.onTapAlbum,
                    onTapFile: logic.onTapFile,
                    onTapPatient:
                        logic.showPatientToolbox ? logic.onTapPatient : null,
                    onTapWardRecording: logic.showPatientToolbox
                        ? logic.onTapWardRecording
                        : null,
                    // LiveKit 未部署前关闭音视频入口
                    onTapCall: null,
                  ),
                  voiceRecordBar: ChatVoiceRecordBar(
                    onCompleted: (duration, path) {
                      logic.sendSound(path: path, duration: duration);
                    },
                  ),
                ),
                child: ChatListView(
                  onTouch: () => logic.closeToolbox(),
                  itemCount: logic.messageList.length,
                  controller: logic.scrollController,
                  onScrollToBottomLoad: logic.onScrollToBottomLoad,
                  onScrollToTop: logic.onScrollToTop,
                  itemBuilder: (_, index) {
                    final message = logic.indexOfMessage(index);
                    return Obx(() => _buildItemView(message));
                  },
                ),
              ),
            ));
      }),
    );
  }
}
