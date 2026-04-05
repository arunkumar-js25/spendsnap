import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spendsnap/data/db/database.dart';
import 'package:url_launcher/url_launcher.dart';

class AddExpenseScreen extends StatefulWidget {
  final AppDatabase db;
  final double? prefilledAmount;
  final String? prefilledDesc;
  final String? prefilledCategory;
  final String? upiUri;

  const AddExpenseScreen({
    super.key,
    required this.db,
    this.prefilledAmount,
    this.prefilledDesc,
    this.prefilledCategory,
    this.upiUri,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _uriController = TextEditingController();

  String category = 'Food';
  String type = 'Cash';
  String finalUpi = '';

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

    if (widget.upiUri != null) {
      _uriController.text = widget.upiUri!;
    }
  }

  void _saveExpense() async {
    final desc = _descController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;

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

    Navigator.pop(context, true);
  }

  Future<void> _payViaUPI() async {
    if (widget.upiUri == null) return;

    final desc = _descController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;

    //final uri = Uri.parse(widget.upiUri!);

    final raw = Uri.parse(widget.upiUri!);

    final pa = raw.queryParameters['pa'] ?? '';
    final pn = raw.queryParameters['pn'] ?? '';
    final am = raw.queryParameters['am'] ?? amount.toString(); // optional
    final tn = raw.queryParameters['tn'] ?? desc;
    final aid = raw.queryParameters['aid'] ?? '';
    final cu = raw.queryParameters['cu'] ?? 'INR';

    final uri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': pa,
        'pn': pn,
        'cu': cu,
        if (am != null && am.isNotEmpty) 'am': am,
        if (tn != null && tn.isNotEmpty) 'tn': tn,
        if (aid != null && aid.isNotEmpty) 'aid': aid
      },
    );

    finalUpi = uri.toString();

    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No UPI app found")),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Status"),
        content: const Text("Did the payment complete?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveExpense(); // Save expense on successful payment
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  Future<void> _payViaUPIDirect() async {
    if (widget.upiUri == null) return;

    final uri = Uri.parse(widget.upiUri!);

    finalUpi = uri.toString();

    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No UPI app found")),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Status"),
        content: const Text("Did the payment complete?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveExpense(); // Save expense on successful payment
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: SingleChildScrollView( // ✅ FIX overflow
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
            const SizedBox(height: 10),

            TextField(
              controller: _uriController,
              decoration: const InputDecoration(labelText: "URI"),
            ),
            const SizedBox(height: 10),

            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: [
                'Food',
                'Travel',
                'Shopping',
                'Bills',
                'Entertainment',
                'Medicine',
                'Investment',
                'Others'
              ]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text("Save"),
            ),

            const SizedBox(height: 10),

            // ✅ Show only if QR-based
            if (widget.upiUri != null)
              ElevatedButton(
                onPressed: _payViaUPI,
                child: const Text("Pay via UPI"),
              ),

              const SizedBox(height: 10),

            // ✅ Show only if QR-based
            /*if (widget.upiUri != null)
              ElevatedButton(
                onPressed: _payViaUPIDirect,
                child: const Text("Pay via UPI Direct"),
              ),*/
          ],          
        ),
      ),
    );
  }
}