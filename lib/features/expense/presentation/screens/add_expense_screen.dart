import 'package:flutter/material.dart';
import 'package:spendsnap/data/db/database.dart';

class AddExpenseScreen extends StatefulWidget {
  final AppDatabase db;
  final double? prefilledAmount;
  final String? prefilledDesc;
  final String? prefilledCategory;
  
  const AddExpenseScreen({
    super.key,
    required this.db,
    this.prefilledAmount,
    this.prefilledDesc,
    this.prefilledCategory,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.prefilledAmount != null) {
      _amountController.text = widget.prefilledAmount.toString();
    }

    if (widget.prefilledDesc != null) {
      _descController.text = widget.prefilledDesc!;
    }

    if (widget.prefilledCategory != null) {
      category = widget.prefilledCategory!;
    }
  }
  
  String category = 'Food';
  String type = 'Cash';

  void _saveExpense() async {
    final desc = _descController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;

    //if (desc.isEmpty || amount == 0) return;
    if (desc.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid details")),
      );
      return;
    }

    await widget.db.insertExpense(
      ExpensesCompanion.insert(
        description: desc,
        category: category,
        amount: amount,
        type: type,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            DropdownButton<String>(
              value: category,
              items: ['Food', 'Travel', 'Shopping','Bills', 'Entertainment','Medicine','Investment', 'Others']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}