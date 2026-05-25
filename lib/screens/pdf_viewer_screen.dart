import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfPath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(pdfPath);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D91),
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
      ),
      body: PdfPreview(
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,

        actionBarTheme: const PdfActionBarTheme(
          backgroundColor: Color(0xFF0A3D91),
          iconColor: Colors.white,
        ),

        build: (_) => file.readAsBytes(),
      ),
    );
  }
}