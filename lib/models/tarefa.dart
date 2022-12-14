final String tableTarefasName = 'tarefas';

class TarefaFields {
  static final String id = '_id';
  static final String name = 'name';
  static final String isDone = 'isDone';

  static final List<String> fields = [id, name, isDone];
}

class Tarefa {
  final int? id;
  final String name;
  final bool isDone;

  const Tarefa({
    this.id,
    required this.name,
    required this.isDone
  });

  Tarefa copy({
    int? id,
    String? name,
    bool? isDone,
  }) => Tarefa(
      id: id ?? this.id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone
  );

  Map<String, Object?> toJson() => {
    TarefaFields.id: id,
    TarefaFields.name: name,
    TarefaFields.isDone: isDone ? 1 : 0,
  };

  static Tarefa fromJson(Map<String, Object?> json) => Tarefa(
    id: json[TarefaFields.id] as int?,
    name: json[TarefaFields.name] as String,
    isDone: json[TarefaFields.isDone] == 1,
  );

  void printTarefa() {
    print('Tarefa $id: $name, feita? $isDone');
  }
}
