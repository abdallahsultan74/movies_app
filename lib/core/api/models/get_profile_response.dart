class GetProfileResponse {
  final String message;
  final ProfileData? data;

  GetProfileResponse({
    required this.message,
    this.data,
  });

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) {
    return GetProfileResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }
}

class ProfileData {
  final String id;
  final String email;
  final String password;
  final String name;
  final String phone;
  final int avaterId;
  final String createdAt;
  final String updatedAt;
  final int v;

  ProfileData({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.avaterId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avaterId: json['avaterId'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

