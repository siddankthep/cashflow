import 'user.dart'; // Make sure this file contains your User model.
import 'category.dart'; // Optional, if you separated Category into its own file.

class Transaction {
  final String id;
  final User user;
  final Category? category;
  final double subtotal;
  final String? description;
  final DateTime transactionDate;
  final String? paymentMethod;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.user,
    this.category,
    required this.subtotal,
    this.description,
    required this.transactionDate,
    this.paymentMethod,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  String get getId => id;
  User get getUser => user;
  Category? get getCategory => category;
  double get getSubtotal => subtotal;
  String? get getDescription => description;
  DateTime get getTransactionDate => transactionDate;
  String? get getPaymentMethod => paymentMethod;
  String? get getLocation => location;
  DateTime get getCreatedAt => createdAt;
  DateTime get getUpdatedAt => updatedAt;

  /// Creates a Transaction instance from a JSON map.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      user: User.fromJson(json['user']),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      subtotal: json['subtotal'] is num
          ? (json['subtotal'] as num).toDouble()
          : double.parse(json['subtotal'].toString()),
      description: json['description'] as String?,
      // For LocalDate, we assume the API returns a date string (e.g., "2025-02-23")
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the Transaction instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user": user.toJson(),
      "category": category?.toJson(),
      "subtotal": subtotal,
      "description": description,
      // Optionally, if you want to send only the date portion:
      "transactionDate": transactionDate.toIso8601String().split('T')[0],
      "paymentMethod": paymentMethod,
      "location": location,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
