class ResetPasswordRequest {
  final String oldPassword;
  final String newPassword;

  ResetPasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}



