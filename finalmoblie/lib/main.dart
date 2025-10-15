import 'package:flutter/material.dart';
import 'models/note_model.dart';
import 'pocketbase_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PocketBase Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const NotePage(),
    );
  }
}

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  bool isLoading = false;

  final List<Color> availableColors = [
    Colors.amber.shade100,
    Colors.pink.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    setState(() => isLoading = true);
    final data = await getNotes();
    setState(() {
      notes = data;
      filteredNotes = data;
      isLoading = false;
    });
  }

  void searchNotes(String query) {
    setState(() {
      filteredNotes = notes
          .where((n) =>
              n.title.toLowerCase().contains(query.toLowerCase()) ||
              n.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // 🧠 Convert Hex to Color
  Color parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xff')));
    } catch (_) {
      return Colors.grey.shade100;
    }
  }

  // 📝 BottomSheet สำหรับสร้าง / แก้ไข Note พร้อมเลือกสี
  void showNoteDialog({Note? note}) {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');
    String selectedColor =
        note?.color ?? '#${availableColors.first.value.toRadixString(16).substring(2)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note == null ? '📝 New Note' : '✏️ Edit Note',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
                const Divider(),
                TextField(
                  controller: contentCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Write your note...',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 20),
                // 🎨 ตัวเลือกสี
                Wrap(
                  spacing: 10,
                  children: availableColors.map((color) {
                    final hex = '#${color.value.toRadixString(16).substring(2)}';
                    final isSelected = selectedColor == hex;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = hex),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: isSelected ? 20 : 18,
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (note == null) {
                          await createNote(
                              titleCtrl.text, contentCtrl.text, selectedColor);
                        } else {
                          await updateNote(note.id, titleCtrl.text,
                              contentCtrl.text, selectedColor);
                        }
                        Navigator.pop(context);
                        fetchNotes();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PocketBase Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: searchNotes,
              decoration: InputDecoration(
                hintText: '🔍 Search notes...',
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchNotes,
                    child: filteredNotes.isEmpty
                        ? const Center(
                            child: Text('No notes found.',
                                style: TextStyle(color: Colors.grey)),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: StaggeredGrid.count(
                              crossAxisCount:
                                  MediaQuery.of(context).size.width > 600 ? 3 : 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              children: filteredNotes.map((n) {
                                final bg = parseColor(n.color);
                                return GestureDetector(
                                  onTap: () => showNoteDialog(note: n),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                n.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                await deleteNote(n.id);
                                                fetchNotes();
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          n.content,
                                          style:
                                              const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showNoteDialog(),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
