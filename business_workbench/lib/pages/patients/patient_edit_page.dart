import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../theme/wb_theme.dart';
import '../../widgets/wb_layout.dart';
import 'patient_edit_logic.dart';

/// 患者编辑页（对齐旧库 PatientForm：分组白卡片 + 上标签下输入）
class PatientEditPage extends StatelessWidget {
  const PatientEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<PatientEditLogic>();
    final isEdit = logic.editingLocalId != null;
    return Scaffold(
      appBar: TitleBar.back(
        title: isEdit ? '编辑患者' : '新建患者',
        right: GestureDetector(
          onTap: logic.save,
          child: Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Text(
              '保存',
              style: TextStyle(fontSize: 17.sp, color: WbTheme.primary),
            ),
          ),
        ),
      ),
      backgroundColor: WbTheme.background,
      body: ListView(
        padding: EdgeInsets.only(top: 8.h, bottom: 40.h),
        children: [
          WbGroupCard(
            marginTop: 0,
            child: Column(
              children: [
                _field('就诊号 *', logic.eventNoCtrl, hint: '请输入就诊号'),
                _field('患者ID *', logic.patientIdCtrl, hint: '请输入患者ID'),
                _field('姓名 *', logic.nameCtrl, hint: '请输入姓名'),
                _gender(logic),
                _field('年龄', logic.ageCtrl,
                    hint: '请输入年龄', keyboard: TextInputType.number),
                _field('身份证', logic.idCardCtrl, hint: '请输入身份证号'),
              ],
            ),
          ),
          WbGroupCard(
            child: Column(
              children: [
                _field('科室', logic.deptCtrl, hint: '请输入科室'),
                _field('床号', logic.bedCtrl, hint: '请输入床号'),
                _field('备注', logic.remarkCtrl, hint: '选填', maxLines: 3),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Text(
              '提示：患者ID与就诊号至少填一项，便于后续对齐文书与院内数据。',
              style: WbTheme.meta13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String hint = '请输入',
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: WbTheme.inputBackground, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: WbTheme.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            maxLines: maxLines,
            style: TextStyle(fontSize: 16.sp, color: WbTheme.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 4.h),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 16.sp, color: WbTheme.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gender(PatientEditLogic logic) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: WbTheme.inputBackground, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '性别',
            style: TextStyle(
              fontSize: 13.sp,
              color: WbTheme.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          _GenderChips(logic: logic),
        ],
      ),
    );
  }
}

class _GenderChips extends StatefulWidget {
  const _GenderChips({required this.logic});
  final PatientEditLogic logic;

  @override
  State<_GenderChips> createState() => _GenderChipsState();
}

class _GenderChipsState extends State<_GenderChips> {
  @override
  Widget build(BuildContext context) {
    Widget btn(String label, int? value) {
      final selected = widget.logic.gender == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => widget.logic.gender = value),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: selected ? WbTheme.primary : WbTheme.inputBackground,
              borderRadius: WbTheme.radiusSm,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : WbTheme.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn('男', 1),
        SizedBox(width: 10.w),
        btn('女', 2),
        SizedBox(width: 10.w),
        btn('未知', null),
      ],
    );
  }
}
