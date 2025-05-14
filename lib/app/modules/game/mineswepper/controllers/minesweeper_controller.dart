import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/services/queue_service.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/dialog_new_leaderboard.dart';
import 'package:playku/core.dart';
import 'package:playku/core_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  void onTileTapped(int row, int col, BuildContext context) {
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

      lastTime = game.convertTimeToSeconds(game.elapsedTimeString.value);
      tileComponents['$row,$col']?.updateTile = tile;
      game.ccTimer();
      _revealAllTiles();
      gameOver = true;
      onGameEndCallback!(false);
    } else {
      _floodFill(row, col);
      if (_checkWin()) {
        final game = Get.find<MinesweeperGame>();
        game.ccTimer();
        lastTime = game.convertTimeToSeconds(game.elapsedTimeString.value);
        gameOver = true;
        onGameEndCallback!(true);
        addData(context);
      }
    }

    update();
  }

  void addData(BuildContext context) async {
    final game = Get.find<MinesweeperGame>();
    int finalTime = lastTime;
    int finalScore = 10;
    String userId = userModel.value!.id ?? "";
    String now = DateTime.now().toString();
    String levels = selectedLevel.value.toString().split('.').last;

    loadLeaderboard(idgame);

    debugPrint("User ID: $userId");
    debugPrint("Game ID: ${idgame}");
    debugPrint("Final Score: $finalScore");
    debugPrint("Final Time: $finalTime");
    debugPrint("Date Now: $now");

    Map<String, dynamic> gameResult = {
      'userId': userId,
      'gameId': idgame,
      'score': finalScore,
      'timePlay': finalTime,
      'level': levels,
      'playedAt': now,
    };

    bool success = await GameService.postGameResult(
      userId: userId,
      gameId: idgame,
      score: finalScore,
      timePlay: finalTime,
      level: levels,
      playedAt: now,
    );

    if (!success) {
      await QueueService.addToQueue(gameResult);
    } else {
      await QueueService.removeFromQueue(gameResult);
      debugPrint("Data gameplay berhasil dikirim!");
      int? newPoint = await PointService.updateUserPoint(userId, 5);
      if (newPoint != null) {
        userModel.value = userModel.value!.copyWith(point: newPoint);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', jsonEncode(userModel.value!.toJson()));
        debugPrint(
            "Point berhasil disinkronkan ke SharedPreferences: $newPoint");
        HomeController homeController = Get.find<HomeController>();
        homeController.userController.loadUserFromPrefs();
        homeController.userController.userModel.refresh();
        homeController.leaderboardController.loadLeaderboard();
      }
    }

    // Proses queue setiap kali game selesai (jika online)
    await QueueService.processQueue();

    // .then((success) async {
    //   if (success) {
    //     debugPrint("Data gameplay berhasil dikirim!");
    //     int? newPoint = await PointService.updateUserPoint(userId, 5);
    //     if (newPoint != null) {
    //       userModel.value = userModel.value!.copyWith(point: newPoint);
    //       SharedPreferences prefs = await SharedPreferences.getInstance();
    //       prefs.setString('user', jsonEncode(userModel.value!.toJson()));
    //       debugPrint("Point berhasil disinkronkan ke SharedPreferences: $newPoint");
    //       HomeController homeController = Get.find<HomeController>();
    //       homeController.userController.loadUserFromPrefs();
    //       homeController.userController.userModel.refresh();
    //       homeController.leaderboardController.loadLeaderboard();
    //     }
    //   } else {
    //     debugPrint("Gagal mengirim data gameplay.");
    //   }
    // });

    Leaderboard entry = Leaderboard(
      userId: userId,
      gameId: idgame,
      score: finalScore,
      timePlay: finalTime,
      played_at: now,
      level: levels,
    );

    addScore(entry, "Mine Sweeper");
  }

  Future<void> loadLeaderboard(int gameId) async {
    String levels = selectedLevel.value.toString().split('.').last;

    try {
      leaderboard.value =
          await LeaderboardService.getLeaderboard(gameId, levels);
    } catch (e) {
      debugPrint("Error: $e");
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
      debugPrint("User berhasil dimuat: ${userModel.value!.id}");
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
    _generateBoardAvoiding(0, 0);
    update();
  }

  Future<void> addScore(Leaderboard entry, String gameName) async {
    List<Leaderboard> before =
        await LeaderboardService.getLeaderboard(entry.gameId, entry.level);
    await LeaderboardService.updateLeaderboard(entry);
    List<Leaderboard> after =
        await LeaderboardService.getLeaderboard(entry.gameId, entry.level);

    bool isChanged = false;
    bool wasInBefore = before
        .any((b) => b.userId == entry.userId && b.timePlay == entry.timePlay);
    bool isInAfter = after
        .any((a) => a.userId == entry.userId && a.timePlay == entry.timePlay);

    if (!wasInBefore && isInAfter) {
      isChanged = true;
    }
    for (var beforeEntry in before) {
      bool stillExists = after.any((a) =>
          a.userId == beforeEntry.userId &&
          a.timePlay == beforeEntry.timePlay &&
          a.played_at == beforeEntry.played_at);
      if (!stillExists) {
        isChanged = true;
        break;
      }
    }
    if (isChanged) {
      int? newIndex = after.indexWhere(
          (a) => a.userId == entry.userId && a.timePlay == entry.timePlay);
      DialogNewLeaderboard.showLeaderboardCongrats(
        gameName,
        beforeRanks: before,
        afterRanks: after,
        newRankIndex: newIndex >= 0 ? newIndex : null,
      );
    }
  }
}
