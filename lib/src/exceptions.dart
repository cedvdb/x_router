class XRouterException implements Exception {
  final String description;
  XRouterException({
    required this.description,
  });

  @override
  String toString() => 'XRouterException(description: $description)';
}
