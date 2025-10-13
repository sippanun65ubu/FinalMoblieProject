import 'package:intl/intl.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String userId;
  final DateTime created;
  final DateTime updated;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.created,
    required this.updated,
  });

  factory NoteModel.fromRecord(Map<String, dynamic> record) {
    return NoteModel(
      id: record['id'] ?? '',
      title: record['title'] ?? '',
      content: record['content'] ?? '',
      userId: record['user'] ?? '',
      created: DateTime.parse(record['created']),
      updated: DateTime.parse(record['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'user': userId,
    };
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy, HH:mm').format(created);
}
