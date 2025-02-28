import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:cashflow/model/services/transaction_service.dart';
import 'package:cashflow/view/add_transaction_screen.dart';
import 'package:cashflow/view/view_transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewAllTransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: FutureBuilder(
        future: TransactionService().getAllTransaction(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewTransactionDetailScreen(
                              transaction: snapshot.data![index],
                            ),
                          ),
                        ),
                        tileColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.black12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        leading: Icon(snapshot.data?[index].getCategory?.icon,
                            color: snapshot.data?[index].getCategory?.color),
                        title: Text(
                          snapshot.data?[index].getCategory?.name ??
                              'No category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${snapshot.data![index].getSubtotal.toString()} ${authProvider.user?.getCurrency}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
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
