import 'package:pocketbase/pocketbase.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String color;
  final DateTime created;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.created,
  });

  factory Note.fromRecord(RecordModel record) {
    return Note(
      id: record.id,
      title: record.data['title'] ?? '',
      content: record.data['content'] ?? '',
      color: record.data['color'] ?? '#FFFFFF',
      created: DateTime.parse(record.created),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'color': color,
    };
  }
}
