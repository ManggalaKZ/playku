import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:playku/app/modules/auth/controller/login_controller.dart';
import 'package:playku/core/theme.dart';

class HomeBackground extends StatelessWidget {
  final BuildContext context;
  final LoginController loginController;

  const HomeBackground({
    Key? key,
    required this.context,
    required this.loginController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
