import 'package:cashflow/entities/category.dart';
import 'package:cashflow/entities/transaction.dart';
import 'package:cashflow/entities/user.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:cashflow/model/services/category_service.dart';
import 'package:cashflow/model/services/transaction_service.dart';
import 'package:cashflow/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewTransactionScreen extends StatefulWidget {
  final Transaction? scannedTransaction;

  const NewTransactionScreen({
    Key? key,
    this.scannedTransaction,
  }) : super(key: key);

  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
  final _subtotalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  Category? _selectedCategory;
  User? _user;
  String? _token;

  // Example static categories. In a real app, you might fetch these from an API.

  @override
  void initState() {
    super.initState();
    // If a Transaction object is provided, prepopulate the form fields.
    if (widget.scannedTransaction != null) {
      _subtotalController.text = widget.scannedTransaction!.subtotal.toString();
      _descriptionController.text =
          widget.scannedTransaction!.description ?? '';
      _paymentMethodController.text =
          widget.scannedTransaction!.paymentMethod ?? '';
      _locationController.text = widget.scannedTransaction!.location ?? '';
      _selectedDate = widget.scannedTransaction!.transactionDate;
    }
  }

  Category? getCategoryFromDropDown(List<Category> categories) {
    if (_selectedCategory == null &&
        widget.scannedTransaction?.category != null) {
      final Category scannedCat = widget.scannedTransaction!.category!;
      print('Scanned Category: ${scannedCat.toString()}');
      final index = categories.indexWhere((c) => c.name == scannedCat.name);
      print('Index of category: $index');
      if (index != -1) {
        return categories[index];
      } else {
        categories.add(scannedCat);
      }
      return scannedCat;
    }
    return null;
  }

  @override
  void dispose() {
    _subtotalController.dispose();
    _descriptionController.dispose();
    _paymentMethodController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      // Create a new Transaction. Note that we leave the id empty (to be generated later).
      final transaction = Transaction(
        id: '',
        userId: _user!.id,
        category: _selectedCategory,
        subtotal: double.parse(_subtotalController.text),
        description: _descriptionController.text,
        transactionDate: _selectedDate!,
        paymentMethod: _paymentMethodController.text,
        location: _locationController.text,
      );

      // For now, simply print the JSON representation.
      print('New Transaction: ${transaction.toJson()}');
      try {
        _transactionService.saveTransaction(_token, transaction);
        // Navigate back to HomeScreen after successful save
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        // Handle error during save
        print('Error saving transaction: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a transaction date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = authProvider.user;
    _token = authProvider.jwtToken;
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subtotal input
                TextFormField(
                  controller: _subtotalController,
                  decoration: const InputDecoration(labelText: 'Subtotal'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subtotal';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                // Description input
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16.0),
                // Transaction Date picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No Date Chosen!'
                            : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Choose Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Payment Method input
                TextFormField(
                  controller: _paymentMethodController,
                  decoration:
                      const InputDecoration(labelText: 'Payment Method'),
                ),
                const SizedBox(height: 16.0),
                // Location input
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 16.0),
                // Category Dropdown
                FutureBuilder<List<Category>>(
                  future: CategoryService().getAllCategories(_token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error loading categories: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    } else {
                      final categories = snapshot.data ?? [];

                      // If there's a scanned transaction and _selectedCategory is null,
                      // find the matching instance from the fetched categories.
                      _selectedCategory = getCategoryFromDropDown(categories);

                      return DropdownButtonFormField<Category>(
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: categories.map((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (Category? newValue) {
                          setState(() {
                            print('Selected Category: $newValue');
                            _selectedCategory =
                                getCategoryFromDropDown(categories);
                          });
                        },
                        value: _selectedCategory,
                      );
                    }
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
