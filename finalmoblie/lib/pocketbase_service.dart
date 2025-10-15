import 'package:pocketbase/pocketbase.dart';
import 'models/note_model.dart';

final pb = PocketBase('http://127.0.0.1:8090');

Future<List<Note>> getNotes() async {
  final records = await pb.collection('notes').getFullList(sort: '-created');
  return records.map((r) => Note.fromRecord(r)).toList();
}

Future<void> createNote(String title, String content, String color) async {
  await pb.collection('notes').create(body: {
    'title': title,
    'content': content,
    'color': color,
  });
}

Future<void> updateNote(String id, String title, String content, String color) async {
  await pb.collection('notes').update(id, body: {
    'title': title,
    'content': content,
    'color': color,
  });
}

Future<void> deleteNote(String id) async {
  await pb.collection('notes').delete(id);
}
