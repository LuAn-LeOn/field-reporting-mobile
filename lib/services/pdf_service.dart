import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/report_model.dart';

class PdfService {
  Future<String> generateReportPdf({
    required ReportModel report,
    required Directory reportDirectory,
  }) async {
    final pdf = pw.Document();

    final evidenceImages = <pw.MemoryImage>[];

    for (final image in report.images) {
      final file = File(image.filePath);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        evidenceImages.add(pw.MemoryImage(bytes));
      }
    }

    pw.MemoryImage? signatureImage;

    if (report.signaturePath != null && report.signaturePath!.isNotEmpty) {
      final signatureFile = File(report.signaturePath!);

      if (await signatureFile.exists()) {
        final bytes = await signatureFile.readAsBytes();
        signatureImage = pw.MemoryImage(bytes);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 18),
            _buildMainContent(report, evidenceImages),
            pw.SizedBox(height: 20),
            _buildFooter(signatureImage),
          ];
        },
      ),
    );

    final pdfPath = p.join(
      reportDirectory.path,
      '${report.folio}.pdf',
    );

    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfPath;
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  width: 44,
                  height: 44,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#0A3D91'),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'SR',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SISTEMA DE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0A3D91'),
                      ),
                    ),
                    pw.Text(
                      'REPORTES DE CAMPO',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0A3D91'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Text(
              'REPORTE DE CAMPO',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0A3D91'),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 2,
          color: PdfColor.fromHex('#0A3D91'),
        ),
      ],
    );
  }

  pw.Widget _buildMainContent(
      ReportModel report,
      List<pw.MemoryImage> evidenceImages,
      ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _infoRow('Folio:', report.folio),
              _infoRow(
                'Fecha del reporte:',
                '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}',
              ),
              _infoRow('Nombre de la estación:', report.stationName),
              _infoRow(
                'Ubicación:',
                report.location.isEmpty ? 'Sin ubicación' : report.location,
              ),
              pw.SizedBox(height: 18),
              pw.Container(
                height: 1,
                color: PdfColor.fromHex('#D9E2F3'),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'OBSERVACIONES',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0A3D91'),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                report.observations,
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Container(
          width: 1,
          height: 260,
          color: PdfColor.fromHex('#D9E2F3'),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'EVIDENCIAS FOTOGRÁFICAS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0A3D91'),
                ),
              ),
              pw.SizedBox(height: 10),
              _buildEvidenceGrid(evidenceImages),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildEvidenceGrid(List<pw.MemoryImage> images) {
    if (images.isEmpty) {
      return pw.Text(
        'Sin evidencias fotográficas',
        style: const pw.TextStyle(fontSize: 10),
      );
    }

    final visibleImages = images.take(4).toList();

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: visibleImages.map((image) {
        return pw.Container(
          width: 115,
          height: 80,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(
              color: PdfColor.fromHex('#D9E2F3'),
            ),
          ),
          child: pw.ClipRRect(
            horizontalRadius: 8,
            verticalRadius: 8,
            child: pw.Image(
              image,
              fit: pw.BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildFooter(pw.MemoryImage? signatureImage) {
    return pw.Column(
      children: [
        pw.Container(
          height: 1,
          color: PdfColor.fromHex('#0A3D91'),
        ),
        pw.SizedBox(height: 18),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Elaboró:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Luis Angel De Los Santos León',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Inspector de Campo',
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            pw.Column(
              children: [
                pw.Container(
                  width: 150,
                  height: 40,
                  alignment: pw.Alignment.center,
                  child: signatureImage != null
                      ? pw.Image(
                    signatureImage,
                    fit: pw.BoxFit.contain,
                  )
                      : pw.SizedBox(),
                ),
                pw.Container(
                  width: 150,
                  height: 1,
                  color: PdfColors.grey600,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Firma',
                  style: const pw.TextStyle(
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            pw.Text(
              'Página 1 de 1',
              style: const pw.TextStyle(
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}