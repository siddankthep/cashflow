import 'package:cashflow/entities/category.dart';
import 'package:cashflow/entities/transaction.dart';
import 'package:cashflow/model/services/category_service.dart';
import 'package:cashflow/model/services/transaction_service.dart';

class NewTransactionController {
  final TransactionService _transactionService = TransactionService.fromEnv();
  final CategoryService _categoryService = CategoryService.fromEnv();

  /// Fetches all categories using the CategoryService.
  Future<List<Category>> fetchCategories(String? token) async {
    return await _categoryService.getAllCategories(token);
  }

  /// Saves the given [transaction] using the TransactionService.
  Future<bool> saveTransaction(String? token, Transaction transaction) async {
    return await _transactionService.saveTransaction(token, transaction);
  }

  /// Determines the appropriate category based on the scanned transaction.
  Category? getCategoryFromDropDown({
    required List<Category> categories,
    Category? selectedCategory,
    Transaction? scannedTransaction,
  }) {
    if (selectedCategory == null && scannedTransaction?.category != null) {
      final Category scannedCat = scannedTransaction!.category!;
      final index = categories.indexWhere((c) => c.name == scannedCat.name);
      if (index != -1) {
        return categories[index];
      } else {
        categories.add(scannedCat);
      }
      return scannedCat;
    }
    return selectedCategory;
  }
}
