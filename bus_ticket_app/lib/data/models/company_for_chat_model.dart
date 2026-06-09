class CompanyForChatModel {
  final String id;
  final String companyName;
  final String? email;
  final String? hotline;

  const CompanyForChatModel({
    required this.id,
    required this.companyName,
    this.email,
    this.hotline,
  });

  factory CompanyForChatModel.fromJson(Map<String, dynamic> json) {
    return CompanyForChatModel(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ??
          json['CompanyName']?.toString() ??
          '',
      email: json['email']?.toString(),
      hotline: json['hotline']?.toString(),
    );
  }
}
