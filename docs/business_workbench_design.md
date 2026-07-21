# 业务工作台（business_workbench）详细设计

> 状态：设计稿（待评审实施）  
> 范围：[DrClawApp](../) — 主工程仅挂载 Tab；**业务实现独立本地包 `business_workbench`**  
> 关联：查房「床旁录音 → 发给 Agent → Business 暂存 → HIS 回填」闭环；Business 患者字段对齐 `PatientDTO`

---

## 1. 背景与目标

### 1.1 业务场景

1. **病房（床旁）**：医生在 App **业务工作台**选择患者 → 长录音 → 多位患者录完后，**单条**将录音发给 Agent；Agent 生成查房文书，审核提交后写入 Business。  
2. **值班室（HIS）**：电子病历「获取查房记录」拉取 Business 文书并回填（本设计不改 HIS / Business API）。

### 1.2 产品与架构原则

| 原则 | 说明 |
|------|------|
| 基础 Tab 冻结 | 「会话 / 通讯录 / 我的」为 IM 基础能力，**不扩展医疗业务** |
| **业务工作台主入口** | 底部 **业务工作台** Tab；独立包 `business_workbench`，作为与 **DrClawBusiness** 交互的业务能力主入口与扩展点 |
| **业务包解耦** | 患者、录音及后续 Business 相关能力均在 path 包内；主工程只做壳 + Host（IM / 后续 Business API）适配 |
| MVP 发送 | 支持**批量录音（本地多条）**；发给 Agent **仅单条发送** |

### 1.3 本期目标（MVP）

- [ ] 新建本地包 `business_workbench`，主工程 `pubspec` path 依赖  
- [ ] 底部增加「业务工作台」Tab；壳在主工程，页面来自业务包  
- [ ] 通过 Host 接口注入 IM 发送能力（主工程实现，业务包不直接依赖 ChatLogic）  
- [ ] 患者本地 CRUD（字段对齐 Business）  
- [ ] 选患者长录音 → 本地录音列表  
- [ ] 录音详情 →「发给助手」单条发送（患者上下文 + 音频）  

### 1.4 非目标（本期不做）

- 多选批量发送给 Agent  
- App 直连 Business 同步患者/文书（可二期）  
- Agent 查房 Skill / MCP 落库（Agent 仓另立任务）  
- HIS 回填 UI  
- 改会话 / 通讯录 / 我的既有业务逻辑  
- 业务包反向依赖主工程 `lib/`（禁止）  

---

## 2. 包拆分与依赖边界

### 2.1 为什么拆包

- 本模块定位为 **与 DrClawBusiness 对齐的业务域**（患者、文书上下文、后续同步/拉取），会持续增长；不宜堆在 IM 的 `lib/pages/`。  
- 命名 `business_workbench` 明确边界：IM 壳 vs Business 业务工作台。  
- 对齐现有 path 包模式：`openim_common`、`openim_live`。  
- 主工程保持「IM 壳 + Host 装配」；业务包可独立演进与测试。

### 2.2 与 Business / Agent 的关系

| 方向 | MVP | 后续 |
|------|-----|------|
| App → Agent（OpenIM） | 单条录音 + 患者上下文（经 Host 发 IM） | custom 消息等 |
| App → Business | 本地患者字段对齐 `PatientDTO`；不直连 | 患者同步、文书状态查询等 API（经 Host 或包内 API client） |
| HIS → Business | 已有拉取文书 API（本包不实现） | — |

Host 可拆为两类能力（实施时可一个类实现）：

- `WorkbenchImHost`：开聊、发文本/语音（对接 OpenIM）  
- `WorkbenchBusinessHost`（P2+）：Business baseUrl、鉴权、患者/文书 API  

MVP 仅实现 IM 侧 Host 即可。

### 2.3 包拓扑

