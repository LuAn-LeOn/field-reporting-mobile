import 'dart:io';

import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/report_storage_service.dart';
import 'new_report_screen.dart';
import 'pdf_viewer_screen.dart';
import 'signature_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  bool get _canEdit => report.formStatus == 'DRAFT';

  bool get _hasPdf =>
      report.pdfPath != null &&
          report.pdfPath!.trim().isNotEmpty &&
          File(report.pdfPath!).existsSync();

  bool get _hasSignature =>
      report.signaturePath != null &&
          report.signaturePath!.trim().isNotEmpty &&
          File(report.signaturePath!).existsSync();

  void _openPdf(BuildContext context) {
    if (!_hasPdf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este reporte todavía no tiene PDF generado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          pdfPath: report.pdfPath!,
          title: report.folio,
        ),
      ),
    );
  }

  Future<void> _signReport(BuildContext context) async {
    final signatureBytes = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (_) => const SignatureScreen(),
      ),
    );

    if (signatureBytes == null || signatureBytes.isEmpty) {
      return;
    }

    try {
      final storageService = ReportStorageService();

      final updatedReport = await storageService.signReport(
        report: report,
        signatureBytes: signatureBytes,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF firmado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(
            report: updatedReport,
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al firmar PDF: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: Text(report.folio),
        centerTitle: true,
        actions: [
          if (_canEdit)
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewReportScreen(
                      reportToEdit: report,
                    ),
                  ),
                );

                Navigator.pop(context);
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: 'Información general',
              children: [
                _infoRow('Folio', report.folio),
                _infoRow('Estación', report.stationName),
                _infoRow(
                  'Ubicación',
                  report.location.isEmpty
                      ? 'Sin ubicación'
                      : report.location,
                ),
                _infoRow(
                  'Fecha',
                  '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}',
                ),
                _infoRow(
                  'Estado formulario',
                  report.formStatus,
                ),
                _infoRow(
                  'Estado sincronización',
                  report.syncStatus,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Observaciones',
              children: [
                Text(
                  report.observations,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Evidencias (${report.images.length})',
              children: [
                if (report.images.isEmpty)
                  Text(
                    'Sin evidencias fotográficas',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: report.images.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final image = report.images[index];

                      return ClipRRect(
                        borderRadius:
                        BorderRadius.circular(12),
                        child: Image.file(
                          File(image.filePath),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Documento PDF',
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: _hasPdf
                          ? Colors.red
                          : Colors.grey,
                      size: 34,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasPdf
                                ? '${report.folio}.pdf'
                                : 'PDF no generado',
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _hasSignature
                                ? 'PDF firmado'
                                : 'Pendiente de firma',
                            style: TextStyle(
                              color: _hasSignature
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF0A3D91),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _hasPdf
                        ? () => _openPdf(context)
                        : null,
                    icon: const Icon(Icons.visibility),
                    label: const Text(
                      'Ver PDF',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasSignature
                          ? Colors.green
                          : const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _signReport(context),
                    icon: Icon(
                      _hasSignature
                          ? Icons.check
                          : Icons.draw,
                    ),
                    label: Text(
                      _hasSignature
                          ? 'Re-firmar PDF'
                          : 'Firmar PDF',
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}