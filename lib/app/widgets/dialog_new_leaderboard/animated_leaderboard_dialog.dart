import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/services/point_service.dart';
import 'package:playku/app/data/services/user_service.dart';
import 'package:playku/app/modules/home/controller/home_controller.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/leaderboard_rank_list.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/claim_point_button.dart';
import 'package:playku/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playku/app/data/models/leaderboard_model.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/leaderboard_point_service.dart';

class AnimatedLeaderboardDialog extends StatefulWidget {
  final String gameName;
  final List<Leaderboard> beforeRanks;
  final List<Leaderboard> afterRanks;
  final int? newRankIndex;

  const AnimatedLeaderboardDialog({
    Key? key,
    required this.gameName,
    required this.beforeRanks,
    required this.afterRanks,
    this.newRankIndex,
  }) : super(key: key);

  @override
  State<AnimatedLeaderboardDialog> createState() =>
      _AnimatedLeaderboardDialogState();
}

class _AnimatedLeaderboardDialogState extends State<AnimatedLeaderboardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool showAfter = false;
  List<Leaderboard> beforeRanksWithUser = [];
  List<Leaderboard> afterRanksWithUser = [];
  int? pointTambahan;
  bool isDataFetched = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fetchUsersForLeaderboard();
    _setAndAddPointUser();
  }

  Future<void> _setAndAddPointUser() async {
    pointTambahan = LeaderboardPointService.calculatePoint(widget.newRankIndex);
    print("Point tambahan: $pointTambahan");
    await LeaderboardPointService.addPointUser(pointTambahan);
    setState(() {});
  }

  Future<void> _fetchUsersForLeaderboard() async {
    Future<List<Leaderboard>> updateUserData(List<Leaderboard> ranks) async {
      List<Leaderboard> updatedRanks = [];
      print("Fetching user details for leaderboard...");
      print("Original rank list: ${ranks.map((e) => e.userId).toList()}");

      for (var entry in ranks) {
        try {
          final userDetails = await UserService.getUserDetails(entry.userId);
          updatedRanks.add(entry.copyWith(
            username: userDetails['username'] ?? entry.username,
            avatar: userDetails['avatar'] ?? entry.avatar,
          ));
        } catch (e) {
          updatedRanks.add(entry);
        }
      }
      return updatedRanks;
    }

    beforeRanksWithUser = await updateUserData(widget.beforeRanks);
    afterRanksWithUser = await updateUserData(widget.afterRanks);

    if (beforeRanksWithUser.isEmpty && afterRanksWithUser.isNotEmpty) {}

    if (mounted) {
      setState(() {
        isDataFetched = true;
      });
      Future.delayed(Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            showAfter = true;
          });
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = !isDataFetched;
    final int itemCount =
        showAfter ? afterRanksWithUser.length : beforeRanksWithUser.length;

    final double calculatedHeight = (itemCount * 70).clamp(70, 240).toDouble();

    return AlertDialog(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Center(
        child: Text(
          '🎉 Selamat! 🎉',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      content: isLoading
          ? const SizedBox(
              height: 100,
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.newRankIndex != null)
                      Text(
                        '🏆 Anda mendapatkan $pointTambahan Poin!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sawarabiGothic(
                            color: Colors.white, fontSize: 20),
                      ),
                    SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        key: ValueKey(showAfter),
                        height: calculatedHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedOpacity(
                              opacity: showAfter ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 600),
                              child: LeaderboardRankList(
                                  ranks: beforeRanksWithUser),
                            ),
                            AnimatedOpacity(
                              opacity: showAfter ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 600),
                              child: ScaleTransition(
                                scale: _animation,
                                child: LeaderboardRankList(
                                  ranks: afterRanksWithUser,
                                  highlightIndex: widget.newRankIndex,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
      actions: [
        Center(
          child: ClaimPointButton(
            pointTambahan: pointTambahan,
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }
}
