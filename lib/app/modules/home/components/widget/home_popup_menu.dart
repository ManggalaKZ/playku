import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/auth/controller/login_controller.dart';
import 'package:playku/core.dart';

class HomePopupMenu extends StatelessWidget {
  final GlobalKey menuKey;
  final LoginController loginController;
  final Function onLogout;

  const HomePopupMenu({
    Key? key,
    required this.menuKey,
    required this.loginController,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: menuKey,
      icon: Icon(
        Icons.settings,
        size: 32,
        color: AppColors.whitePrimary,
      ),
      menuPadding: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      onOpened: () {
        AudioService.playButtonSound();
      },
      onCanceled: () {
        AudioService.playButtonSound();
      },
      onSelected: (value) async {
        if (value == 'logout') {
          await SharedPreferenceHelper.clearUserData();
          onLogout();
        } else if (value == 'sound') {
          loginController.toggleSound();
        }
      },
      color: AppColors.primary,
      elevation: 12,
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'sound',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                SoundButton(
                  controller: loginController,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Musik",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
