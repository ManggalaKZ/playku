import 'package:flutter/material.dart';
import 'package:playku/app/data/models/leaderboard_model.dart';

class LeaderboardRankList extends StatelessWidget {
  final List<Leaderboard> ranks;
  final int? highlightIndex;

  const LeaderboardRankList({Key? key, required this.ranks, this.highlightIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(ranks.length, (i) {
        final isNew = highlightIndex != null && i == highlightIndex;
        return AnimatedContainer(
          duration: Duration(milliseconds: 500),
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isNew ? Colors.amberAccent.withOpacity(0.7) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isNew
                ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: ListTile(
            leading: ranks[i].avatar != null && ranks[i].avatar!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(ranks[i].avatar!),
                    backgroundColor: isNew ? Colors.orange : Colors.grey[300],
                    radius: 22,
                  )
                : CircleAvatar(
                    backgroundColor: isNew ? Colors.orange : Colors.grey[300],
                    child: Text(
                      "Rank ${i + 1}",
                      style: TextStyle(
                        color: isNew ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    radius: 22,
                  ),
            title: Text(
              ranks[i].username != null && ranks[i].username.isNotEmpty
                  ? ranks[i].username
                  : "Unknown User",
              style: TextStyle(
                fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                fontSize: isNew ? 18 : 16,
                color: isNew ? Colors.orange[900] : Colors.black,
              ),
            ),
            trailing: isNew ? Icon(Icons.star, color: Colors.orange[800]) : null,
          ),
        );
      }),
    );
  }
}