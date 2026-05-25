import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/report_image_model.dart';
import '../models/report_model.dart';
import 'pdf_service.dart';

class ReportStorageService {
  final PdfService _pdfService = PdfService();

  Future<String> generateNextFolio() async {
    final now = DateTime.now();

    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.year}';

    final reports = await getReports();

    final todayReports = reports.where((report) {
      return report.folio.endsWith(formattedDate);
    }).toList();

    int maxConsecutive = 0;

    for (final report in todayReports) {
      final parts = report.folio.split('-');

      if (parts.length >= 3) {
        final consecutive = int.tryParse(parts[1]) ?? 0;

        if (consecutive > maxConsecutive) {
          maxConsecutive = consecutive;
        }
      }
    }

    final nextConsecutive = maxConsecutive + 1;

    final formattedConsecutive =
    nextConsecutive.toString().padLeft(4, '0');

    return 'REP-$formattedConsecutive-$formattedDate';
  }

  Future<ReportModel> signReport({
    required ReportModel report,
    required List<int> signatureBytes,
  }) async {
    final baseDir =
    await getApplicationDocumentsDirectory();

    final reportDir = Directory(
      p.join(
        baseDir.path,
        'FieldReportingSystem',
        'reports',
        report.folio,
      ),
    );

    await reportDir.create(recursive: true);

    final signaturePath = p.join(
      reportDir.path,
      '${report.folio}_signature.png',
    );

    final signatureFile = File(signaturePath);

    await signatureFile.writeAsBytes(signatureBytes);

    final updatedReport = ReportModel(
      id: report.id,
      folio: report.folio,
      stationName: report.stationName,
      location: report.location,
      observations: report.observations,
      reportDate: report.reportDate,
      formStatus: report.formStatus,
      syncStatus: report.syncStatus,
      pdfPath: report.pdfPath,
      signaturePath: signaturePath,
      createdAt: report.createdAt,
      syncedAt: report.syncedAt,
      images: report.images,
    );

    final regeneratedPdfPath =
    await _pdfService.generateReportPdf(
      report: updatedReport,
      reportDirectory: reportDir,
    );

    final finalReport = ReportModel(
      id: updatedReport.id,
      folio: updatedReport.folio,
      stationName: updatedReport.stationName,
      location: updatedReport.location,
      observations: updatedReport.observations,
      reportDate: updatedReport.reportDate,
      formStatus: updatedReport.formStatus,
      syncStatus: updatedReport.syncStatus,
      pdfPath: regeneratedPdfPath,
      signaturePath: updatedReport.signaturePath,
      createdAt: updatedReport.createdAt,
      syncedAt: updatedReport.syncedAt,
      images: updatedReport.images,
    );

    final reportJsonFile = File(
      p.join(
        reportDir.path,
        'report.json',
      ),
    );

    await reportJsonFile.writeAsString(
      const JsonEncoder.withIndent(' ')
          .convert(finalReport.toJson()),
    );

    return finalReport;
  }

  Future<ReportModel> saveReport({
    required String folio,
    required String stationName,
    required String location,
    required String observations,
    required List<XFile> images,
  }) async {
    final now = DateTime.now();

    final reportId =
    now.microsecondsSinceEpoch.toString();

    final baseDir =
    await getApplicationDocumentsDirectory();

    final reportsDir = Directory(
      p.join(
        baseDir.path,
        'FieldReportingSystem',
        'reports',
      ),
    );

    final reportDir = Directory(
      p.join(
        reportsDir.path,
        folio,
      ),
    );

    final imagesDir = Directory(
      p.join(
        reportDir.path,
        'images',
      ),
    );

    await imagesDir.create(recursive: true);

    final savedImages = <ReportImageModel>[];

    for (int i = 0; i < images.length; i++) {
      final sourceImage = File(images[i].path);

      final extension =
      p.extension(images[i].path).isEmpty
          ? '.jpg'
          : p.extension(images[i].path);

      final imageNumber =
      (i + 1).toString().padLeft(3, '0');

      final formattedDate =
          '${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}'
          '_'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}'
          '${now.second.toString().padLeft(2, '0')}';

      final fileName =
          '${folio}_${formattedDate}_IMG_$imageNumber$extension';

      final destinationPath = p.join(
        imagesDir.path,
        fileName,
      );

      final destinationFile =
      File(destinationPath);

      if (sourceImage.path !=
          destinationFile.path) {
        await sourceImage.copy(destinationPath);
      }

      savedImages.add(
        ReportImageModel(
          id: '${reportId}_IMG_$imageNumber',
          reportId: reportId,
          fileName: fileName,
          filePath: destinationPath,
          createdAt: now,
        ),
      );
    }

    ReportModel report = ReportModel(
      id: reportId,
      folio: folio,
      stationName: stationName,
      location: location,
      observations: observations,
      reportDate: now,

      /// PDF generado y listo para enviarse.
      formStatus: 'READY_FOR_SYNC',

      /// Pendiente de subir al servidor.
      syncStatus: 'PENDING_SYNC',

      pdfPath: null,
      signaturePath: null,
      createdAt: now,
      syncedAt: null,
      images: savedImages,
    );

    final pdfPath =
    await _pdfService.generateReportPdf(
      report: report,
      reportDirectory: reportDir,
    );

    report = ReportModel(
      id: report.id,
      folio: report.folio,
      stationName: report.stationName,
      location: report.location,
      observations: report.observations,
      reportDate: report.reportDate,
      formStatus: report.formStatus,
      syncStatus: report.syncStatus,
      pdfPath: pdfPath,
      signaturePath: report.signaturePath,
      createdAt: report.createdAt,
      syncedAt: report.syncedAt,
      images: report.images,
    );

    final reportJsonFile = File(
      p.join(
        reportDir.path,
        'report.json',
      ),
    );

    await reportJsonFile.writeAsString(
      const JsonEncoder.withIndent(' ')
          .convert(report.toJson()),
    );

    return report;
  }

  Future<List<ReportModel>> getReports() async {
    try {
      final baseDir =
      await getApplicationDocumentsDirectory();

      final reportsDir = Directory(
        p.join(
          baseDir.path,
          'FieldReportingSystem',
          'reports',
        ),
      );

      if (!await reportsDir.exists()) {
        return [];
      }

      final reportFolders =
      reportsDir
          .listSync()
          .whereType<Directory>()
          .toList();

      final reports = <ReportModel>[];

      for (final folder in reportFolders) {
        final reportJsonFile = File(
          p.join(
            folder.path,
            'report.json',
          ),
        );

        if (await reportJsonFile.exists()) {
          final jsonString =
          await reportJsonFile.readAsString();

          final jsonMap =
          jsonDecode(jsonString);

          final report =
          ReportModel.fromJson(jsonMap);

          reports.add(report);
        }
      }

      reports.sort(
            (a, b) =>
            b.createdAt.compareTo(a.createdAt),
      );

      return reports;
    } catch (error) {
      throw Exception(
        'Error al obtener reportes: $error',
      );
    }
  }
}