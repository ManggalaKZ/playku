import 'dart:convert';

import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/local/shared_preference_helper.dart';
import 'package:playku/app/data/models/leaderboard_model.dart';
import 'package:playku/app/data/models/user_model.dart';
import 'package:playku/app/data/services/api_service.dart';
import 'package:playku/app/modules/game/mineswepper/game/minesweeper_game.dart';
import 'package:playku/app/modules/game/mineswepper/utils/board_generator.dart';
import 'package:playku/app/modules/home/controller/game_controller.dart';
import 'package:playku/app/modules/home/controller/home_controller.dart';
import 'package:playku/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/tile_component.dart';
import '../models/tile_model.dart';

class MinesweeperController extends GetxController {
  late int rows;
  late int cols;
  late int totalBombs;
  late int lastTime;
  int idgame = 2;
  final Map<String, TileComponent> tileComponents = {};
  var userModel = Rxn<UserModel>();
  var leaderboard = <Leaderboard>[].obs;
  var isCountdownFinished = false.obs;
  var isRestartingGame = false.obs;
  final tiles = <List<TileModel>>[].obs;

  var selectedLevel = GameLevel.easy.obs;
  FlameGame? gameRef;

  bool firstClick = true;
  bool gameOver = false;
  int elapsedSeconds = 0;

  void Function(bool won)? onGameEndCallback;

  @override
  void onInit() {
    super.onInit();
    loadUserFromPrefs();
  }

  void setLevel(GameLevel level) {
    selectedLevel.value = level;

    switch (level) {
      case GameLevel.easy:
        init(6, 6, 6, onGameEndCallback);
        break;
      case GameLevel.medium:
        init(8, 8, 12, onGameEndCallback);
        break;
      case GameLevel.hard:
        init(10, 10, 20, onGameEndCallback);
        break;
    }
  }

  void init(int r, int c, int bombs, void Function(bool won)? onGameEnd) {
    rows = r;
    cols = c;
    totalBombs = bombs;
    onGameEndCallback = onGameEnd;

    tiles.value = List.generate(rows, (row) {
      return List.generate(cols, (col) {
        return TileModel(row: row, col: col);
      });
    });

    firstClick = true;
    gameOver = false;
    elapsedSeconds = 0;
  }

  void onTileTapped(int row, int col) {
    if (gameOver) return;
    final tile = tiles[row][col];
    if (tile.isOpened || tile.isFlagged) return;

    if (firstClick) {
      firstClick = false;
      _generateBoardAvoiding(row, col);
    }

    if (tile.isBomb) {
      tile.openTile();
      final game = Get.find<MinesweeperGame>();

      lastTime = game.getElapsedTimeInSeconds();
      tileComponents['$row,$col']?.updateTile = tile;

      _revealAllTiles();
      gameOver = true;
      onGameEndCallback!(false);
    } else {
      _floodFill(row, col);
      if (_checkWin()) {
        final game = Get.find<MinesweeperGame>();

        lastTime = game.getElapsedTimeInSeconds();
        gameOver = true;
        onGameEndCallback!(true);
        addData();
      }
    }

    update();
  }

  void addData() {
    int finalTime = lastTime;
    int finalScore = 10;
    String userId = userModel.value!.id ?? "";
    String now = DateTime.now().toString();
    String levels = selectedLevel.value.toString().split('.').last;

    loadLeaderboard(idgame);

    print("User ID: $userId");
    print("Game ID: ${idgame}");
    print("Final Score: $finalScore");
    print("Final Time: $finalTime");
    print("Date Now: $now");

    AuthService.postGameResult(
      userId: userId,
      gameId: idgame,
      score: finalScore,
      timePlay: finalTime,
      level: levels,
      playedAt: now,
    ).then((success) async {
      if (success) {
        print("Data gameplay berhasil dikirim!");
        int? newPoint = await AuthService.updateUserPoint(userId);
        if (newPoint != null) {
          userModel.value = userModel.value!.copyWith(point: newPoint);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user', jsonEncode(userModel.value!.toJson()));
          print("Point berhasil disinkronkan ke SharedPreferences: $newPoint");
          HomeController homeController = Get.find<HomeController>();
          homeController.loadUserFromPrefs();
          homeController.userModel.refresh();
          homeController.loadLeaderboard();
        }
      } else {
        print("Gagal mengirim data gameplay.");
      }
    });

    // Simpan ke leaderboard
    Leaderboard entry = Leaderboard(
      userId: userId,
      gameId: idgame,
      score: finalScore,
      timePlay: finalTime,
      played_at: now,
      level: levels,
    );

    addScore(entry);
  }

  Future<void> loadLeaderboard(int gameId) async {
    String levels = selectedLevel.value.toString().split('.').last;

    try {
      leaderboard.value = await AuthService.getLeaderboard(gameId, levels);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> loadUserFromPrefs() async {
    var userData = await SharedPreferenceHelper.getUserData();

    if (userData != null) {
      userModel.value = UserModel(
        point: userData["point"],
        username: userData["name"],
        id: userData["id"],
        name: userData["username"],
        email: userData["email"],
      );
      print("User berhasil dimuat: ${userModel.value!.id}");
    }
  }

  void toggleFlag(int row, int col) {
    final tile = tiles[row][col];
    if (!tile.isOpened) {
      tile.toggleFlag();
      tileComponents['$row,$col']?.updateTile = tile;

      tiles.refresh();
    }
  }

  void _generateBoardAvoiding(int avoidRow, int avoidCol) {
    final generator = BoardGeneratorAvoiding(
      rows: rows,
      cols: cols,
      numBombs: totalBombs,
      avoidRow: avoidRow,
      avoidCol: avoidCol,
    );
    tiles.value = generator.getBoard();
  }

  void _revealAllTiles() {
    for (var row in tiles) {
      for (var tile in row) {
        tile.openTile();
        tileComponents['${tile.row},${tile.col}']?.updateTile = tile;
      }
    }
  }

  bool _checkWin() {
    for (var row in tiles) {
      for (var tile in row) {
        if (!tile.isBomb && !tile.isOpened) {
          return false;
        }
      }
    }
    return true;
  }

  void _floodFill(int row, int col) {
    if (row < 0 || col < 0 || row >= rows || col >= cols) return;

    final tile = tiles[row][col];
    if (tile.isOpened || tile.isFlagged || tile.isBomb) return;

    tile.openTile();
    tileComponents['$row,$col']?.updateTile = tile;

    if (tile.adjacentBombs > 0) return;

    for (int r = -1; r <= 1; r++) {
      for (int c = -1; c <= 1; c++) {
        if (r == 0 && c == 0) continue;
        _floodFill(row + r, col + c);
      }
    }
  }

  void resetGame() {
    firstClick = true;
    gameOver = false;
    elapsedSeconds = 0;
    _generateBoardAvoiding(0, 0);
    update();
  }

  Future<void> addScore(Leaderboard entry) async {
    await AuthService.updateLeaderboard(entry);
    await loadLeaderboard(entry.gameId);
  }
}
