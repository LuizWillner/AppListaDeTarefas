import 'dart:io';
import "dart:async";
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:lista_tarefas_completo_app/db/tarefas_database.dart';
import 'package:lista_tarefas_completo_app/models/tarefa.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  TextEditingController _controllerCreateTarefa = TextEditingController();
  TextEditingController _controllerEditTarefa = TextEditingController();

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    print("Path: ${dir.path}");
    print("dir = ${dir.absolute}");

    return File("${dir.path}/data.json");
  }

  Future refreshTarefas() async {
    _listaTarefas = await TarefaDB.instance.readAll();
  }

  _saveTarefa() {
    String taskStr = _controllerCreateTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = taskStr;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _saveFile();

    _controllerCreateTarefa.text = "";
  }

  _createTarefaOnDB() async {
    Tarefa tarefa = Tarefa(
        name: _controllerCreateTarefa.text,
        isDone: false
    );
    await TarefaDB.instance.create(tarefa);

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _controllerCreateTarefa.text = "";
  }

  _saveFile() async {
    final file = await _getFile();
    String data = jsonEncode(_listaTarefas);
    file.writeAsString(data);
  }

  _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget listItemCreate(BuildContext context, int index) {
    // final item = _listaTarefas[index].name +
    //     _listaTarefas[index].isDone.toString();
    // var _lastRemovedTask;

    final tarefa = _listaTarefas[index];

    return Dismissible(
        key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
        confirmDismiss: (DismissDirection direction) async {
          switch (direction) {
            case DismissDirection.endToStart:
              return await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Tem certeza que deseja remover a tarefa?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Não")),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _listaTarefas.removeAt(index);
                              });
                              _saveFile();
                              Navigator.pop(context);
                            },
                            child: Text("Sim")),
                      ],
                    );
                  });
            case DismissDirection.startToEnd:
              return await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Editar Tarefa"),
                      content: TextField(
                          controller: _controllerEditTarefa .. text = _listaTarefas[index]["titulo"],
                          onChanged: (text) {}),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancelar")),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _listaTarefas[index]["titulo"] = _controllerEditTarefa.text;
                              });
                              _saveFile();
                              Navigator.pop(context);
                            },
                            child: Text("Salvar")),
                      ],
                    );
                  });
            default:
              break;
          }
          return true;
        },
        background: Container(
          color: Colors.green,
          padding: EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
              Icons.edit,
              color: Colors.white,
            )
          ]),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ]),
        ),
        child: CheckboxListTile(
          title: Text(tarefa.name),
          value: tarefa.isDone,
          onChanged: (newVal) {
            setState(() {
              tarefa.isDone = newVal;
            });
            // _saveFile();
            // update()
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    refreshTarefas();
  }

  @override
  Widget build(BuildContext context) {
    print("_listaTarefas = " + _listaTarefas.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                      controller: _controllerCreateTarefa,
                      decoration:
                          InputDecoration(labelText: "Digite sua tarefa"),
                      onChanged: (text) {}),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancelar")),
                    TextButton(
                        onPressed: () {
                          // _saveTarefa();
                          _createTarefaOnDB();
                          Navigator.pop(context);
                        },
                        child: Text("Salvar")),
                  ],
                );
              });
        },
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaTarefas.length, itemBuilder: listItemCreate))
        ]),
      ),
    );
  }
}
