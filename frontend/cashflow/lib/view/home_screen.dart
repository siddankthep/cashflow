import 'package:cashflow/model/providers/camera_provider.dart';
import 'package:cashflow/model/services/user_service.dart';
import 'package:cashflow/view/scan_receipt_screen.dart';
import 'package:cashflow/view/view_all_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserService userService = UserService.fromEnv();

  @override
  Widget build(BuildContext context) {
    final firstCamera =
        Provider.of<CameraProvider>(context, listen: false).firstCamera;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cashflow'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(200, 150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ScanReceiptScreen(camera: firstCamera!)));
              print('Scanning receipt');
            },
            // child: Text('Scan Receipt', textAlign: TextAlign.center),
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
              fixedSize: Size(200, 150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewAllTransactionScreen()));
              print('Viewing transactions');
            },
            // child: Text('Scan Receipt', textAlign: TextAlign.center),
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
      )),
    );
  }
}
