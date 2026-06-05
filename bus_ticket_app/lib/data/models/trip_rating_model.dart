class TripRatingModel {
  final int id;
  final int serviceQuality;
  final int punctuality;
  final int safety;
  final int cleanliness;
  final String? customerName;
  final String? routeName;
  final String? description;
  final double averageStars;
  final String? createdAt;

  TripRatingModel({
    required this.id,
    required this.serviceQuality,
    required this.punctuality,
    required this.safety,
    required this.cleanliness,
    this.customerName,
    this.routeName,
    this.description,
    required this.averageStars,
    this.createdAt,
  });

  factory TripRatingModel.fromJson(Map<String, dynamic> json) {
    return TripRatingModel(
      id: (json['id'] as num).toInt(),
      serviceQuality: (json['serviceQuality'] as num).toInt(),
      punctuality: (json['punctuality'] as num).toInt(),
      safety: (json['safety'] as num).toInt(),
      cleanliness: (json['cleanliness'] as num).toInt(),
      customerName: json['customerName'] as String?,
      routeName: json['routeName'] as String?,
      description: json['description'] as String?,
      averageStars: (json['averageStars'] as num).toDouble(),
      createdAt: json['createdAt'] as String?,
    );
  }
}
