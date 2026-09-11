/// DTO representing API health check and dataset version provenance.
class HealthCheckDto {
  final String status;
  final String? version;
  final String? datasetVersion;

  const HealthCheckDto({
    required this.status,
    this.version,
    this.datasetVersion,
  });

  factory HealthCheckDto.fromJson(Map<String, dynamic> json) {
    return HealthCheckDto(
      status: json['status'] as String? ?? 'ok',
      version: json['version'] as String?,
      datasetVersion: json['dataset_version'] as String? ?? json['source_version'] as String?,
    );
  }
}