```
drclaw (主工程 lib/)
  ├── 依赖 openim_common / openim_live / business_workbench
  ├── Home Tab：嵌入 WorkbenchPage（来自业务包）
  └── 实现 WorkbenchHost（IM 跳转、发文本/语音、botUserId）

business_workbench/          ← 新建 path 包
  ├── 依赖：flutter、get、hive、record、path_provider…
  ├── 可选依赖：openim_common（仅 Styles / TitleBar / 通用组件）
  ├── 禁止依赖：主工程 lib/、openim_live（无必要）
  └── 通过抽象 Host 访问 IM，推荐不直接依赖 flutter_openim_sdk

openim_common/
  └── 不依赖 business_workbench（单向：业务 → 公共，不可反向）
```

依赖方向（允许）：

```
主工程 → business_workbench → openim_common
主工程 → openim_common
主工程 → openim_live → openim_common
```

禁止：

```
business_workbench → 主工程 lib/
openim_common → business_workbench
```

### 2.4 Host 适配（反转依赖）

业务包定义接口，主工程在启动/登录后注入实现。

```dart
/// 位于 business_workbench，业务侧只依赖此抽象
abstract class WorkbenchHost {
  /// Agent 机器人 OpenIM userID
  String get agentBotUserId;

  /// 打开与助手的单聊（无会话则创建）
  Future<void> openAgentChat();

  /// 向当前助手会话发送文本
  Future<void> sendTextToAgent(String text);

  /// 向当前助手会话发送本地语音文件
  Future<void> sendSoundToAgent({
    required String filePath,
    required int durationSec,
  });
}
```

主工程实现示例职责：

| 方法 | 主工程怎么做 |
|------|----------------|
| `agentBotUserId` | 读 `EnvConfig` / `DataSp` / dart-define |
| `openAgentChat` | `ConversationLogic.toChat(userID: …)` |
| `sendTextToAgent` | OpenIM `createTextMessage` + send（薄封装，不拉整页 ChatLogic） |
| `sendSoundToAgent` | `createSoundMessageFromFullPath` + send |

装配：

```dart
// 主工程 HomeBinding / 登录后
Get.put<WorkbenchHost>(AppBusinessWorkbenchHost(), permanent: true);
// 或 WorkbenchModule.init(host: AppBusinessWorkbenchHost());
```

业务包内「发给助手」只调用 `Get.find<WorkbenchHost>()`（或构造注入），**零引用** `chat_logic.dart`。

### 2.5 路由归属

| 层级 | 归属 |
|------|------|
| Tab 根嵌入 | 主工程 `home_view` 增加 Tab，`screen: WorkbenchPage()`（export 自业务包） |
| `/workbench/...` 子路由 | **业务包**提供 `WorkbenchPages.routes`；主工程 `AppPages.routes` **展开合并** |
| 导航 API | 业务包内 `WorkbenchNavigator`；主工程无需为每个子页写死跳转 |

### 2.6 资源与多语言

| 项 | 建议 |
|----|------|
| 业务文案 | 业务包自有文案模块；主工程 `Get.addTranslations` 合并（若需要） |
| 主工程仅改 | `StrRes.workbench` →「业务工作台」；英文 `Business Workbench`；Tab 图标仍用 `homeTab3*` |
| 业务图标 | 包内 `assets/`，在包 `pubspec` 声明 |

### 2.7 包目录（实施骨架）

```
DrClawApp/
├── lib/                          # IM 壳：home 挂 Tab + AppBusinessWorkbenchHost
├── openim_common/
├── openim_live/
├── business_workbench/           # 新建
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── business_workbench.dart         # export 入口
│   │   ├── host/workbench_host.dart        # 抽象 Host（IM；P2+ 可扩 Business）
│   │   ├── workbench_module.dart           # init / routes
│   │   ├── pages/
│   │   │   ├── shell/                      # Tab 根：入口列表
│   │   │   ├── patients/
│   │   │   └── recordings/
│   │   ├── models/
│   │   ├── store/
│   │   ├── services/                       # 录音器等（不含 IM SDK）
│   │   └── l10n/
│   └── test/
└── docs/business_workbench_design.md
```

主工程 `pubspec.yaml`：

```yaml
dependencies:
  business_workbench:
    path: business_workbench
```

---

## 3. 信息架构与导航

### 3.1 底部 Tab 调整

当前（3 Tab）：

```
[会话 Dr.Claw]  [通讯录]  [我的]
```

