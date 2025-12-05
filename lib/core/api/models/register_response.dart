class RegisterResponse {
  final String message;
  final RegisterData? data;

  RegisterResponse({
    required this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

class RegisterData {
  final String email;
  final String password;
  final String name;
  final String phone;
  final int avaterId;
  final String id;
  final String createdAt;
  final String updatedAt;
  final int v;

  RegisterData({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.avaterId,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avaterId: json['avaterId'] ?? 0,
      id: json['_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}



