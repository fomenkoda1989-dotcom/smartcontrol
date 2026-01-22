/// Data model for a receipt
class Receipt {
  final String id;
  final String store;
  final String date;
  final String total;
  final String uploadedAt;
  final int? itemCount;
  final List<ReceiptItem>? items;

  Receipt({
    required this.id,
    required this.store,
    required this.date,
    required this.total,
    required this.uploadedAt,
    this.itemCount,
    this.items,
  });

  /// Create Receipt from JSON (for list view - simplified data)
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      store: json['store'] as String,
      date: json['date'] as String,
      total: json['total'] as String,
      uploadedAt: json['uploaded_at'] as String,
      itemCount: json['item_count'] as int?,
      items: null, // Items not included in list response
    );
  }

  /// Create Receipt from JSON (for detail view - full data)
  factory Receipt.fromDetailJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Receipt(
      id: json['id'] as String,
      store: json['store'] as String,
      date: json['date'] as String,
      total: json['total'] as String,
      uploadedAt: json['uploaded_at'] as String,
      itemCount: items.length,
      items: items,
    );
  }
}

/// Data model for a single item on a receipt
class ReceiptItem {
  final String name;
  final String price;
  final String category;

  ReceiptItem({
    required this.name,
    required this.price,
    required this.category,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String,
      price: json['price'] as String,
      category: json['category'] as String,
    );
  }
}
