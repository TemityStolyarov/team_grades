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
  bool isOnTeamAddition = true;
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
      isOnTeamAddition = !isOnTeamAddition;
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
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _switchSide(),
                    child: Text(
                      '<- К списку участников',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: isOnTeamAddition ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _switchSide(),
                    child: Text(
                      'К оцениванию ->',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: isOnTeamAddition ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: isOnTeamAddition
              ? TeamEditingScreen(
                  controller: _controller,
                  addParticipant: _addParticipant,
                  participants: participants,
                )
              : TeamRankingScreen(
                  participants: participants,
                ),
        ),
      ),
    );
  }
}
