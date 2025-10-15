import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() async {
  final faker = Faker();
  final colors = [
    "#FFF9C4",
    "#F8BBD0",
    "#C8E6C9",
    "#BBDEFB",
    "#FFE0B2",
    "#E1BEE7",
    "#B2EBF2",
  ];
  const baseUrl = 'http://127.0.0.1:8090/api/collections/notes/records';
  final random = Random();

  for (var i = 0; i < 10; i++) {
    final note = {
      'title': faker.lorem.sentence(),
      'content': faker.lorem.sentences(3).join(' '),
      'color': colors[random.nextInt(colors.length)],
    };

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note),
    );

    if (res.statusCode == 200) {
      print("✅ Created note ${i + 1}");
    } else {
      print("❌ Error: ${res.body}");
    }
  }
}
