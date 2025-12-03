import 'package:flutter/material.dart';
import 'package:prova/db/database_helper.dart';
import 'package:prova/models/task.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  const TaskForm({super.key, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late String _titulo;
  String? _descricao;
  int _prioridade = 1;
  String? _prefixoEmpresa;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _titulo = t.titulo;
      _descricao = t.descricao;
      _prioridade = t.prioridade;
      _prefixoEmpresa = t.prefixoEmpresa;
    } else {
      _titulo = '';
      _prefixoEmpresa = '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (widget.task == null) {
      final t = Task(
        titulo: _titulo,
        descricao: _descricao,
        prioridade: _prioridade,
        prefixoEmpresa: _prefixoEmpresa,
      );
      await DatabaseHelper.insertTask(t);
    } else {
      final t = Task(
        id: widget.task!.id,
        titulo: _titulo,
        descricao: _descricao,
        prioridade: _prioridade,
        criadoEm: widget.task!.criadoEm,
        prefixoEmpresa: _prefixoEmpresa,
      );
      await DatabaseHelper.updateTask(t);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final ok = await showDialog<bool>(
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
                if (ok == true) {
                  if (widget.task!.id != null)
                    await DatabaseHelper.deleteTask(widget.task!.id!);
                  Navigator.pop(context, true);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _titulo,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Título obrigatório.';
                    }
                    if (v.trim().length < 3) return 'Mínimo 3 caracteres.';
                    return null;
                  },
                  onSaved: (v) => _titulo = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _descricao,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 3,
                  onSaved: (v) => _descricao = v?.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _prioridade,
                  decoration: const InputDecoration(labelText: 'Prioridade'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Baixa')),
                    DropdownMenuItem(value: 2, child: Text('Média')),
                    DropdownMenuItem(value: 3, child: Text('Alta')),
                  ],
                  onChanged: (v) => setState(() => _prioridade = v ?? 1),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _prefixoEmpresa,
                  decoration: const InputDecoration(
                    labelText: 'Prefixo Empresa',
                  ),
                  onSaved: (v) => _prefixoEmpresa = v?.trim(),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _save, child: const Text('Salvar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
