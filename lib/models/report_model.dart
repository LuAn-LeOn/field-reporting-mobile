import 'report_image_model.dart';

class ReportModel {
  final String id;
  final String folio;
  final String stationName;
  final String location;
  final String observations;
  final DateTime reportDate;

  /// Estado funcional del reporte:
  /// DRAFT          = Editable localmente
  /// READY_FOR_SYNC = PDF generado y listo para enviar
  /// LOCKED         = Enviado al servidor, no editable
  /// ARCHIVED       = Histórico
  final String formStatus;

  /// Estado de sincronización:
  /// LOCAL_ONLY    = Solo existe localmente
  /// PENDING_SYNC  = Esperando sincronización
  /// SYNCING       = Enviándose
  /// SYNCED        = Confirmado por servidor
  /// SYNC_ERROR    = Error al enviar
  /// LOCAL_DELETED = Archivos locales eliminados tras sincronizar
  final String syncStatus;

  final String? pdfPath;

  /// Ruta local de la firma capturada como imagen PNG.
  final String? signaturePath;

  final DateTime createdAt;
  final DateTime? syncedAt;
  final List<ReportImageModel> images;

  ReportModel({
    required this.id,
    required this.folio,
    required this.stationName,
    required this.location,
    required this.observations,
    required this.reportDate,
    required this.formStatus,
    required this.syncStatus,
    this.pdfPath,
    this.signaturePath,
    required this.createdAt,
    this.syncedAt,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folio': folio,
      'stationName': stationName,
      'location': location,
      'observations': observations,
      'reportDate': reportDate.toIso8601String(),
      'formStatus': formStatus,
      'syncStatus': syncStatus,
      'pdfPath': pdfPath,
      'signaturePath': signaturePath,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'images': images.map((image) => image.toJson()).toList(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      folio: json['folio'],
      stationName: json['stationName'],
      location: json['location'],
      observations: json['observations'],
      reportDate: DateTime.parse(json['reportDate']),
      formStatus: json['formStatus'] ?? 'DRAFT',
      syncStatus: json['syncStatus'] ?? 'LOCAL_ONLY',
      pdfPath: json['pdfPath'],
      signaturePath: json['signaturePath'],
      createdAt: DateTime.parse(json['createdAt']),
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'])
          : null,
      images: (json['images'] as List<dynamic>)
          .map((image) => ReportImageModel.fromJson(image))
          .toList(),
    );
  }
}