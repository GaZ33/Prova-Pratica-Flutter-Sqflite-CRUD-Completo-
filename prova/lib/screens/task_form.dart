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
  String? _campoExtra;
  String? _ra;
  String? _tema;
  String? _corPrimaria;
  String? _corSecundaria;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _titulo = t.titulo;
      _descricao = t.descricao;
      _prioridade = t.prioridade;
      _campoExtra = t.campoExtra;
      _ra = t.ra ?? DatabaseHelper.getAppRa();
      _tema = t.tema;
      _corPrimaria = t.corPrimaria;
      _corSecundaria = t.corSecundaria;
    } else {
      _titulo = '';
      _ra = DatabaseHelper.getAppRa();
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
        campoExtra: _campoExtra,
        ra: _ra,
        tema: _tema,
        corPrimaria: _corPrimaria,
        corSecundaria: _corSecundaria,
      );
      await DatabaseHelper.insertTask(t);
    } else {
      final t = Task(
        id: widget.task!.id,
        titulo: _titulo,
        descricao: _descricao,
        prioridade: _prioridade,
        criadoEm: widget.task!.criadoEm,
        campoExtra: _campoExtra,
        ra: _ra,
        tema: _tema,
        corPrimaria: _corPrimaria,
        corSecundaria: _corSecundaria,
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
                  initialValue: _campoExtra,
                  decoration: const InputDecoration(
                    labelText: 'Campo Extra (personalizado)',
                  ),
                  onSaved: (v) => _campoExtra = v?.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _ra,
                  decoration: const InputDecoration(labelText: 'RA'),
                  onSaved: (v) => _ra = v?.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _tema,
                  decoration: const InputDecoration(
                    labelText: 'Tema (nome/descrição)',
                  ),
                  onSaved: (v) => _tema = v?.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _corPrimaria,
                  decoration: const InputDecoration(
                    labelText: 'Cor Primária (hex, ex: #3366FF)',
                  ),
                  onSaved: (v) => _corPrimaria = v?.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _corSecundaria,
                  decoration: const InputDecoration(
                    labelText: 'Cor Secundária (hex)',
                  ),
                  onSaved: (v) => _corSecundaria = v?.trim(),
                ),
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
