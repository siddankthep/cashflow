import 'package:cashflow/entities/user.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:cashflow/model/providers/camera_provider.dart';
import 'package:cashflow/model/services/user_service.dart';
import 'package:cashflow/view/add_transaction_screen.dart';
import 'package:cashflow/view/scan_receipt_screen.dart';
import 'package:cashflow/view/spending_by_category_screen.dart';
import 'package:cashflow/view/view_all_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserService userService = UserService.fromEnv();
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = await userService.getUser(context, authProvider.jwtToken!);

    setState(() {
      _currentBalance = user.getBalance;
    });
  }

  Future<void> _setBudget(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final TextEditingController budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget'),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter Budget Amount',
            prefixText: '${authProvider.user?.getCurrency} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final budget = double.tryParse(budgetController.text);
              final token = authProvider.jwtToken;
              if (budget != null) {
                // Check if both budget and token are valid
                if (token != null) {
                  // Now 'token' is guaranteed non-null in this block
                  await userService.updateUserBalance(context, token, budget);
                }
                // if (authProvider.currentUser != null) {
                //   authProvider.updateUserBalance(budget);
                // }
                Navigator.pop(context);
                _loadBalance(); // Refresh balance after setting budget
              }
            },
            child: Text('Set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firstCamera =
        Provider.of<CameraProvider>(context, listen: false).firstCamera;
    final amountFormat =
        NumberFormat.currency(symbol: '${authProvider.user?.getCurrency} ');
    final formattedAmount = amountFormat.format(_currentBalance);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cashflow'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dashboard
              Container(
                width: 380,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Balance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      formattedAmount,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _setBudget(context),
                      icon: Icon(Icons.edit),
                      label: Text('Set Budget'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
                height: 20,
              ),
              // Original buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SpendingByCategoryScreen()));
                    print('Analyzing transactions!');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Spending Analysis",
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(1),
                      ),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      Icon(Icons.analytics_outlined),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                height: 20,
              ),
              // Scan receipt and View transactions buttons
              LayoutBuilder(
                builder: (context, constraints) {
                  final buttonWidth = (constraints.maxWidth - 20 - 32) / 2;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(buttonWidth, 150),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScanReceiptScreen(
                                        camera: firstCamera!)));
                            print('Scanning receipt');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Scan Receipt",
                                textAlign: TextAlign.center,
                                textScaler: TextScaler.linear(1),
                              ),
                              SizedBox(
                                height: 10,
                                width: 10,
                              ),
                              Icon(Icons.camera_alt),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(buttonWidth, 150),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewAllTransactionScreen()));
                            print('Viewing transactions');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "View Transactions",
                                textAlign: TextAlign.center,
                                textScaler: TextScaler.linear(1),
                              ),
                              SizedBox(
                                height: 10,
                                width: 10,
                              ),
                              Icon(Icons.list),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTransactionScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
