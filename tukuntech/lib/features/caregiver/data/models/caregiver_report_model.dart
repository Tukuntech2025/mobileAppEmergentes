class CaregiverReportModel {
  final String reportId;
  final String patientId;
  final String startDate;
  final String endDate;
  final String status;
  final DateTime generatedAt;
  final int? avgHeartRate;
  final int? minHeartRate;
  final int? maxHeartRate;
  final int? avgSpO2;
  final double? avgTemperature;

  CaregiverReportModel({
    required this.reportId,
    required this.patientId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.generatedAt,
    this.avgHeartRate,
    this.minHeartRate,
    this.maxHeartRate,
    this.avgSpO2,
    this.avgTemperature,
  });

  factory CaregiverReportModel.fromJson(Map<String, dynamic> json) {
    return CaregiverReportModel(
      reportId: json['reportId'] ?? '',
      patientId: json['patientId'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
      avgHeartRate: json['avgHeartRate'] != null ? (json['avgHeartRate'] as num).toInt() : null,
      minHeartRate: json['minHeartRate'] != null ? (json['minHeartRate'] as num).toInt() : null,
      maxHeartRate: json['maxHeartRate'] != null ? (json['maxHeartRate'] as num).toInt() : null,
      avgSpO2: json['avgSpO2'] != null ? (json['avgSpO2'] as num).toInt() : null,
      avgTemperature: json['avgTemperature'] != null ? (json['avgTemperature'] as num).toDouble() : null,
    );
  }
}
