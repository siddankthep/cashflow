import 'package:cashflow/entities/transaction.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ViewTransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const ViewTransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Format the date nicely
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final formattedDate = dateFormat.format(transaction.transactionDate);

    // Format the amount with currency
    final amountFormat =
        NumberFormat.currency(symbol: '${authProvider.user?.getCurrency} ');
    final formattedAmount = amountFormat.format(transaction.subtotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount card with category
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (transaction.category != null) ...[
                          Icon(
                            transaction.category!.icon,
                            color: transaction.category!.color,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          formattedAmount,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.category?.name ?? 'Uncategorized',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Transaction details
            const Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),

            // Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(formattedDate),
            ),

            // Description
            if (transaction.description != null &&
                transaction.description!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Description'),
                subtitle: Text(transaction.description!),
              ),

            // Payment method
            if (transaction.paymentMethod != null &&
                transaction.paymentMethod!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payment Method'),
                subtitle: Text(transaction.paymentMethod!),
              ),

            // Location
            if (transaction.location != null &&
                transaction.location!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location'),
                subtitle: Text(transaction.location!),
              ),

            // Transaction ID
            ListTile(
              leading: const Icon(Icons.tag),
              title: const Text('Transaction ID'),
              subtitle: Text(transaction.id ?? 'Not assigned'),
            ),

            const SizedBox(height: 24),

            // Edit and Delete buttons
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     ElevatedButton.icon(
            //       onPressed: () {
            //         // Navigate to edit transaction screen
            //         // Navigator.push(context, MaterialPageRoute(
            //         //   builder: (context) => EditTransactionScreen(transaction: transaction)
            //         // ));
            //       },
            //       icon: const Icon(Icons.edit),
            //       label: const Text('Edit'),
            //       style: ElevatedButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 24, vertical: 12),
            //       ),
            //     ),
            //     OutlinedButton.icon(
            //       onPressed: () {
            //         // Show confirmation dialog
            //         showDialog(
            //           context: context,
            //           builder: (ctx) => AlertDialog(
            //             title: const Text('Delete Transaction'),
            //             content: const Text(
            //                 'Are you sure you want to delete this transaction?'),
            //             actions: [
            //               TextButton(
            //                 onPressed: () => Navigator.of(ctx).pop(),
            //                 child: const Text('Cancel'),
            //               ),
            //               TextButton(
            //                 onPressed: () {
            //                   // Delete the transaction
            //                   // TransactionService().deleteTransaction(transaction.id);
            //                   Navigator.of(ctx).pop();
            //                   Navigator.of(context).pop();
            //                 },
            //                 child: const Text('Delete',
            //                     style: TextStyle(color: Colors.red)),
            //               ),
            //             ],
            //           ),
            //         );
            //       },
            //       icon: const Icon(Icons.delete, color: Colors.red),
            //       label:
            //           const Text('Delete', style: TextStyle(color: Colors.red)),
            //       style: OutlinedButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 24, vertical: 12),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
