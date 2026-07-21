import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../theme/wb_theme.dart';
import '../../widgets/recording_list_tile.dart';
import '../../widgets/wb_layout.dart';
import '../../workbench_routes.dart';
import 'recording_list_logic.dart';

class RecordingListPage extends StatelessWidget {
  const RecordingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<RecordingListLogic>();
    return Scaffold(
      appBar: TitleBar.back(title: '录音'),
      backgroundColor: WbTheme.background,
      body: Column(
        children: [
          WbSearchBar(
            hintText: '搜索标题、患者姓名、就诊号…',
            onChanged: logic.onSearch,
            onSubmitted: logic.onSearch,
          ),
          Expanded(
            child: Obx(() {
              if (logic.items.isEmpty) {
                final searching = logic.keyword.value.trim().isNotEmpty;
                return WbEmptyView(
                  icon: Icons.mic_none_outlined,
                  text: searching ? '未找到匹配录音' : '暂无录音',
                  hint: searching
                      ? '试试其他关键词'
                      : '进入患者详情后即可开始录音',
                  actionLabel: searching ? null : '去患者列表',
                  onAction: searching
                      ? null
                      : () => Get.toNamed(WorkbenchRoutes.patients),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WbListHeader(text: '共 ${logic.items.length} 条录音'),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 2, bottom: 24),
                      itemCount: logic.items.length,
                      itemBuilder: (_, i) {
                        final item = logic.items[i];
                        return RecordingListTile(
                          recording: item.recording,
                          patient: item.patient,
                          cardStyle: true,
                          showChevron: true,
                          onTap: () => logic.openDetail(item.recording),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
