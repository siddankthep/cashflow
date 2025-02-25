import 'category.dart'; // Optional, if you separated Category into its own file.

class Transaction {
  final String? id;
  final String userId;
  final Category? category;
  final double subtotal;
  final String? description;
  final DateTime transactionDate;
  final String? paymentMethod;
  final String? location;

  Transaction({
    this.id,
    required this.userId,
    this.category,
    required this.subtotal,
    this.description,
    required this.transactionDate,
    this.paymentMethod,
    this.location,
  });

  String? get getId => id;
  String get getUserId => userId;
  Category? get getCategory => category;
  double get getSubtotal => subtotal;
  String? get getDescription => description;
  DateTime get getTransactionDate => transactionDate;
  String? get getPaymentMethod => paymentMethod;
  String? get getLocation => location;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '', // Provide a default if null
      userId: json['userId'] ?? '', // Provide a default if null
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      subtotal: json['subtotal'] is num
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      location: json['location'] as String?,
    );
  }

  /// Converts the Transaction instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "category": category?.toJson(),
      "subtotal": subtotal,
      "description": description,
      // Optionally, if you want to send only the date portion:
      "transactionDate": transactionDate.toIso8601String().split('T')[0],
      "paymentMethod": paymentMethod,
      "location": location,
    };
  }
}
