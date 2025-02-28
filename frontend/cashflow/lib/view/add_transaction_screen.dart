import 'package:cashflow/controller/new_transaction_controller.dart';
import 'package:cashflow/entities/category.dart';
import 'package:cashflow/entities/transaction.dart';
import 'package:cashflow/entities/user.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:cashflow/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewTransactionScreen extends StatefulWidget {
  final Transaction? scannedTransaction;

  const NewTransactionScreen({
    super.key,
    this.scannedTransaction,
  });

  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for user input
  final _subtotalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  Category? _selectedCategory;
  User? _user;
  String? _token;

  // Instantiate the controller.
  late NewTransactionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NewTransactionController();

    // Prepopulate fields if a scanned transaction is provided.
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

  @override
  void dispose() {
    _subtotalController.dispose();
    _descriptionController.dispose();
    _paymentMethodController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Opens a date picker and sets the selected date.
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

  /// Gathers the data from the form and delegates the save operation to the controller.
  void _saveTransaction() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
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

      try {
        await _controller.saveTransaction(_token, transaction);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
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
    // Get the authenticated user and token from the AuthProvider.
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
                            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
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
                // Category Dropdown loaded via the controller.
                FutureBuilder<List<Category>>(
                  future: _controller.fetchCategories(_token),
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
                      _selectedCategory = _controller.getCategoryFromDropDown(
                        categories: categories,
                        selectedCategory: _selectedCategory,
                        scannedTransaction: widget.scannedTransaction,
                      );
                      return DropdownButtonFormField<Category>(
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: categories.map((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon, color: category.color),
                                SizedBox(width: 8.0),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (Category? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
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
