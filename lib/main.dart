import 'package:flutter/material.dart';
import 'helperclass.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Sqflite(),
  ));
}

class Sqflite extends StatefulWidget {
  @override
  State<Sqflite> createState() => _SqfliteState();
}

class _SqfliteState extends State<Sqflite> {
  bool isLoading = true;
  List<Map<String, dynamic>> note_from_db = [];

  @override
  void initState() {
    refreshData();
    super.initState();
  }

  void refreshData() async {
    final datas = await SQLHelper.readNotes();
    setState(() {
      note_from_db = datas;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ToDo List'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: note_from_db.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text("${note_from_db[index]['title']}"),
                      subtitle: Text("${note_from_db[index]['note']}"),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  showForm(note_from_db[index]['id']);
                                },
                                icon: Icon(Icons.edit)),
                            IconButton(
                                onPressed: () {
                                  deleteNote(note_from_db[index]['id']);
                                },
                                icon: Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showForm(null),
          child: Icon(Icons.add),
        ));
  }

  final title = TextEditingController();
  final note = TextEditingController();

  void showForm(int? id) async {
    if (id != null) {
      final existingNote = note_from_db.firstWhere((note) => note['id'] == id);
      title.text = existingNote['title'];
      note.text = existingNote['note'];
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
              padding: EdgeInsets.only(
                  left: 10,
                  top: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                      controller: title,
                      decoration: InputDecoration(
                          hintText: "Title", border: OutlineInputBorder())),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: note,
                    decoration: InputDecoration(
                        hintText: "Enter notes", border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await addNote();
                      }
                      if (id != null) {
                        await updateNote(id);
                        title.text = "";
                        note.text = "";
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(id == null ? 'ADD NOTE' : "UPDATE"),
                  ),
                ],
              ),
            ));
  }

  Future addNote() async {
    await SQLHelper.createNote(title.text, note.text);
    refreshData();
  }

  Future<void> updateNote(int id) async {
    await SQLHelper.updateNote(id, title.text, note.text);
    refreshData();
  }

  void deleteNote(int id) async {
    await SQLHelper.deletenote(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Note Deleted")));
    refreshData();
  }
}
