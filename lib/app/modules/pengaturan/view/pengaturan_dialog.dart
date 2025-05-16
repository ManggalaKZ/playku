import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/core/theme.dart';
import '../controller/pengaturan_controller.dart';

class PengaturanDialog extends StatelessWidget {
  final PengaturanController controller = Get.put(PengaturanController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Dialog(
          child: Container(
            width: Get.width,
            height: Get.height * 0.4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color.fromARGB(48, 0, 0, 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.down,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Container(
                      color: const Color.fromARGB(47, 255, 255, 255),
                      child: NavigationRail(
                        indicatorColor: Colors.transparent,
                        groupAlignment: 0.0,
                        backgroundColor: Colors.transparent,
                        selectedIndex: controller.selectedIndex.value,
                        onDestinationSelected: (index) =>
                            controller.selectedIndex.value = index,
                        labelType: NavigationRailLabelType.all,
                        selectedIconTheme:
                            const IconThemeData(color: Colors.black, size: 35),
                        unselectedIconTheme:
                            const IconThemeData(color: Colors.white),
                        selectedLabelTextStyle:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        unselectedLabelTextStyle:
                            const TextStyle(color: Colors.white),
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.music_note),
                            label: Text("Musik"),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.border_outer),
                            label: Text("Border"),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person),
                            label: Text("Akun"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: controller.buildSettingContent(),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
