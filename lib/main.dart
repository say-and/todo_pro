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
  List<Map<String, dynamic>> noteFromDb = [];

  @override
  void initState() {
    refreshData();
    super.initState();
  }

  void refreshData() async {
    final data = await SQLHelper.readNotes();
    setState(() {
      noteFromDb = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ToDo List'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: noteFromDb.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text("${noteFromDb[index]['title']}"),
                      subtitle: Text("${noteFromDb[index]['note']}"),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  showForm(noteFromDb[index]['id']);
                                },
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () {
                                  deleteNote(noteFromDb[index]['id']);
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showForm(null),
          child: const Icon(Icons.add),
        ));
  }

  final title = TextEditingController();
  final note = TextEditingController();

  void showForm(int? id) async {
    if (id != null) {
      final existingNote = noteFromDb.firstWhere((note) => note['id'] == id);
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
                      decoration: const InputDecoration(
                          hintText: "Title", border: OutlineInputBorder())),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: note,
                    decoration: const InputDecoration(
                        hintText: "Enter notes", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (id == null) {
                        addNote(title.text, note.text);
                        title.clear();
                        note.clear();
                        Navigator.of(context).pop();
                      }
                      if (id != null) {
                        updateNote(id, title.text, note.text);
                        title.clear();
                        note.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(id == null ? 'ADD NOTE' : "UPDATE"),
                  ),
                ],
              ),
            ));
  }

  Future addNote(String title, String note) async {
    await SQLHelper.createNote(title, note);
    refreshData();
  }

  Future<void> updateNote(int id, String title, String note) async {
    await SQLHelper.updateNote(id, title, note);
    refreshData();
  }

  void deleteNote(int id) async {
    await SQLHelper.deletenote(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Note Deleted")));
    refreshData();
  }
}
