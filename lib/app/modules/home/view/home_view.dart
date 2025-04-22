import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:playku/core.dart';


class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _editButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.put(GameController());
    final LoginController loginController = Get.put(LoginController());
    String? uploadedImageUrl;
    bool _tooltipShown = false;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          _buildBackground(context, loginController),
          SingleChildScrollView(
            controller: ScrollController(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                SizedBox(height: 70),
                _buildHeader(controller, context, _tooltipShown),
                _buildStats(context),
                SizedBox(height: 30),
                _buildGameList(gameController, context),
              ],
            ),
          ),
          Positioned(
            top: 45,
            right: 20,
            child: PopupMenuButton<String>(
              key: _menuKey,
              icon: Icon(
                Icons.settings,
                size: 32,
                color: AppColors.whitePrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onOpened: () {
                AudioService.playButtonSound();
              },
              onCanceled: () {
                AudioService.playButtonSound();
              },
              color: Colors.white,
              elevation: 8,
              onSelected: (value) async {
                if (value == 'logout') {
                  await SharedPreferenceHelper.clearUserData();
                  Get.offAllNamed(Routes.WELCOME);
                } else if (value == 'sound') {
                  loginController.toggleSound();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text("Logout",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'sound',
                  child: Row(
                    children: [
                      SoundButton(controller: loginController),
                      SizedBox(width: 10),
                      Text("Musik",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 45,
            right: 70,
            child: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  size: 32,
                  color: AppColors.whitePrimary,
                ),
                onPressed: () {
                  final frames = [
                    FrameModel(
                      id: 'frame1',
                      name: 'Bingkai Emas',
                      imagePath: 'assets/bingkai/bingkai_default.png',
                      price: 300,
                    ),
                    FrameModel(
                      id: 'frame1',
                      name: 'Bingkai Emas',
                      imagePath: 'assets/bingkai/bingkai_1.png',
                      price: 300,
                    ),
                    FrameModel(
                      id: 'frame2',
                      name: 'Bingkai Sakura',
                      imagePath: 'assets/bingkai/bingkai_2.png',
                      price: 500,
                    ),
                  ];
                  AudioService.playButtonSound();
                  PurchaseFrameDialog.show(
                    frames: frames,
                    onBuy: (frame) {
                      print("Membeli: ${frame.name}");
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(context, loginController) {
    return Stack(
      children: [
        Positioned(
          top: 25,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            "assets/bg/hiasan.svg",
            height: 200,
            color: AppColors.whitePrimary,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 180,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppColors.whitePrimary,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              image: DecorationImage(
                image: AssetImage("assets/images/pattern_light.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.06),
                  BlendMode.srcOver,
                ),
              ),
            ),
            child: Stack(
              children: [
                // Ornamen SVG kecil di pojok
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Opacity(
                    opacity: 0.1,
                    child: SvgPicture.asset(
                      "assets/bg/hiasan.svg",
                      height: 40,
                      width: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(HomeController controller, context, _tooltipShown) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Obx(() {
        final user = controller.userModel.value;
        if (user != null && !_tooltipShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration(milliseconds: 200), () {
              debugPrint("[DEBUG] Cek avatar kosong: '${user.avatar}'");

              if ((user.avatar ?? "").isEmpty ||
                  user.avatar ==
                      "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg") {
                if (_editButtonKey.currentContext != null) {
                  debugPrint(
                      "[DEBUG] Context edit button tersedia, tampilkan tooltip.");
                  _tooltipShown = true;
                } else {
                  debugPrint("[DEBUG] Context edit button NULL!");
                }
              } else {
                debugPrint(
                    "[DEBUG] Avatar sudah ada, tooltip tidak ditampilkan.");
              }
            });
          });
        }

        if (user == null) {
          return Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Container(
              // color: Colors.yellow,
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user.avatar != null && user.avatar!.isNotEmpty
                          ? user.avatar!
                          : "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
                    ),
                    onBackgroundImageError: (_, __) => const Icon(Icons.error),
                  ),
                  Image.asset(
                    'assets/bingkai/bingkai_1.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: InkWell(
                      key: _editButtonKey, 
                      onTap: () {
                        controller.showEditProfile();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              user.name,
              style: GoogleFonts.sawarabiGothic(
                fontSize: 24,
                color: AppColors.primary,
              ),
            ),

            // Tampilkan ajakan jika foto belum diatur
            if (user.avatar == null || user.avatar!.trim().isEmpty)
              GestureDetector(
                onTap: () {
                  controller.showEditProfile();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Lengkapi foto profil kamu",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStats(BuildContext context) {
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
              final user = controller.userModel.value;

              if (user == null) {
                return CircularProgressIndicator();
              }

              return Expanded(
                child: _buildStatItem(
                    controller.cekPoint(), "POINTS", Icons.monetization_on),
              );
            }),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withOpacity(0.6),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingui.value) {
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

                var topLeaderboard = controller.userTopLeaderboard.value;
                var rankleaderboard = controller.userLeaderboardRank.value;
                if (rankleaderboard == -1) {
                  rankleaderboard = 0;
                }
                return InkWell(
                  onTap: controller.ontap,
                  child: _buildStatItem(
                      controller.cekLeaderboard(),
                      topLeaderboard != null
                          ? "${topLeaderboard.gameName}\n${topLeaderboard.level}"
                          : "Tidak Ada",
                      Icons.public),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.sawarabiGothic(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.sawarabiGothic(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildGameList(GameController gameController, BuildContext context) {
    List<Map<String, dynamic>> games = [
      {
        "title": "Math Metrix",
        "thumbnail": "assets/images/math.png",
      },
      {
        "title": "Memory Game",
        "thumbnail": "assets/images/memory.png",
      },
      {
        "title": "Mine Sweeper",
        "thumbnail": "assets/images/memory.png",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: List.generate(games.length, (index) {
          return _buildGame(
            games[index]['title'],
            games[index]['thumbnail'],
            context,
            index,
            gameController,
          );
        }),
      ),
    );
  }

  Widget _buildGame(
    String title,
    String thumbnail,
    BuildContext context,
    int indexGame,
    GameController gameController,
  ) {
    return GestureDetector(
      onTap: () => gameController.showDialogConfirm(context, indexGame, title),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    thumbnail,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.sawarabiGothic(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
