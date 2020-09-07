import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(TodoListApp());
}

class TodoListApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TodoListPage());
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos;

  @override
  void initState() {
    _readTodos();
    super.initState();
  }

  @override
  void setState(fn){
    super.setState(fn);
    _writeTodos();
  }

  _readTodos() async{
    /* await Future.delayed(Duration(seconds: 5));
    _todos = [
      Todo('A'), 
      Todo('B'), 
      Todo('C')
    ]; */
    try{
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/todos.json');
      List json = jsonDecode(await file.readAsString());
      List<Todo> todos = [];
      for(var item in json){
        todos.add(Todo.fromJson(item));
      } 
      super.setState(() => _todos = todos);
    }catch(e){
      setState(() => _todos =[]);
    }
  }

  _writeTodos() async{
    try{
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/todos.json');
      String jsonText = jsonEncode(_todos);
      print(jsonText);
      await file.writeAsString(jsonText);   
    }catch(e){
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('no se pudo grabar el fichero'),
        )
      );
    }
  }

  _removeChecked(){
    List<Todo> pending = [];
    for(var todo in _todos){
      if(!todo.done) pending.add(todo);
    }
    setState(() {
      _todos = pending;
    });
  }


  _buildList(){
    if(_todos == null){
      return Center(child: CircularProgressIndicator(),);
    }
    return ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            setState(() {
              _todos[index].toggleDone();
            });
          },
          child: ListTile(
            leading: Checkbox(
              value: _todos[index].done,
              onChanged: (checked) {
                setState(() => _todos[index].done = checked);
              },
            ),
            title: Text(
              _todos[index].what,
              style: TextStyle(
                  decoration: (_todos[index].done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none)),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _removeChecked,
          )
        ],
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
            builder: (_) => NewTodoPage(),
            )
          ).then((value){
            setState(() {
              _todos.add(Todo(value));
            });
          });
        },
      ),
    );
  }
}

class NewTodoPage extends StatefulWidget {
  @override
  _NewTodoPageState createState() => _NewTodoPageState();
}

class _NewTodoPageState extends State<NewTodoPage> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Todo...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
              child: Text('Añade'),
            )
          ],
        ),
      ),
    );
  }
}

//min 9:48
class Todo {
  String what;
  bool done;
  Todo(this.what) : done = false;

  void toggleDone() => done = !done;

  Todo.fromJson(Map<String, dynamic> json)
    : what = json['what'],
      done = json['done'];

  Map<String, dynamic> toJson()=>{
    'what': what,
    'done': done,
  };
}
