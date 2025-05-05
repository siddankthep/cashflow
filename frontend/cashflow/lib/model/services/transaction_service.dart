import 'dart:convert';
import 'package:cashflow/entities/transaction.dart';
import 'package:http/http.dart' as http;
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionService {
  final String baseUrl;

  // Constructor that takes the baseUrl
  TransactionService({required this.baseUrl});

  // Factory constructor that loads the URL from environment variables
  factory TransactionService.fromEnv() {
    return TransactionService(
      baseUrl: '${dotenv.env['API_BASE_URL']}/transactions',
    );
  }

  Future<List<Transaction>> getAllTransaction(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.jwtToken}',
      },
    );

    int status = response.statusCode;
    print('Status Code: $status');
    print('Token: ${authProvider.jwtToken}');
    print('Response: ${response.body}');
    if (status == 200) {
      print("Successfully retrieved transactions");
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Transaction> transactions = [];
      for (var item in body) {
        transactions.add(Transaction.fromJson(item));
      }
      return transactions.reversed.toList();
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<bool> saveTransaction(String? token, Transaction transaction) async {
    print('Token: $token');
    final response = await http.post(
      Uri.parse('$baseUrl/save'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(transaction.toJson()),
    );

    int status = response.statusCode;
    print('Status Code: $status');
    print('Response: ${response.body}');
    if (status == 200) {
      print("Successfully saved transaction");
      return true;
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to save transaction');
    }
  }
}
