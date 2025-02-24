import 'package:cashflow/model/user_service.dart';
import 'package:cashflow/view/view_transaction_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cashflow'),
      ),
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(150, 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => Placeholder()));
              print('Scanning receipt');
            },
            // child: Text('Scan Receipt', textAlign: TextAlign.center),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Scan Receipt",
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(0.8),
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
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(150, 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewTransactionScreen()));
              print('Viewing transactions');
            },
            // child: Text('Scan Receipt', textAlign: TextAlign.center),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "View Transactions",
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(0.8),
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
      )),
    );
  }
}
