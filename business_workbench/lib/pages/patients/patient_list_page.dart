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
        right: WbTextAction(label: '新建', onTap: logic.toCreate),
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
                return WbEmptyView(
                  icon: Icons.person_outline,
                  text: searching ? '未找到匹配患者' : '暂无患者',
                  hint: searching ? '试试其他关键词' : '添加患者后即可录音并发送',
                  actionLabel: searching ? null : '新建患者',
                  onAction: searching ? null : logic.toCreate,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WbListHeader(text: '共 ${logic.patients.length} 位患者'),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 2, bottom: 24),
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
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