目标（4 Tab）：

```
[会话]  [通讯录]  [业务工作台]  [我的]
```

| 顺序 | Tab | 页面 | 职责 | 代码位置 |
|------|-----|------|------|----------|
| 0 | 会话 | `ConversationPage` | IM 会话（不变） | 主工程 |
| 1 | 通讯录 | `ContactsPage` | 好友/群（不变） | 主工程 |
| 2 | **业务工作台** | `WorkbenchPage` | 业务入口 | **业务包** |
| 3 | 我的 | `MinePage` | 账号（不变） | 主工程 |

主工程改动面尽量小：

- `home_view.dart`：插入 Tab，`import 'package:business_workbench/business_workbench.dart'`  
- `HomeBinding`：调用 `WorkbenchModule.ensureRegistered()`（如需要）  
- 文案：`workbench` →「业务工作台」/ `Business Workbench`  

### 3.2 工作台内导航

```
WorkbenchPage（入口宫格/列表）          ← business_workbench
  ├─ PatientListPage
  │    ├─ PatientEditPage
  │    └─ PatientDetailPage
  ├─ RecordingListPage
  │    └─ RecordingDetailPage          ←「发给助手」→ WorkbenchHost
  └─ RecordingSessionPage
```

### 3.3 入口注册表（扩展点）

仍在业务包内维护；新增业务能力 = 包内加入口 + 页面，主工程 Tab 无需改。

```dart
class WorkbenchEntry {
  final String id;
  final String title;
  final String? iconAsset;
  final String routeName;
  final bool enabled;
}
```

| 入口 id | 标题 | MVP |
|---------|------|-----|
| `patients` | 患者管理 | ✓ |
| `ward_recordings` | 查房录音 | ✓ |
| （预留） | 文书草稿箱、待办等 | ✗ |

---

## 4. 端到端流程（MVP）

```
┌────────────── 病房 · 业务工作台（business_workbench）────┐
│ 1. 患者管理：本地维护                                │
│ 2. 选患者 → 长录音 → 本地保存                        │
│ 3. 单条「发给助手」→ WorkbenchHost（主工程 IM）        │
└─────────────────────┬──────────────────────────────┘
                      │ OpenIM
┌─────────────────────▼──────────────────────────────┐
│ Agent →（后续）Business → HIS 回填                    │
└────────────────────────────────────────────────────┘
```

---

## 5. 数据模型

本地为主；字段命名与 Business `PatientDTO` 对齐。模型与 Hive **全部在业务包内**。

### 5.1 患者 `LocalPatient`

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `localId` | string (uuid) | ✓ | 本地主键 |
| `patientId` | string | 建议 | 院内患者 ID |
| `eventNo` | string | 建议 | 就诊号；与 patientId 至少一个有值 |
| `patientName` | string | ✓ | 姓名 |
| `idCard` | string | | |
| `gender` | int/enum | | 对齐 Business Gender |
| `age` | int | | |
| `department` | string | | |
| `bedNumber` | string | | 列表主展示 |
| `remark` | string | | |
| `createdAt` / `updatedAt` | int (ms) | ✓ | |
| `deleted` | bool | ✓ | 软删 |

### 5.2 录音 `LocalRecording`

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `localId` | string (uuid) | ✓ | |
| `patientLocalId` | string | ✓ | |
| `filePath` | string | ✓ | |
| `durationSec` | int | ✓ | |
| `fileSize` | int | | |
| `mime` / `ext` | string | | 默认 `.m4a` |
| `status` | enum | ✓ | `local` / `sending` / `sent` / `failed` |
| `sentAt` | int? | | |
| `openimClientMsgId` | string? | | Host 发送成功后回写 |
| `createdAt` / `updatedAt` | int | ✓ | |
| `deleted` | bool | ✓ | |

发送时按 `patientLocalId` 读患者；患者已删则拦截。

### 5.3 存储

| 项 | 设计 |
|----|------|
| 引擎 | 业务包内 Hive：`wb_patients` / `wb_recordings` |
| 初始化 | `WorkbenchModule.init()` 打开 box（主工程 `Config.init` 之后调用一次） |
| 文件目录 | `Documents/workbench/voice/{patientLocalId}/{recordingLocalId}.m4a` |

