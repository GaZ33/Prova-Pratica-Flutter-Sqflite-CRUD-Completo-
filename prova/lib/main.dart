import 'package:flutter/material.dart';
import 'package:prova/db/database_helper.dart';
import 'package:prova/screens/task_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o DB usando o RA fornecido
  await DatabaseHelper.initDB('47530');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Cadastro de Tarefas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TaskList(),
    );
  }
}
