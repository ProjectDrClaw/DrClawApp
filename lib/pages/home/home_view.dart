import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:business_workbench/business_workbench.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../contacts/contacts_view.dart';
import '../conversation/conversation_view.dart';
import '../mine/mine_view.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  final logic = Get.find<HomeLogic>();
  HomePage({super.key});

  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: ConversationPage(),
          item: ItemConfig(
            icon: _setupIcon(
              const _ChatTabIcon(active: true),
              logic.unreadMsgCount.value,
            ),
            inactiveIcon: _setupIcon(
              const _ChatTabIcon(active: false),
              logic.unreadMsgCount.value,
            ),
            title: StrRes.home,
            textStyle: Styles.ts_0089FF_10sp_semibold,
          ),
        ),
        PersistentTabConfig(
          screen: ContactsPage(),
          item: ItemConfig(
            icon: _setupIcon(
                ImageRes.homeTab2Sel.toImage, logic.unhandledCount.value),
            inactiveIcon: _setupIcon(
                ImageRes.homeTab2Nor.toImage, logic.unhandledCount.value),
            title: StrRes.contacts,
            textStyle: Styles.ts_0089FF_10sp_semibold,
          ),
        ),
        PersistentTabConfig(
          screen: WorkbenchPage(),
          item: ItemConfig(
            icon: ImageRes.homeTab3Sel.toImage,
            inactiveIcon: ImageRes.homeTab3Nor.toImage,
            title: StrRes.workbench,
            textStyle: Styles.ts_0089FF_10sp_semibold,
          ),
        ),
        PersistentTabConfig(
          screen: MinePage(),
          item: ItemConfig(
            icon: ImageRes.homeTab4Sel.toImage,
            inactiveIcon: ImageRes.homeTab4Nor.toImage,
            title: StrRes.mine,
            textStyle: Styles.ts_0089FF_10sp_semibold,
          ),
        ),
      ];

  Widget _setupIcon(Widget icon, int unReadCount) {
    return Stack(
      alignment: Alignment.center,
      children: [
        icon,
        Positioned(
          top: 0,
          right: 0,
          child: Transform.translate(
            offset: const Offset(2, -2),
            child: UnreadCountView(count: unReadCount),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.c_FFFFFF,
      body: Obx(
        () => PersistentTabView(
          tabs: _tabs(),
          navBarBuilder: (navBarConfig) => Style1BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: const NavBarDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 0.5, spreadRadius: 0.5),
              ],
            ),
          ),
          navBarOverlap: const NavBarOverlap.none(),
          screenTransitionAnimation: const ScreenTransitionAnimation.none(),
        ),
      ),
    );
  }
}

/// 与其它 Tab 切图同风格的实心单气泡
class _ChatTabIcon extends StatelessWidget {
  const _ChatTabIcon({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    // 与 Style1BottomNavBar 的 IconTheme.iconSize（默认 26）对齐
    final size = IconTheme.of(context).size ?? 26.0;
    final color = active ? Styles.c_0089FF : Styles.c_8E9AB0;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ChatTabPainter(color: color)),
    );
  }
}

class _ChatTabPainter extends CustomPainter {
  _ChatTabPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.saveLayer(Offset.zero & size, Paint());

    // 单气泡主体
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.06,
          size.width * 0.84,
          size.height * 0.68,
        ),
        Radius.circular(size.width * 0.22),
      ),
      fill,
    );

    // 尖角
    final tip = Path()
      ..moveTo(size.width * 0.22, size.height * 0.66)
      ..lineTo(size.width * 0.16, size.height * 0.92)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..close();
    canvas.drawPath(tip, fill);

    // 两条文字留白
    final erase = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.24,
          size.height * 0.28,
          size.width * 0.52,
          size.height * 0.09,
        ),
        Radius.circular(size.width * 0.05),
      ),
      erase,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.24,
          size.height * 0.46,
          size.width * 0.36,
          size.height * 0.09,
        ),
        Radius.circular(size.width * 0.05),
      ),
      erase,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChatTabPainter oldDelegate) =>
      oldDelegate.color != color;
}
