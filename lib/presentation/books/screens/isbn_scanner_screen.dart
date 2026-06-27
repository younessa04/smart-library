import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';

class IsbnScannerScreen extends StatefulWidget {
  const IsbnScannerScreen({super.key});
  @override
  State<IsbnScannerScreen> createState() => _IsbnScannerScreenState();
}

class _IsbnScannerScreenState extends State<IsbnScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        final value = barcode.rawValue!;
        // ISBN barcodes are typically 10 or 13 digits
        if (RegExp(r'^\d{10,13}$').hasMatch(value)) {
          _scanned = true;
          Navigator.pop(context, value);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner ISBN')),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 150),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.barcode_reader, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Placez le code-barres ISBN dans le cadre',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
