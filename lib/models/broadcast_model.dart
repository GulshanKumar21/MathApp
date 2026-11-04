import 'dart:convert';

class AdminBroadcastModel {
  final String id;
  final String title;
  final String body;
  final String target; // 'all', 'free', 'pro'
  final DateTime sentAt;

  String get targetAudience => target.isEmpty || target.toLowerCase() == 'all' ? 'All Students' : target;

  AdminBroadcastModel({
    required this.id,
    required this.title,
    required this.body,
    this.target = 'all',
    required this.sentAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'target': target,
        'sentAt': sentAt.toIso8601String(),
      };

  factory AdminBroadcastModel.fromMap(Map<String, dynamic> map) => AdminBroadcastModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        target: map['target'] ?? 'all',
        sentAt: DateTime.tryParse(map['sentAt'] ?? '') ?? DateTime.now(),
      );

  String toJson() => json.encode(toMap());
  factory AdminBroadcastModel.fromJson(String source) => AdminBroadcastModel.fromMap(json.decode(source));
}
