class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int avatarId;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarId,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarId': avatarId,
      'token': token,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarId: json['avatarId'] ?? json['avaterId'] ?? 1,
      token: json['token'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? avatarId,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarId: avatarId ?? this.avatarId,
      token: token ?? this.token,
    );
  }
}

