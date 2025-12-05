class LoginResponse {
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dataMap;
    
    if (json['data'] != null && json['data'] is Map) {
      dataMap = json['data'] as Map<String, dynamic>;
    } else if (json.containsKey('token') || json.containsKey('_id')) {
      dataMap = {
        'token': json['token'],
        '_id': json['_id'] ?? json['id'],
        'name': json['name'],
        'email': json['email'],
        'phone': json['phone'],
        'avaterId': json['avaterId'] ?? json['avatarId'],
      };
    }
    
    return LoginResponse(
      message: json['message'] ?? '',
      data: dataMap != null ? LoginData.fromJson(dataMap) : null,
    );
  }
}

class LoginData {
  final String? token;
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final int? avaterId;

  LoginData({
    this.token,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avaterId,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? json['Token'],
      id: json['id'] ?? json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avaterId: json['avaterId'] ?? json['avatarId'],
    );
  }
}



