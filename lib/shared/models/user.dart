import 'package:flutter/foundation.dart';

@immutable
class TatoUser {
  final String id;
  final String email;
  final String? name;

  const TatoUser({
    required this.id,
    required this.email,
    this.name,
  });

  TatoUser copyWith({
    String? id,
    String? email,
    String? name,
  }) {
    return TatoUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  factory TatoUser.fromJson(Map<String, dynamic> json) {
    return TatoUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TatoUser && other.id == id && other.email == email && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;
}
