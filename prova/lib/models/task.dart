class Task {
  int? id;
  String titulo;
  String? descricao;
  int prioridade; // 1-baixa,2-media,3-alta
  DateTime criadoEm;
  String? campoExtra;
  String? ra;
  String? tema;
  String? corPrimaria; // hex string, ex: #FF0000
  String? corSecundaria;

  Task({
    this.id,
    required this.titulo,
    this.descricao,
    required this.prioridade,
    DateTime? criadoEm,
    this.campoExtra,
    this.ra,
    this.tema,
    this.corPrimaria,
    this.corSecundaria,
  }) : criadoEm = criadoEm ?? DateTime.now();

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'titulo': titulo,
      'descricao': descricao,
      'prioridade': prioridade,
      'criadoEm': criadoEm.toIso8601String(),
      'campoExtra': campoExtra,
      'ra': ra,
      'tema': tema,
      'corPrimaria': corPrimaria,
      'corSecundaria': corSecundaria,
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
      campoExtra: map['campoExtra'] as String?,
      ra: map['ra'] as String?,
      tema: map['tema'] as String?,
      corPrimaria: map['corPrimaria'] as String?,
      corSecundaria: map['corSecundaria'] as String?,
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
    return 'Task{id: $id, titulo: $titulo, prioridade: $prioridade, criadoEm: $criadoEm, campoExtra: $campoExtra}';
  }
}
