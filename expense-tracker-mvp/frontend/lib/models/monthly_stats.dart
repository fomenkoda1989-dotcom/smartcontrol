/// Data model for monthly spending statistics
class MonthlyStats {
  final int month;
  final int year;
  final double totalSpent;
  final int receiptCount;
  final List<CategorySpending> categories;

  MonthlyStats({
    required this.month,
    required this.year,
    required this.totalSpent,
    required this.receiptCount,
    required this.categories,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    final categoriesList = json['categories'] as List<dynamic>? ?? [];
    final categories = categoriesList
        .map((cat) => CategorySpending.fromJson(cat as Map<String, dynamic>))
        .toList();

    return MonthlyStats(
      month: json['month'] as int,
      year: json['year'] as int,
      totalSpent: (json['total_spent'] as num).toDouble(),
      receiptCount: json['receipt_count'] as int,
      categories: categories,
    );
  }

  /// Get month name (e.g., "January")
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

/// Data model for spending in a specific category
class CategorySpending {
  final String category;
  final double amount;

  CategorySpending({
    required this.category,
    required this.amount,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  /// Get display name for category (capitalize first letter)
  String get displayName {
    if (category.isEmpty) return 'Other';
    return category[0].toUpperCase() + category.substring(1);
  }
}
