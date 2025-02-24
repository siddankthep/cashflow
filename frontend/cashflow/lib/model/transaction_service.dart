import 'dart:convert';
import 'package:cashflow/entities/transaction.dart';
import 'package:http/http.dart' as http;
import 'package:cashflow/model/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class TransactionService {
  final String baseUrl = 'http://10.0.2.2:8080/transactions';

  Future<List<Transaction>> getAllTransaction(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${authProvider.jwtToken}',
      },
    );

    int status = response.statusCode;
    print('Status Code: $status');
    print('Token: ${authProvider.jwtToken}');
    print('Response: ${response.body}');
    if (status == 200) {
      print("Successfully retrieved transactions");
      final body = jsonDecode(response.body);
      List<Transaction> transactions = [];
      for (var item in body) {
        transactions.add(Transaction.fromJson(item));
      }
      return transactions;
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }
}
