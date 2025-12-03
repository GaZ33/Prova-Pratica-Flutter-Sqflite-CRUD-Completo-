class Task {
  int? id;
  String titulo;
  String? descricao;
  int prioridade; // 1-baixa,2-media,3-alta
  DateTime criadoEm;
  String? prefixoEmpresa;

  Task({
    this.id,
    required this.titulo,
    this.descricao,
    required this.prioridade,
    DateTime? criadoEm,
    this.prefixoEmpresa,
  }) : criadoEm = criadoEm ?? DateTime.now();

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'titulo': titulo,
      'descricao': descricao,
      'prioridade': prioridade,
      'criadoEm': criadoEm.toIso8601String(),
      'prefixoEmpresa': prefixoEmpresa,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String?,
      prioridade: map['prioridade'] as int,
      criadoEm: DateTime.parse(map['criadoEm'] as String),
      prefixoEmpresa: map['prefixoEmpresa'] as String?,
    );
  }

  String? validateTitulo() {
    if (titulo.trim().isEmpty) return 'Título obrigatório.';
    if (titulo.trim().length < 3) {
      return 'Título deve ter ao menos 3 caracteres.';
    }
    return null;
  }

  @override
  String toString() {
    return 'Task{id: $id, titulo: $titulo, prioridade: $prioridade, criadoEm: $criadoEm, prefixoEmpresa: $prefixoEmpresa}';
  }
}
