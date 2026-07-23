import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../services/patient_display.dart';
import '../../theme/wb_theme.dart';
import '../../widgets/patient_list_tile.dart';
import '../../widgets/wb_layout.dart';
import 'patient_list_logic.dart';

class PatientListPage extends StatelessWidget {
  const PatientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<PatientListLogic>();
    return Scaffold(
      appBar: TitleBar.back(
        title: '患者',
        right: WbTextAction(label: '添加', onTap: logic.toCreate),
      ),
      backgroundColor: WbTheme.background,
      body: Column(
        children: [
          WbSearchBar(
            hintText: '搜索姓名、就诊号、床号…',
            onChanged: logic.onSearch,
            onSubmitted: logic.onSearch,
          ),
          Expanded(
            child: Obx(() {
              if (logic.patients.isEmpty) {
                final searching = logic.keyword.value.trim().isNotEmpty;
                return RefreshIndicator(
                  onRefresh: () => logic.refreshFromServer(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: searching
                            ? const WbEmptyView(
                                icon: Icons.person_outline,
                                text: '未找到匹配患者',
                                hint: '试试其他关键词',
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const WbEmptyView(
                                    icon: Icons.person_outline,
                                    text: '暂无患者',
                                    hint: '从院内检索添加，或手动填写',
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 44,
                                          child: ElevatedButton(
                                            onPressed: logic.toPlatformSearch,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: WbTheme.primary,
                                            ),
                                            child: const Text(
                                              '从院内检索',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: logic.toManualCreate,
                                          child: Text(
                                            '手动填写',
                                            style: TextStyle(
                                              color: WbTheme.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WbListHeader(
                    text: logic.syncing.value
                        ? '同步中… 共 ${logic.patients.length} 位'
                        : '共 ${logic.patients.length} 位患者',
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => logic.refreshFromServer(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 2, bottom: 24),
                        itemCount: logic.patients.length,
                        itemBuilder: (_, i) {
                          final p = logic.patients[i];
                          return PatientListTile(
                            patient: p,
                            onTap: () => logic.toDetail(p),
                            onLongPress: () async {
                              final ok = await Get.dialog<bool>(
                                CustomDialog(
                                  title: PatientDisplay.deletePatientConfirm,
                                ),
                              );
                              if (ok == true) await logic.deletePatient(p);
                            },
                          );
                        },
                      ),
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