与聊天 `Documents/voice/` 隔离。

---

## 6. 功能设计

### 6.1 患者管理

| 功能 | 说明 |
|------|------|
| 列表 | 床号/时间排序；搜索；软删 |
| 新建/编辑 | `patientName` 必填；`patientId` 与 `eventNo` 至少一个 |
| 详情 | 「开始录音」+ 「该患者录音」 |
| 删除 | **级联软删录音**并删文件（推荐） |

### 6.2 长录音

| 项 | 设计 |
|----|------|
| 页面 | `RecordingSessionPage`（业务包） |
| 时长 | 上限 **30 分钟**（常量可配）；到时分段保存并可续录 |
| 引擎 | 业务包 `WorkbenchVoiceRecorder`（`package:record`）；**不改**聊天 `VoiceRecord` 60s 行为 |
| 权限 | 麦克风；MVP 仅前台录制 |

### 6.3 单条发送

1. 校验文件 / 患者 / 时长  
2. `host.openAgentChat()`  
3. `host.sendTextToAgent(模板文本)`  
4. `host.sendSoundToAgent(...)`  
5. 更新本地 `status`  

不做：多选批量、custom 110（二期）。

### 6.4 聊天内选患者（概要）

与相册/文件同级：对话框工具箱增加「患者」入口，复用业务包患者数据。详见 **§7**。  
**分期：P1**（P0 先完成工作台患者库与录音；聊天入口依赖同一套本地患者数据）。

---

## 7. 聊天工具箱：选择患者（详细设计）

### 7.1 目标与场景

医生在与 Agent（或同事）的**对话页**中，像选图片、选文件一样，从工具箱点「患者」，选出床旁已维护的患者，把患者上下文带进当前会话，再继续文字/语音交互。

| 场景 | 行为 |
|------|------|
| A. 仅声明当前患者 | 选患者 → 直接发出「患者上下文」文本 |
| B. 选患者后短语音 | 选患者 → 发出上下文文本 → 用户用聊天按住说话（≤60s） |
| C. 选患者后长录音 | 选患者 → 跳转业务包长录音页（绑该患者）→ 结束后走录音列表或回聊天 |

P1 优先落地 **场景 A**；B 自然可用；C 复用已有长录音页。

### 7.2 与现有「选图 / 选文件」对齐

| 能力 | 相册 | 文件 | **患者（新增）** |
|------|------|------|----------------|
| 入口 | `ChatToolBox.onTapAlbum` | `onTapFile` | `onTapPatient` |
| 权限 | 相册 | 存储/SAF | 无系统权限（读本地 Hive） |
| 选择 UI | 系统/微信选择器 | FilePicker | **业务包** `PatientPicker`（半屏/全屏） |
| 结果 | 图片路径 | 文件路径 | `LocalPatient` |
| 发送 | `createImageMessage…` | `createFileMessage…` | **文本模板**（P1）；可选 custom 110（P2） |
| 数据归属 | 系统媒体 | 用户文件 | `business_workbench` 患者库 |

**依赖方向不变**：主工程聊天只调用业务包公开 API，不把患者 CRUD 写进 `ChatLogic`。

```
ChatPage / ChatLogic（主工程）
  └─ onTapPatient()
       └─ showPatientPicker(context)   // business_workbench 导出
            └─ Future<LocalPatient?>
                 └─ 发送【当前患者】文本（见 §7.5）
```

### 7.3 业务包对外 API（供聊天调用）

```dart
/// 展示患者选择器；取消返回 null
Future<LocalPatient?> showPatientPicker(
  BuildContext context, {
  String? title,           // 默认「选择患者」
  bool allowCreate = true, // 空列表时可跳转新建
});

/// 将患者格式化为对话上下文
String formatPatientContext(LocalPatient p);

/// 可选：会话级当前患者（角标用，§7.6）
abstract class ChatPatientContext {
  LocalPatient? get current;
  void set(LocalPatient? p);
  void clear();
}
```

