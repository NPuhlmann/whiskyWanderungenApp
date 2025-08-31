import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) => 
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.data.toString() == data.toString() &&
        other.isRead == isRead &&
        other.createdAt.millisecondsSinceEpoch == createdAt.millisecondsSinceEpoch;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, body, type, data.toString(), isRead, createdAt.millisecondsSinceEpoch);
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, data: $data, isRead: $isRead, createdAt: $createdAt)';
  }
}

enum NotificationType {
  orderUpdate,
  deliveryUpdate,
  general,
}
