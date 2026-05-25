class ReportImageModel {
  final String id;
  final String reportId;
  final String fileName;
  final String filePath;
  final DateTime createdAt;

  ReportImageModel({
    required this.id,
    required this.reportId,
    required this.fileName,
    required this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'fileName': fileName,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportImageModel.fromJson(Map<String, dynamic> json) {
    return ReportImageModel(
      id: json['id'],
      reportId: json['reportId'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}