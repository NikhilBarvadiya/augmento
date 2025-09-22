class APIResponse {
  final bool success;
  final dynamic message;
  final dynamic data;
  final int? status;

  APIResponse({required this.success, this.message, this.data, this.status});

  factory APIResponse.fromJson(Map<String, dynamic> json) {
    return APIResponse(success: json['success'] ?? false, message: json['message'], data: json['data'], status: json['status']);
  }
}
