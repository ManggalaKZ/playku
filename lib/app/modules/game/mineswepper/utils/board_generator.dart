import 'dart:math';

import 'package:playku/app/modules/game/mineswepper/models/tile_model.dart';

class BoardGeneratorAvoiding {
  final int rows;
  final int cols;
  final int numBombs;
  final int avoidRow;
  final int avoidCol;

  late List<List<TileModel>> board;

  BoardGeneratorAvoiding({
    required this.rows,
    required this.cols,
    required this.numBombs,
    required this.avoidRow,
    required this.avoidCol,
  }) {
    board = List.generate(rows, (row) {
      return List.generate(cols, (col) {
        return TileModel(row: row, col: col);
      });
    });

    _generateBombs();
    _calculateAdjacentBombs();
  }

  void _generateBombs() {
    Random random = Random();
    int bombsPlaced = 0;

    while (bombsPlaced < numBombs) {
      int row = random.nextInt(rows);
      int col = random.nextInt(cols);

      if ((row - avoidRow).abs() <= 1 && (col - avoidCol).abs() <= 1) {
        continue;
      }

      if (!board[row][col].isBomb) {
        board[row][col].isBomb = true;
        bombsPlaced++;
      }
    }
  }

  void _calculateAdjacentBombs() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (board[row][col].isBomb) continue;

        int bombCount = 0;
        for (int r = -1; r <= 1; r++) {
          for (int c = -1; c <= 1; c++) {
            int newRow = row + r;
            int newCol = col + c;

            if (newRow >= 0 &&
                newRow < rows &&
                newCol >= 0 &&
                newCol < cols &&
                board[newRow][newCol].isBomb) {
              bombCount++;
            }
          }
        }

        board[row][col].adjacentBombs = bombCount;
      }
    }
  }

  List<List<TileModel>> getBoard() {
    return board;
  }
}
