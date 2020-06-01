import 'package:flutter/material.dart';
import '../model/todo_item.dart';
import '../util/DatabaseHelper.dart';
import '../util/date_formatter.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final _textEditingController = new TextEditingController();

  var db = new DatabaseHelper();

  final List<ToDoItem> _itemList = <ToDoItem>[];

  @override
  void initState() {
    super.initState();
    _readToDoList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.black87,
        body: Column(
          children: <Widget>[
            new Flexible(
                child: new ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    reverse: false,
                    itemCount: _itemList.length,
                    itemBuilder: (_, int index) {
                      return Card(
                        color: Colors.white10,
                        child: new ListTile(
                          title: _itemList[index],
                          onLongPress: () =>
                              _updateItem(_itemList[index], index),
                          trailing: new Listener(
                            // key: new Key(_itemList[index].itemName),
                            child: new Icon(
                              Icons.remove_circle,
                              color: Colors.redAccent,
                            ),
                            onPointerDown: (pointerEvent) =>
                                _deleteToDoItem(_itemList[index].id, index),
                          ),
                        ),
                      );
                    })),
            new Divider(
              height: 1.0,
            )
          ],
        ),
        floatingActionButton: new FloatingActionButton(
            tooltip: "Add Item",
            backgroundColor: Colors.redAccent,
            child: new ListTile(title: new Icon(Icons.add)),
            onPressed: _showFormDialog));
  }

  void _handleSubmit(String txt) async {
    _textEditingController.clear();

    // ToDoItem item = ToDoItem(txt, DateTime.now().toIso8601String());
    ToDoItem item = ToDoItem(txt, dateFormatted());
    int savedItemId = await db.saveItem(item);
    // print("Item saved : $savedItemId");

    ToDoItem addedItem = await db.getToDoItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });
  }

  void _showFormDialog() {
    _textEditingController.text = "";
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          Expanded(
            child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "e.g Buy Milk",
                  icon: new Icon(Icons.note_add),
                )),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Save")),
        new FlatButton(
            onPressed: () {
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancel"))
      ],
    );

    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readToDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      // ToDoItem toDoItem = ToDoItem.map(item);
      // print("$toDoItem.itemName");
      setState(() {
        _itemList.add(ToDoItem.map(item));
      });
    });
  }

  _deleteToDoItem(int id, int index) async {
    await db.deleteToDoItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _updateItem(ToDoItem item, index) async {
    _textEditingController.text = item.itemName;
    var alert = new AlertDialog(
      title: new Text("Update Item"),
      content: new Row(
        children: <Widget>[
          Expanded(
              child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Item",
              hintText: "e.g Buy Milk",
              icon: new Icon(Icons.update),
            ),
          ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async {
              ToDoItem newUpdated = ToDoItem.fromMap({
                "itemName": _textEditingController.text,
                "dateCreated": dateFormatted(),
                "id": item.id
              });

              _handleSubmitUpdate(index, item);
              await db.updateToDoItem(newUpdated);
              setState(() {
                _readToDoList();
              });
              Navigator.pop(context);
            },
            child: new Text("Update")),
        new FlatButton(
            onPressed: () => Navigator.pop(context), child: new Text("Cancel")),
      ],
    );

    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _handleSubmitUpdate(int index, ToDoItem item) {
    setState(() {
      // _itemList.removeAt(index);//DOESN'T WORK
      _itemList.removeWhere((element) {
        _itemList[index].id == item.id;
      });
    });
  }
}
