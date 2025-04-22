import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/core.dart';


class LeaderboardDialog extends StatelessWidget {
  final HomeController controller;

  const LeaderboardDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black.withOpacity(0.4),
      child: Container(
        width: Get.width * 0.95,
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          children: [
            Text(
              "🏆 Leaderboard",
              style: GoogleFonts.sawarabiGothic(
                fontSize: 24,
                color: Colors.amberAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    controller.buildGameFilterButton(
                        -1, "Semua", controller.selectedGameId.value),
                    controller.buildGameFilterButton(
                        0, "Math Metrix", controller.selectedGameId.value),
                    controller.buildGameFilterButton(
                        1, "Memory Game", controller.selectedGameId.value),
                    controller.buildGameFilterButton(
                        2, "MineSweeper", controller.selectedGameId.value),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                      child: Text("⏳ Memuat...",
                          style: GoogleFonts.sawarabiGothic(
                              fontSize: 12, color: Colors.white)));
                }

                if (controller.filteredLeaderboard.isEmpty) {
                  return Center(
                      child: Text("Belum ada data leaderboard.",
                          style: GoogleFonts.sawarabiGothic(
                              fontSize: 10, color: Colors.white),
                          textAlign: TextAlign.center));
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        controller.groupedLeaderboard.entries.map((gameEntry) {
                      final gameTitle = gameEntry.key;
                      final levels = gameEntry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gameTitle,
                              style: GoogleFonts.sawarabiGothic(
                                  fontSize: 16, color: Colors.amber)),
                          const SizedBox(height: 4),
                          ...levels.entries.map((levelEntry) {
                            final level = levelEntry.key;
                            final topEntries =
                                levelEntry.value.take(3).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Level: $level",
                                    style: GoogleFonts.sawarabiGothic(
                                        fontSize: 14, color: Colors.white)),
                                const SizedBox(height: 4),
                                ...topEntries.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var e = entry.value;
                                  bool isCurrentUser = e.username ==
                                      controller.userModel.value?.username;

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.amber.shade100
                                          : Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2))
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        controller.buildRankBadge(index),
                                        const SizedBox(width: 8),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              Colors.deepPurple.shade300,
                                          backgroundImage: e.avatar.isNotEmpty
                                              ? NetworkImage(e.avatar)
                                              : null,
                                          child: e.avatar.isEmpty
                                              ? Text(
                                                  e.username[0].toUpperCase(),
                                                  style: GoogleFonts
                                                      .sawarabiGothic(
                                                          fontSize: 12,
                                                          color: Colors.white))
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  isCurrentUser
                                                      ? "Anda"
                                                      : e.username,
                                                  style: GoogleFonts
                                                      .sawarabiGothic(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isCurrentUser
                                                              ? Colors.black
                                                              : Colors.grey
                                                                  .shade800)),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(e.played_at,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: isCurrentUser
                                                              ? Colors
                                                                  .grey.shade800
                                                              : Colors
                                                                  .black54)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text("${e.timePlay} detik",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isCurrentUser
                                                    ? Colors.grey.shade800
                                                    : Colors.black87)),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AudioService.playButtonSound();
                  Get.back();
                },
                icon: Icon(Icons.close, color: Colors.white),
                label: Text("TUTUP",
                    style: GoogleFonts.sawarabiGothic(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