选择器 UI（列表、搜索、空态）全部在包内；主工程不复制列表实现。

### 7.4 主工程改动点

| 位置 | 改动 |
|------|------|
| `ChatToolBox` | 增加可选 `onTapPatient`；回调非空才展示「患者」格子 |
| 文案 / 图标 | `toolboxPatient`（「患者」）；图标可复用联系人或业务包 asset |
| `chat_view.dart` | 传入 `onTapPatient: logic.onTapPatient` |
| `chat_logic.dart` | `onTapPatient` → `showPatientPicker` → 按策略发送 |
| **不改** | 相册 / 文件原有逻辑 |

**显示策略（推荐）**：仅当 `conversation.userID == agentBotUserId` 时传入 `onTapPatient`（只在与助手对话显示）。群聊默认不显示。`agentBotUserId` 与 Host 同源配置。

### 7.5 选中后的发送策略（P1）

**默认：直接发送上下文消息**（关闭工具箱），模板：

```text
【当前患者】
患者姓名：{patientName}
床号：{bedNumber}
患者ID：{patientId}
就诊号：{eventNo}
科室：{department}
```

与查房录音模板字段一致，仅标题为「当前患者」，便于 Agent 区分「指定患者」与「带录音查房」。

备选：写入输入框再手发——易被误改，不推荐作为默认。

与后续语音：医生发完【当前患者】后再发语音/文字；Agent 同会话内关联最近一条患者卡（Skill 另仓约定）。P1 App **不强制**写语音 `ex`；P2 可强化。

### 7.6 会话级「当前患者」角标（P1 可选）

聊天顶栏或输入区显示「当前：12床 张三」：

- 选患者时 `ChatPatientContext.set`，并仍发【当前患者】（或配置为仅 set 不发）  
- 换患者时更新角标并再发一条  
- 离开会话或清除时 `clear()`  

最小 P1 可不做角标，只做工具箱发送。

### 7.7 空患者库

| 情况 | 处理 |
|------|------|
| 无患者 | 空态：「去业务工作台添加」→ 跳转患者新建/列表 |
| 已软删 | 选择器不展示 |
| 包未 init | toast「业务模块未就绪」 |

### 7.8 与工作台录音入口对照

| 入口 | 路径 |
|------|------|
| 业务工作台 | 患者详情 → 长录音 → 列表 → 发给助手 |
| 聊天工具箱 | 选患者 →【当前患者】→（可选）短语音 / 跳转长录音 |

共用 `LocalPatient`、Hive、字段格式化；入口职责不同，不互相替代。

### 7.9 交互线框

```
┌──────── 聊天页（与 Agent）─────────┐
│ … 历史消息 …                         │
│ [输入框]                         [+] │
└─────────────────────────────────────┘
              │ 工具箱
              ▼
     ┌ 相册 | 文件 | 患者 ┐
              │
              ▼
┌──── 选择患者 ─────────────┐
│ 🔍 床号 / 姓名              │
│ 12床 张三                   │
│ 08床 李四                   │
│ [新建患者]                  │
└─────────────────────────────┘
              │
              ▼
会话出现：【当前患者】…
```

### 7.10 验收（P1 · 聊天选患者）

- [ ] 与 Agent 会话工具箱可见「患者」；选择器来自业务包  
- [ ] 选中后发出【当前患者】文本，字段完整  
- [ ] 可搜索；无数据时可去新建  
- [ ] 业务包不 import `lib/pages/chat/**`  
- [ ] 相册/文件无回归  

### 7.11 非目标（本节）

- 聊天内多选患者一次发送  
- custom 110 患者卡片气泡（P2）  
- 群聊 @患者（患者不是 IM 用户）  

---

## 8. 与 Agent / OpenIM 对接

### 8.1 机器人账号

配置落在**主工程**（Host 读取）；业务包只读 `host.agentBotUserId`。

### 8.2 文本模板汇总

| 前缀 | 来源 | 用途 |
|------|------|------|
| `【查房录音】` | 工作台单条发送录音前 | 患者 + 录音元数据，随后语音 |
| `【当前患者】` | 聊天工具箱选患者 | 声明后续对话所属患者 |

