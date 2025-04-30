import 'package:flutter/material.dart';
import 'package:playku/app/modules/game/controller/game_controller.dart';
import 'package:playku/app/modules/home/components/widget/home_game_item.dart';

class HomeGameList extends StatelessWidget {
  final GameController gameController;
  final BuildContext context;

  const HomeGameList({
    Key? key,
    required this.gameController,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          return HomeGameItem(
            title: games[index]['title'],
            thumbnail: games[index]['thumbnail'],
            context: context,
            indexGame: index,
            gameController: gameController,
          );
        }),
      ),
    );
  }
}
