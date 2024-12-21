import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TeamRankingScreen extends StatefulWidget {
  const TeamRankingScreen({
    super.key,
    required this.participants,
  });

  final List<String> participants;

  @override
  State createState() => _TeamRankingScreenState();
}

class _TeamRankingScreenState extends State<TeamRankingScreen> {
  List<String> remainingParticipants = [];
  String currentEvaluator = '';
  List<String> rankedParticipants = [];
  Map<String, Map<String, int>> evaluationResults = {};

  @override
  void initState() {
    super.initState();
    remainingParticipants = List.from(widget.participants);
    _startNextEvaluation();
  }

  void _startNextEvaluation() {
    setState(() {
      if (remainingParticipants.isNotEmpty) {
        currentEvaluator = remainingParticipants.removeAt(0);
        rankedParticipants = List.from(widget.participants)
          ..remove(currentEvaluator);
      } else {
        currentEvaluator = ''; // Очищаем текущего оценивающего
        rankedParticipants = [];
      }
    });
  }

  int _getScore(int index) {
    return rankedParticipants.length - index;
  }

  Future<void> _saveEvaluation() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final Map<String, int> rankings = {
      for (int i = 0; i < rankedParticipants.length; i++)
        rankedParticipants[i]: _getScore(i),
    };

    evaluationResults[currentEvaluator] = rankings;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Оценки сохранены для $currentEvaluator')),
    );

    _startNextEvaluation();
  }

  Future<void> copyResultsToClipboard() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      final jsonString = jsonEncode(evaluationResults);
      await Clipboard.setData(ClipboardData(text: jsonString));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Результаты скопированы в буфер обмена'),
        ),
      );
    } catch (e) {
      print('Ошибка при копировании JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentEvaluator.isEmpty) {
      // Отображаем заглушку, если все завершили оценивание
      return Scaffold(
        appBar: AppBar(
          title: const Text('Оценивание завершено'),
        ),
        body: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Все участники завершили оценивание.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                bottom: 56,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: copyResultsToClipboard,
                    child: const Text('Скопировать оценки'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Основной интерфейс для текущего оценивающего
    return Scaffold(
      appBar: AppBar(
        title: Text('Оценивающий: $currentEvaluator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  final item = rankedParticipants.removeAt(oldIndex);
                  rankedParticipants.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < rankedParticipants.length; i++)
                  ListTile(
                    key: GlobalKey(debugLabel: rankedParticipants[i]),
                    title: Text(rankedParticipants[i]),
                    trailing: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        'Оценка: ${_getScore(i)}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 56,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _saveEvaluation,
                  child: const Text('Далее'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
