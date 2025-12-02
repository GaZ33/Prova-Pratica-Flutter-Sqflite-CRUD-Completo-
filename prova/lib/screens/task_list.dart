import 'package:flutter/material.dart';
import 'package:prova/db/database_helper.dart';
import 'package:prova/models/task.dart';
import 'task_form.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
    });
    final tasks = await DatabaseHelper.getTasks();
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.deleteTask(id);
    await _loadTasks();
  }

  Color _priorityColor(int p) {
    switch (p) {
      case 3:
        return Colors.red.shade400;
      case 2:
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  Color _parseColor(String hex) {
    try {
      var h = hex.trim();
      if (h.startsWith('#')) h = h.substring(1);
      if (h.length == 6) h = 'FF$h';
      final val = int.parse(h, radix: 16);
      return Color(val);
    } catch (_) {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? const Center(child: Text('Nenhuma tarefa cadastrada'))
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final t = _tasks[index];
                  return Dismissible(
                    key: ValueKey(t.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (dir) async {
                      final res = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Confirmar'),
                          content: const Text('Deseja excluir esta tarefa?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                      return res == true;
                    },
                    onDismissed: (_) async {
                      if (t.id != null) await _deleteTask(t.id!);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _priorityColor(t.prioridade),
                        child: Text('${t.prioridade}'),
                      ),
                      title: Text(t.titulo),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((t.descricao ?? '').isNotEmpty)
                            Text(t.descricao!),
                          if ((t.campoExtra ?? '').isNotEmpty)
                            Text('Extra: ${t.campoExtra}'),
                          if ((t.tema ?? '').isNotEmpty)
                            Text('Tema: ${t.tema}'),
                          if ((t.ra ?? '').isNotEmpty) Text('RA: ${t.ra}'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if ((t.corPrimaria ?? '').isNotEmpty)
                                Container(
                                  width: 18,
                                  height: 18,
                                  color: _parseColor(t.corPrimaria!),
                                  margin: const EdgeInsets.only(right: 8),
                                ),
                              if ((t.corSecundaria ?? '').isNotEmpty)
                                Container(
                                  width: 18,
                                  height: 18,
                                  color: _parseColor(t.corSecundaria!),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final changed = await Navigator.push<bool?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskForm(task: t),
                            ),
                          );
                          if (changed == true) await _loadTasks();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.push<bool?>(
            context,
            MaterialPageRoute(builder: (_) => const TaskForm()),
          );
          if (changed == true) await _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
