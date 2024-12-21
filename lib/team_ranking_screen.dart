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
  final String evaluatorName = "Оценивающий: Иван";

  List<String> rankedParticipants = [];

  Future<void> copyJsonToClipboard() async {
    final Map<String, int> rankings = {
      for (int i = 0; i < rankedParticipants.length; i++)
        rankedParticipants[i]: _getScore(i),
    };

    try {
      final jsonString = jsonEncode(rankings);
      await Clipboard.setData(ClipboardData(text: jsonString));

      print('JSON скопирован в буфер обмена');
    } catch (e) {
      print('Ошибка при копировании JSON: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    rankedParticipants = List.from(widget.participants);
  }

  int _getScore(int index) {
    return widget.participants.length - index;
  }

  Future<void> _exportToJson() async {
    final Map<String, int> rankings = {
      for (int i = 0; i < rankedParticipants.length; i++)
        rankedParticipants[i]: _getScore(i),
    };

    final jsonString = jsonEncode(rankings);

    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = Directory('/storage/emulated/0/Download');
      final file = File('${directory.path}/rankings.json');
      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Файл сохранен: ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Доступ к хранилищу не предоставлен')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(evaluatorName),
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
                        )),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Переход к предыдущему человеку (здесь можно добавить логику)
                  },
                  child: Text('Назад'),
                ),
                ElevatedButton(
                  onPressed: () => copyJsonToClipboard(),
                  child: Text('Сохранить'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Переход к следующему человеку (здесь можно добавить логику)
                  },
                  child: Text('Вперед'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
