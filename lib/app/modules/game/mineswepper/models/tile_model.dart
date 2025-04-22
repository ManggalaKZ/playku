class TileModel {
  bool isBomb;
  bool isOpened;
  bool isFlagged;
  int adjacentBombs;
  final int row;
  final int col;

  TileModel({
    this.isBomb = false,
    this.isOpened = false,
    this.isFlagged = false,
    this.adjacentBombs = 0,
    required this.row,
    required this.col,
  });

  void openTile() {
    if (isFlagged) return;
    isOpened = true;
    
  }

  void toggleFlag() {
    isFlagged = !isFlagged;
  }
}
