import 'package:flutter/material.dart';
import 'package:team_grades/team_editing_screen.dart';
import 'package:team_grades/team_ranking_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isOnTeamRanking = false;
  List<String> participants = [];
  final TextEditingController _controller = TextEditingController();

  void _addParticipant() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        participants.add(name);
      });
      _controller.clear();
    }
  }

  _switchSide() {
    setState(() {
      isOnTeamRanking = !isOnTeamRanking;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(120, 100),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                MouseRegion(
                  cursor: isOnTeamRanking
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.forbidden,
                  child: GestureDetector(
                    onTap: isOnTeamRanking ? () => _switchSide() : null,
                    child: Text(
                      '<- К списку участников',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: isOnTeamRanking ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                MouseRegion(
                  cursor: isOnTeamRanking
                      ? SystemMouseCursors.forbidden
                      : SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: isOnTeamRanking ? null : () => _switchSide(),
                    child: Text(
                      'К оцениванию ->',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: isOnTeamRanking ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: isOnTeamRanking
              ? TeamRankingScreen(
                  participants: participants,
                )
              : TeamEditingScreen(
                  controller: _controller,
                  addParticipant: _addParticipant,
                  participants: participants,
                ),
        ),
      ),
    );
  }
}
