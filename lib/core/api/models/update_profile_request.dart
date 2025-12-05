class UpdateProfileRequest {
  final String? email;
  final int? avaterId;
  final String? name;
  final String? phone;

  UpdateProfileRequest({
    this.email,
    this.avaterId,
    this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (email != null) json['email'] = email;
    if (avaterId != null) json['avaterId'] = avaterId;
    if (name != null) json['name'] = name;
    if (phone != null) json['phone'] = phone;
    return json;
  }
}

