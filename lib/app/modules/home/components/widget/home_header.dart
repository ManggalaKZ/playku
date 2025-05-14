import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/modules/home/controller/frame_controller.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/theme.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class HomeHeader extends StatelessWidget {
  final UserController userController;
  final FrameController frameController;
  final BuildContext context;
  bool tooltipShown;
  final GlobalKey _editButtonKey = GlobalKey();
  HomeHeader({
    super.key,
    required this.userController,
    required this.frameController,
    required this.context,
    required this.tooltipShown,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Obx(() {
        final frame = frameController.usedFrame.value;
        final user = userController.userModel.value;
        if (user != null && !tooltipShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration(milliseconds: 200), () {
              debugPrint("[DEBUG] Cek avatar kosong: '${user.avatar}'");

              if ((user.avatar ?? "").isEmpty ||
                  user.avatar ==
                      "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg") {
                if (_editButtonKey.currentContext != null) {
                  debugPrint(
                      "[DEBUG] Context edit button tersedia, tampilkan tooltip.");
                  tooltipShown = true;
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
        if (frameController.isLoadingFrames.value || frame == null) {
          // Contoh: Tampilkan placeholder atau avatar default
          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300, // Warna placeholder
            // Atau tampilkan ikon default
            // child: Icon(Icons.person, size: 40, color: Colors.white),
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
                  Image.network(
                    frame.imagePath,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.error, size: 30, color: Colors.grey)),
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        // Jika loading selesai, tampilkan gambar
                        return child;
                      } else {
                        // Jika masih loading, tampilkan CircularProgressIndicator
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null, // Tampilkan progress jika memungkinkan
                            strokeWidth: 2.0, // Atur ketebalan spinner
                          ),
                        );
                      }
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: InkWell(
                      key: _editButtonKey,
                      onTap: () {
                        userController.showEditProfile();
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
                  userController.showEditProfile();
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
}
