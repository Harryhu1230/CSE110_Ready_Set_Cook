import 'package:flutter/material.dart';
// Fast QR code reader plugin

class Barcode extends StatefulWidget {
  @override
  _BarcodeState createState() => _BarcodeState();
}

class _BarcodeState extends State<Barcode> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Barcode Page', style: TextStyle(fontSize: 12)));
  }
}
