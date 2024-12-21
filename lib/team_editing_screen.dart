import 'package:flutter/material.dart';

class TeamEditingScreen extends StatefulWidget {
  const TeamEditingScreen({
    super.key,
    required this.controller,
    required this.addParticipant, required this.participants,
  });

  final TextEditingController controller;
  final VoidCallback addParticipant;
  final List<String> participants;

  @override
  State createState() => _TeamEditingScreenState();
}

class _TeamEditingScreenState extends State<TeamEditingScreen> {
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
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.participants.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${index + 1}.'),
                    title: Text(widget.participants[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
