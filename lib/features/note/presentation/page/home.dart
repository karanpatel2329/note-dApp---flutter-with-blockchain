import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/model/note_model.dart';
import '../provider/note_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NoteService notesServices = NoteService();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  void EditNote(String id,String title,String desc){
    titleController.value=TextEditingValue(text: title);
    descriptionController.value=TextEditingValue(text: desc);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                notesServices.updateNote(id, titleController.text, descriptionController.text,);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void AddNote(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                notesServices.addNote(titleController.text, descriptionController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    List<Note> notes = Provider.of<NoteService>(context).notes;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Web3 with Flutter"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddNote();
        },
        child: const Icon(Icons.add),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: RefreshIndicator(
          onRefresh: () async {
            notesServices.fetchNotes();
          },
          child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(notes[index].title),
                  subtitle: Text(notes[index].description),
                  trailing: SizedBox(
                    height:50,
                    width:100,
                    child:Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            EditNote(notesServices.notes[index].id.toString(),
                                notesServices.notes[index].title.toString(),
                                notesServices.notes[index].description.toString());
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            notesServices.deleteNote(notesServices.notes[index].id.toString());
                          },
                        ),
                      ],
                    ),
                  )
              );
            },
          ),
        ),
      ),
    );
  }
}
