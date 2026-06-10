class PaginatedChatResult<T> {
  final List<T> content;
  final int currentPage;
  final int? totalPages;
  final int? totalElements;
  final int pageSize;

  const PaginatedChatResult({
    required this.content,
    required this.currentPage,
    this.totalPages,
    this.totalElements,
    this.pageSize = 10,
  });

  bool hasMore({int? loadedCount}) {
    if (totalPages != null && totalPages! > 0) {
      return currentPage + 1 < totalPages!;
    }
    if (totalElements != null && loadedCount != null) {
      return loadedCount < totalElements!;
    }
    return content.length >= pageSize;
  }
}
