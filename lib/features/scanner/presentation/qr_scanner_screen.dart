import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:spendsnap/core/utils/upi_parser.dart';
import 'package:spendsnap/features/expense/presentation/screens/add_expense_screen.dart';
import 'package:spendsnap/data/db/database.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'dart:io';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false;

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final inputImage = mlkit.InputImage.fromFile(File(image.path));

    final barcodeScanner = mlkit.BarcodeScanner();

    final barcodes = await barcodeScanner.processImage(inputImage);

    for (mlkit.Barcode barcode in barcodes) {
      final String? code = barcode.rawValue;

      if (code != null) {
        // ✅ Parse UPI QR
        final data = parseUpi(code);
        final amount = double.tryParse(data["amount"] ?? "0") ?? 0;
        final note = data["note"] ?? "";
        final category = detectCategory(note);

        // ✅ Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR detected! Review and save")),
        );

        // ✅ Navigate to Add Expense Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddExpenseScreen(
              db: AppDatabase(),
              prefilledAmount: amount,
              prefilledDesc: note,
              prefilledCategory: category,
              upiUri: code, // 🔥 pass UPI for payment later
            ),
          ),
        ).then((value) {
          // ✅ Return to home after saving
          Navigator.pop(context, value);
        });
        break;
      }
    }

   /* ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gallery scan coming soon 🚀")),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) async {
          if (isScanned) return;

          final barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            final code = barcode.rawValue;

            if (code != null && !isScanned) {
              isScanned = true;

              // ✅ Parse UPI QR
              final data = parseUpi(code);

              final amount = double.tryParse(data["amount"] ?? "0") ?? 0;
              final note = data["note"] ?? "";
              final category = detectCategory(note);

              // ✅ Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("QR detected! Review and save")),
              );

              // ✅ Navigate to Add Expense Screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(
                    db: AppDatabase(),
                    prefilledAmount: amount,
                    prefilledDesc: note,
                    prefilledCategory: category,
                    upiUri: code, // 🔥 pass UPI for payment later
                  ),
                ),
              );/*.then((value) {
                // ✅ Return to home after saving
                Navigator.pop(context, value);
              });*/

              break; // ✅ stop loop after first scan
            }
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "scan from files",
            onPressed: _scanFromGallery,
            child: const Icon(Icons.folder),
          ),
        ],
      ),
    );
  }
}
