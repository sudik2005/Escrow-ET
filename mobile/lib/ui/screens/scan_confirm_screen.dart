import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanConfirmScreen extends StatefulWidget {
  const ScanConfirmScreen({super.key});

  @override
  State<ScanConfirmScreen> createState() => _ScanConfirmScreenState();
}

class _ScanConfirmScreenState extends State<ScanConfirmScreen> {
  var _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to verify'), centerTitle: true),
      body: MobileScanner(
        onDetect: (capture) {
          if (_done) {
            return;
          }
          final value = capture.barcodes.firstOrNull?.rawValue;
          if (value == null || value.isEmpty) {
            return;
          }
          _done = true;
          Navigator.of(context).pop(value);
        },
      ),
    );
  }
}
