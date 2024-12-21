import 'package:flutter/material.dart';

class TeamEditingScreen extends StatefulWidget {
  const TeamEditingScreen({
    super.key,
    required this.controller,
    required this.addParticipant,
    required this.participants,
  });

  final TextEditingController controller;
  final VoidCallback addParticipant;
  final List<String> participants;

  @override
  State createState() => _TeamEditingScreenState();
}

class _TeamEditingScreenState extends State<TeamEditingScreen> {
  void _editParticipant(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController editController =
            TextEditingController(text: widget.participants[index]);

        return AlertDialog(
          title: const Text('Редактировать участника'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Новое имя участника',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.participants[index] = editController.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _deleteParticipant(int index) {
    setState(() {
      widget.participants.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление участниками'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      labelText: 'Добавить участника',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: widget.addParticipant,
                  child: const Text('Добавить'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Список участников:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ReorderableListView(
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = widget.participants.removeAt(oldIndex);
                    widget.participants.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < widget.participants.length; i++)
                    ListTile(
                      key: UniqueKey(),
                      leading: Text('${i + 1}.'),
                      title: Text(widget.participants[i]),
                      trailing: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editParticipant(i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteParticipant(i),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
