class PaginatedResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;
  final bool first;
  final bool last;

  PaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final List<dynamic> contentJson = json['content'] ?? [];
    return PaginatedResponse(
      content: contentJson.map((item) => fromJsonT(item)).toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      number: json['number'] ?? 0,
      size: json['size'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}
