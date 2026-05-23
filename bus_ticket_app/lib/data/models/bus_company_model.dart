class BusCompanyModel {
  final String busCompanyName;
  final String busCompanyId;
  final double rating;

  BusCompanyModel({
    required this.busCompanyName,
    required this.busCompanyId,
    required this.rating,
  });

  factory BusCompanyModel.fromJson(Map<String, dynamic> json) {
    return BusCompanyModel(
      busCompanyName: json['busCompanyName'] ?? '',
      busCompanyId: json['busCompanyId'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
}
