import 'package:flutter/material.dart';
import 'pocketbase_service.dart';
import 'models/note_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pbService = PocketBaseService();
  List<NoteModel> notes = [];
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final searchController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchNotes();
    searchController.addListener(onSearch);
  }

  Future<void> fetchNotes({String? query}) async {
    setState(() => loading = true);
    final data = await pbService.getNotes(query: query);
    setState(() {
      notes = data;
      loading = false;
    });
  }

  void onSearch() {
    fetchNotes(query: searchController.text);
  }

  void showNoteDialog({NoteModel? note}) {
    titleController.text = note?.title ?? '';
    contentController.text = note?.content ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (note == null) {
                await pbService.createNote(titleController.text, contentController.text);
              } else {
                await pbService.updateNote(note.id, titleController.text, contentController.text);
              }
              Navigator.pop(context);
              fetchNotes();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void logout() {
    pbService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // 🔍 ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // 📝 รายการโน้ต
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                    ? const Center(child: Text('No notes found'))
                    : ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                  Text(
                                    "🕒 ${note.formattedDate}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => showNoteDialog(note: note)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () async {
                                    await pbService.deleteNote(note.id);
                                    fetchNotes();
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
