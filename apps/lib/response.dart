class Response {
  final dynamic content;
  final String message;

  const Response({
    required this.content,
    required this.message,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      content: json['content'] as dynamic,
      message: json['message'] as String,
    );
  }
}
