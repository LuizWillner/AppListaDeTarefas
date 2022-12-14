final String tableTarefasName = 'tarefas';

class TarefaFields {
  static final String id = '_id';
  static final String name = 'name';

  static final List<String> fields = [id, name];
}

class Tarefa {
  final int? id;
  final String name;

  const Tarefa({
    this.id,
    required this.name
  });

  Tarefa copy({
    int? id,
    String? name
  }) => Tarefa(id: id ?? this.id, name: name ?? this.name);

  Map<String, Object?> toJson() => {
    TarefaFields.id: id,
    TarefaFields.name: name
  };

  static Tarefa fromJson(Map<String, Object?> json) => Tarefa(
    id: json[TarefaFields.id] as int?,
    name: json[TarefaFields.name] as String
  );
}
