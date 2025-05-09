import 'package:get/get.dart';
import 'package:playku/app/bindings/login_binding.dart';
import 'package:playku/core.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTRASI = '/registrasi';
  static const HOME = '/home';
  static const WELCOME = '/welcome';
  static const ANSWER_QUESTION = '/answer-question';
  static const MEMORY_GAME = '/memory-game';
  static const MINESWEEPER = '/minesweeper';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      transition: Transition.downToUp,
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 700),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      transition: Transition.circularReveal,
      binding: LoginBinding(),
      transitionDuration: const Duration(milliseconds: 700),
    ),
    GetPage(
      name: Routes.REGISTRASI,
      page: () => const RegistrasiView(),
      binding: RegistrasiBinding(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 700),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 700),
    ),
    GetPage(
      name: Routes.MINESWEEPER,
      page: () => MinesweeperView(),
      binding: MinesweeperBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.ANSWER_QUESTION,
      page: () => AnswerQuestionView(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.MEMORY_GAME,
      page: () => MemoryGameView(),
      binding: MemoryGameBinding(),
      transition: Transition.noTransition,
    ),
  ];
}
