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

  Future<void> _deleteTask(Task task) async {
    // keep a copy for undo
    final deleted = task;
    if (deleted.id == null) return;
    await DatabaseHelper.deleteTask(deleted.id!);
    await _loadTasks();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tarefa '${deleted.titulo}' excluída."),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () async {
            // reinsert the deleted task (without id so autoincrement)
            final restored = Task(
              titulo: deleted.titulo,
              descricao: deleted.descricao,
              prioridade: deleted.prioridade,
              criadoEm: deleted.criadoEm,
              prefixoEmpresa: deleted.prefixoEmpresa,
            );
            await DatabaseHelper.insertTask(restored);
            await _loadTasks();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        actions: [
          IconButton(
            tooltip: 'Mostrar caminho do DB',
            icon: const Icon(Icons.storage),
            onPressed: () async {
              final path = DatabaseHelper.getDbPath() ?? 'DB não inicializado';
              final tasks = await DatabaseHelper.getTasks();
              await showDialog<void>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Informações do DB'),
                  content: SelectableText(
                    'Path: $path\nRegistros: ${tasks.length}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
                      await _deleteTask(t);
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
                          if ((t.prefixoEmpresa ?? '').isNotEmpty)
                            Text('Prefixo: ${t.prefixoEmpresa}'),
                          const SizedBox(height: 6),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
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
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Confirmar'),
                                  content: const Text(
                                    'Deseja excluir esta tarefa?',
                                  ),
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
                              if (ok == true) await _deleteTask(t);
                            },
                          ),
                        ],
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
