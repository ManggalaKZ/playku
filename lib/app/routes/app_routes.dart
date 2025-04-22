import 'package:get/get.dart';
import 'package:playku/app/bindings/home_binding.dart';
import 'package:playku/app/bindings/login_binding.dart';
import 'package:playku/app/bindings/memory_game_binding.dart';
import 'package:playku/app/bindings/minesweeper_binding.dart';
import 'package:playku/app/bindings/registrasi_binding.dart';
import 'package:playku/app/bindings/welcome_binding.dart';
import 'package:playku/app/modules/auth/view/registrasi_view.dart';
import 'package:playku/app/modules/game/answer-question/view/answer_question_view.dart';
import 'package:playku/app/modules/game/memory-game/views/memory_game_view.dart';
import 'package:playku/app/modules/game/mineswepper/views/minesweeper_view.dart';
import '../bindings/splash_binding.dart';
import '../modules/auth/view/login_view.dart';
import '../modules/home/view/home_view.dart';
import '../modules/landing/view/splash_view.dart';
import '../modules/welcome/view/welcome_view.dart';

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
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      transition: Transition.downToUp,
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTRASI,
      page: () => const RegistrasiView(),
      binding: RegistrasiBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () =>  HomeView(),
      binding: HomeBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.MINESWEEPER,
      page: () =>  MinesweeperView(),
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
