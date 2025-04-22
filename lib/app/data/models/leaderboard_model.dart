class Leaderboard {
  String? id;
  String userId;
  int gameId;
  int score;
  int timePlay;
  String played_at;
  String level;
  final String username; 
  final String gameName;
  final String avatar; 

  Leaderboard({
    this.id,
    required this.userId,
    required this.gameId,
    required this.score,
    required this.timePlay,
    required this.played_at,
    required this.level,
    this.username = "Unknown User",
    this.gameName = "Unknown Game",
    this.avatar = "Unknown avatar",
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "game_id": gameId,
      "score": score,
      "time_play": timePlay,
      "played_at": played_at,
      "level": level,
    };
  }

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      id: json["id"],
      userId: json["user_id"],
      gameId: json["game_id"],
      score: json["score"],
      timePlay: json["time_play"],
      played_at: json["played_at"],
      level: json["level"],
    );
  }

  Leaderboard copyWith({String? username, String? gameName, String? avatar}) {
    return Leaderboard(
      userId: userId,
      gameId: gameId,
      score: score,
      played_at: played_at,
      level: level,
      timePlay: timePlay,
      username: username ?? this.username,
      gameName: gameName ?? this.gameName,
      avatar: avatar ?? this.avatar,
    );
  }
}
