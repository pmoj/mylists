// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mylists/templates/estilos.dart';
import 'package:mylists/tarefa.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  List<Tarefa> tarefas = [];
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {
              showDialog(
                barrierColor: Colors.blue,
                context: context,
                builder: (context) => AlertDialog(
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      showCursor: true,
                      autofocus: true,
                      controller: _nomeController,
                      validator: (nome) {
                        if (nome == null || nome.isEmpty) {
                          return "Este campo é obrigatório.";
                        }
                        return null;
                      },
                      decoration:
                          InputDecoration(hintText: "Insira o nome da tarefa"),
                      onFieldSubmitted: (nome) => setState(() {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          _nomeController.clear();
                          return tarefas.add(Tarefa(nome: nome));
                        }
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: backGround(
          ReorderableListView.builder(
            proxyDecorator: proxyDecorator,
            itemCount: tarefas.length,
            itemBuilder: (BuildContext context, int index) {
              final tarefa = tarefas[index];
              return buildCard(index, tarefa);
            },
            padding: const EdgeInsets.all(8),
            onReorder: (int oldIndex, int newIndex) {
              if (newIndex > oldIndex) newIndex--;
              setState(() {
                var tarefa = tarefas[oldIndex];
                tarefas.removeAt(oldIndex);
                tarefas.insert(newIndex, tarefa);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildCard(int index, Tarefa tarefa) {
    return Card(
      key: ValueKey(tarefa),
      margin: const EdgeInsets.all(5),
      child: ListTile(
        // tileColor: _tile_color,
        key: ValueKey(tarefa),
        title: Text(tarefa.nome),
        onTap: () => Navigator.of(context).push(
          PageTransition(
              type: PageTransitionType.rightToLeftJoined,
              childCurrent: widget,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500),
              child: TelaTarefa(nome: tarefa.nome)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              onPressed: (() => editar(index)),
              icon: Icon(Icons.edit),
            ),
            IconButton(
              onPressed: (() => deletar(index)),
              icon: Icon(Icons.delete),
            )
          ],
        ),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0.0,
          color: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }

  void editar(int index) => showDialog(
        context: context,
        builder: ((context) {
          final tarefa = tarefas[index];
          return AlertDialog(
            content: Form(
              key: _editFormKey,
              child: TextFormField(
                autofocus: true,
                initialValue: tarefa.nome,
                validator: (nome) {
                  if (nome == null || nome.isEmpty) {
                    return "Este campo é obrigatório.";
                  }
                  return null;
                },
                onFieldSubmitted: (nome) => setState(() {
                  if (_editFormKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    tarefa.nome = nome;
                  }
                }),
              ),
            ),
          );
        }),
      );

  void deletar(int index) => setState(() {
        tarefas.removeAt(index);
      });
}
