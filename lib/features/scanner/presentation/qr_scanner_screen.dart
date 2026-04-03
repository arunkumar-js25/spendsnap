import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:spendsnap/core/utils/upi_parser.dart';
import 'package:spendsnap/features/expense/presentation/screens/add_expense_screen.dart';
import 'package:spendsnap/data/db/database.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          if (isScanned) return; // ✅ prevent multiple calls

          final barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            final code = barcode.rawValue;
             if (code != null && !isScanned) {
              isScanned = true;

              final data = parseUpi(code);

              final amount = double.tryParse(data["amount"] ?? "0") ?? 0;
              final note = data["note"] ?? "";
              final category = detectCategory(note);

              // ✅ SHOW MESSAGE HERE
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("QR detected! Review and save")),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(
                    db: AppDatabase(),
                    prefilledAmount: amount,
                    prefilledDesc: note,
                    prefilledCategory: category,
                  ),
                ),
              ).then((value) {
                Navigator.pop(context, value); // return to Home
              });
            }          
          }
        },
      ),
    );
  }
}