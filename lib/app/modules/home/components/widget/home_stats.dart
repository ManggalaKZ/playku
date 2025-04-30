import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/home/components/widget/home_stat_item.dart';
import 'package:playku/app/modules/home/controller/leaderboard_controller.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:shimmer/shimmer.dart';

class HomeStats extends StatelessWidget {
  final BuildContext context;
  final UserController userController;
  final LeaderboardController leaderboardController;

  const HomeStats({
    Key? key,
    required this.context,
    required this.userController,
    required this.leaderboardController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Obx(() {
              final user = userController.userModel.value;

              if (user == null) {
                return CircularProgressIndicator();
              }

              return Expanded(
                child: HomeStatItem(
                    value: userController.userModel.value?.point?.toString() ?? "0",
                    label: "POINTS",
                    icon: Icons.monetization_on),
              );
            }),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withOpacity(0.6),
            ),
            Expanded(
              child: Obx(() {
                if (leaderboardController.isLoadingui.value) {
                  // 🔹 Shimmer untuk loading leaderboard
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, color: Colors.white, size: 24),
                        SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var topLeaderboard = leaderboardController.userTopLeaderboard.value;
                var rankleaderboard = leaderboardController.userLeaderboardRank.value;
                if (rankleaderboard == -1) {
                  rankleaderboard = 0;
                }
                return InkWell(
                  onTap: leaderboardController.ontap,
                  child: HomeStatItem(
                      value: leaderboardController.cekLeaderboard(),
                      label: topLeaderboard != null
                          ? "${topLeaderboard.gameName}\n${topLeaderboard.level}"
                          : "Tidak Ada",
                      icon: Icons.public),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
