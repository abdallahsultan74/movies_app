class DeleteProfileResponse {
  final String message;

  DeleteProfileResponse({
    required this.message,
  });

  factory DeleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteProfileResponse(
      message: json['message'] ?? '',
    );
  }
}