字段对齐 Business：`patientName` / `bedNumber` / `patientId` / `eventNo` / `department`。

查房录音模板：

```text
【查房录音】
患者姓名：{patientName}
床号：{bedNumber}
患者ID：{patientId}
就诊号：{eventNo}
科室：{department}
本地录音ID：{recordingLocalId}
时长：{durationSec}秒
```

随后 Host 发送 `contentType=103` 语音。

### 8.3 二期

custom `110`（`ward_round_voice` / `current_patient`）；批量发送；Business 同步；语音 `ex` 写入 patientId。

---

## 9. 主工程改动清单（最小化）

| 文件/项 | 改动 | 阶段 |
|---------|------|------|
| `pubspec.yaml` | path 依赖 `business_workbench` | P0 |
| `home_view.dart` | 插入业务工作台 Tab | P0 |
| `home_binding` / 启动 | `WorkbenchModule.init` + Host | P0 |
| `app_pages.dart` | 合并 `WorkbenchPages.routes` | P0 |
| `EnvConfig` / `DataSp` | `agentBotUserId` | P0 |
| `app_business_workbench_host.dart` | Host（IM 发送） | P0 |
| `workbench` 文案 | 「业务工作台」 | P0 |
| `ChatToolBox` + `chat_view` / `chat_logic` | `onTapPatient` + `showPatientPicker` | **P1** |
| `toolboxPatient` 文案 | 「患者」 | **P1** |

**不改**：`conversation_*`、`contacts_*`、`mine_*`；相册/文件原路径。

---

## 10. 分期

| 阶段 | 内容 |
|------|------|
| **P0** | 建包 + Tab + Host；患者 CRUD；长录音；工作台单条发给助手 |
| **P1** | **聊天工具箱选患者**（§7）；发送重试；botId 配置；可选当前患者角标 |
| **P2** | custom 110；批量发送；Business 同步；语音绑定 patientId |
| **P3** | 业务包更多入口（文书状态、待办等） |

---

## 11. 风险与对策

| 风险 | 对策 |
|------|------|
| 业务包误依赖 ChatLogic | 禁止依赖主工程；聊天只调包 API |
| Host 与聊天气泡不一致 | 共用底层发消息 |
| 患者卡 + 语音被 Agent 拆轮 | Agent 约定关联最近【当前患者】/【查房录音】 |
| 工具箱对所有会话显示 | 默认仅 Agent 会话显示 |
| 长录音上传失败 | 限时长/码率；可重试 |
| openim_common 过重 | 业务包按需依赖 Styles |

---

## 12. 验收标准

### P0（业务工作台）

- [ ] 存在独立包 `business_workbench`，主工程仅 path 依赖与 Host  
- [ ] 业务包无 `import` 主工程 `lib/pages/**`  
- [ ] 4 Tab：会话 / 通讯录 / 业务工作台 / 我的；前三无回归  
- [ ] 患者 CRUD、长录音（>60s）、列表播放删除  
- [ ] 单条「发给助手」可见患者文本 + 语音  
- [ ] 无多选批量发送  

### P1（聊天选患者）

见 **§7.10**。

---

## 13. 相关文档

- [architecture.md](./architecture.md)  
- [message_types_alignment.md](./message_types_alignment.md)  
- Agent：[DRCLAW_OPENIM_CHANNEL_zh.md](../../DrClawAgent/docs/DRCLAW_OPENIM_CHANNEL_zh.md)  
- Business：[病历文书接口文档.md](../../DrClawBusiness/docs/病历文书接口文档.md)  

---

## 14. 修订记录

| 日期 | 说明 |
|------|------|
| 2026-07-21 | 初稿：工作台 Tab、患者与长录音、单条发送 MVP |
| 2026-07-21 | 增补：独立包、Host 反转依赖、主工程最小化挂载 |
| 2026-07-21 | 定名 `business_workbench` /「业务工作台」；定位为与 DrClawBusiness 交互的业务入口 |
| 2026-07-21 | 增补 §7：聊天工具箱选患者（对齐相册/文件）；【当前患者】模板；P1 分期与验收 |
