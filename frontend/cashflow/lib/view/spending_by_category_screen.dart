import 'package:cashflow/entities/transaction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cashflow/model/services/transaction_service.dart';

class SpendingByCategoryScreen extends StatefulWidget {
  @override
  _SpendingByCategoryScreenState createState() => _SpendingByCategoryScreenState();
}

class _SpendingByCategoryScreenState extends State<SpendingByCategoryScreen> {
  TransactionService _transactionService = TransactionService.fromEnv();
  Map<String, double> spendingData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpendingData();
  }

  Future<void> _fetchSpendingData() async {
    try {
      // Fetch transactions
      List<Transaction> transactions = await _transactionService.getAllTransactions(context);

      // Aggregate spending by category
      final tempSpendingData = <String, double>{};
      for (var transaction in transactions) {
        final categoryName = transaction.category!.name;
        final amount = transaction.subtotal;
        tempSpendingData[categoryName] = (tempSpendingData[categoryName] ?? 0) + amount;
      }

      setState(() {
        spendingData = tempSpendingData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load spending data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spending by Category'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : spendingData.isEmpty
              ? Center(child: Text('No spending data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildLegend(),
                    ],
                  ),
                ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    int colorIndex = 0;

    final totalSpending = spendingData.values.reduce((a, b) => a + b);

    return spendingData.entries.map((entry) {
      final categoryName = entry.key;
      final value = entry.value;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${(value / totalSpending * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: spendingData.entries.map((entry) {
        final categoryName = entry.key;
        final amount = entry.value;
        final colorIndex = spendingData.keys.toList().indexOf(categoryName);
        final color = [
          Colors.blue,
          Colors.green,
          Colors.red,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.teal,
        ][colorIndex % 7];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: color,
            ),
            SizedBox(width: 8),
            Text(
              '$categoryName: \$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      }).toList(),
    );
  }
}