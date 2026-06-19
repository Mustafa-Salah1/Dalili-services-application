class ProviderAvailabilityModel {
  final bool busy;
  final String? customerName;
  final int? requestId;
  final int remainingMinutes;

  ProviderAvailabilityModel({
    required this.busy,
    this.customerName,
    this.requestId,
    required this.remainingMinutes,
  });

  factory ProviderAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return ProviderAvailabilityModel(
      busy: json['busy'] ?? false,
      customerName: json['customerName'],
      requestId: json['requestId'],
      remainingMinutes: json['remainingMinutes'] ?? 0,
    );
  }
}
