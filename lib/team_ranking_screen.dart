import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Future<void> _saveEvaluation() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final Map<String, int> rankings = {
      for (int i = 0; i < rankedParticipants.length; i++)
        rankedParticipants[i]: rankedParticipants.length - i,
    };

    evaluationResults[currentEvaluator] = rankings;

    // Вывод JSON оценок текущего участника в консоль
    final jsonString = jsonEncode({currentEvaluator: rankings});
    print('$currentEvaluator: $jsonString');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Оценки сохранены для $currentEvaluator')),
    );

    _startNextEvaluation();
  }

  Future<void> copyResultsToClipboard() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      final jsonString = jsonEncode(evaluationResults);
      print('Итоговый файл: $jsonString');
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

  List<MapEntry<String, double>> _calculateFinalScores() {
    final Map<String, int> totalScores = {};

    // Суммируем баллы для каждого участника
    evaluationResults.forEach((evaluator, rankings) {
      rankings.forEach((participant, score) {
        totalScores.update(participant, (value) => value + score,
            ifAbsent: () => score);
      });
    });

    // Находим минимальную и максимальную сумму баллов
    final minScore = totalScores.values.reduce((a, b) => a < b ? a : b);
    final maxScore = totalScores.values.reduce((a, b) => a > b ? a : b);
    final totalSum = totalScores.values.fold(0, (a, b) => a + b);

    // Вычисляем финальные оценки по формуле
    List<MapEntry<String, double>> finalScores = [];

    totalScores.forEach((participant, score) {
      double normalizedScore;

      if (minScore == maxScore) {
        normalizedScore = 3.5;
      } else {
        normalizedScore = 2 + (score - minScore) * (3 / (maxScore - minScore));
      }

      // Округляем до одного знака после запятой
      finalScores.add(MapEntry(
          participant, double.parse(normalizedScore.toStringAsFixed(1))));
    });

    // Сортируем по убыванию финальной оценки
    finalScores.sort((a, b) => b.value.compareTo(a.value));

    return finalScores;
  }

  @override
  Widget build(BuildContext context) {
    if (currentEvaluator.isEmpty) {
      // Итоговый топ участников
      final List<MapEntry<String, double>> finalScores =
          _calculateFinalScores();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Оценивание завершено'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Итоговый рейтинг участников:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: finalScores.length,
                        itemBuilder: (context, index) {
                          final entry = finalScores[index];
                          return ListTile(
                            title: Text('${index + 1}. ${entry.key}'),
                            trailing: Text('Оценка: ${entry.value}'),
                          );
                        },
                      ),
                    ),
                  ],
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
                        'Оценка: ${rankedParticipants.length - i}',
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
