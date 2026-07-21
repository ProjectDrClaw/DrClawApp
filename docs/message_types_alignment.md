# DrClawApp 与 Agent 消息类型对齐计划

> 状态：**已实施**（代码已合入 App，待联调验收）  
> 范围：仅 [DrClawApp](../)，不改 DrClawAgent / OpenIM Server  
> 目标：App 侧 OpenIM 消息能力与 Agent 频道对齐（文本 / 图片 / 语音 / 视频 / 文件 / @文本）

---

## 1. 能力对照（实施后）

| contentType | 类型 | Agent | App 收 | App 发 |
|-------------|------|-------|--------|--------|
| 101 | 文本 | 收发 | ✓ Markdown | ✓ |
| 102 | 图片 | 收发 | ✓ | ✓ 相册 |
| 103 | 语音 | 收发 | ✓ 播放 | ✓ 按住说话 |
| 104 | 视频 | 收发 | ✓ 封面预览 | ✓ 相册 |
| 105 | 文件 | 收发 | ✓ | ✓ 工具箱 |
| 106 | @文本 | 入站 | ✓ | ✓ 群聊输入 `@` |

---

## 2. 已落地改动

### 展示

- `parseMsg`：补 `[语音]` / `[视频]` / `[文件]`
- 新建 `ChatVoiceView` / `ChatVideoView` / `ChatFileView`
- `chat_item_view` 增加 voice / video / file 分支

### 发送

- 相册视频 → `createVideoMessageFromFullPath`
- 工具箱文件 → `FilePicker` + `createFileMessageFromFullPath`
- `ChatVoiceRecordBar` + 输入框语音切换 → `createSoundMessageFromFullPath`
- 群聊 `@` 选人 → `createTextAtMessage`；`getAtMapping` 已接通

### 关键文件

- `openim_common/lib/src/widgets/chat/chat_voice_view.dart`
- `openim_common/lib/src/widgets/chat/chat_video_view.dart`
- `openim_common/lib/src/widgets/chat/chat_file_view.dart`
- `openim_common/lib/src/widgets/chat/chat_voice_record_bar.dart`
- `openim_common/lib/src/widgets/chat/chat_input_box.dart`
- `openim_common/lib/src/widgets/chat/chat_item_view.dart`
- `openim_common/lib/src/widgets/chat/chat_toolbox.dart`
- `openim_common/lib/src/utils/utils.dart`
- `lib/pages/chat/chat_logic.dart`
- `lib/pages/chat/chat_view.dart`

---

## 3. 验收清单

- [ ] 单聊/群聊：发文本、图片、语音、视频、文件，Agent 可入站并回复
- [ ] Agent 回媒体：App 可预览/播放，不再「暂不支持」
- [ ] 群聊 `@机器人`：发出 `atText(106)`，Agent `require_mention` 可识别
- [ ] 会话摘要显示 `[语音]` / `[视频]` / `[文件]`
- [x] `flutter analyze` 相关改动无 error

---

## 4. 非目标

- 流式打字机、交互卡片、引用消息
- 改 DrClawAgent / OpenIM Server
- 相机直拍视频
- 出站 @ 气泡高亮美化
