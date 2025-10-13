import 'package:pocketbase/pocketbase.dart';
import 'models/note_model.dart';

class PocketBaseService {
  final pb = PocketBase('http://127.0.0.1:8090');

  // 🔐 Auth
  Future<void> register(String email, String password) async {
    await pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
    });
  }

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  void logout() => pb.authStore.clear();
  bool get isLoggedIn => pb.authStore.isValid;
  String get userId => pb.authStore.model.id;

  // 📝 CRUD
  Future<List<NoteModel>> getNotes({String? query}) async {
    final filter = 'user="$userId"'
        '${query != null && query.isNotEmpty ? ' && (title~"$query" || content~"$query")' : ''}';
    final records = await pb.collection('notes').getFullList(
      filter: filter,
      sort: '-created',
    );
    return records.map((r) => NoteModel.fromRecord(r.toJson())).toList();
  }

  Future<NoteModel> createNote(String title, String content) async {
    final record = await pb.collection('notes').create(body: {
      'title': title,
      'content': content,
      'user': userId,
    });
    return NoteModel.fromRecord(record.toJson());
  }

  Future<void> updateNote(String id, String title, String content) async {
    await pb.collection('notes').update(id, body: {
      'title': title,
      'content': content,
    });
  }

  Future<void> deleteNote(String id) async {
    await pb.collection('notes').delete(id);
  }
}
