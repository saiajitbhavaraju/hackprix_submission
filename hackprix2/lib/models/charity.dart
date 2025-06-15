// lib/models/charity.dart

class Charity {
  final String charityId;
  final String name;
  final int totalSignups;
  bool isJoined;

  Charity({
    required this.charityId,
    required this.name,
    required this.totalSignups,
    this.isJoined = false,
  });

  factory Charity.fromJson(Map<String, dynamic> json) {
    return Charity(
      charityId: json['charityId'],
      name: json['name'],
      totalSignups: json['totalSignups'] ?? 0,
    );
  }
}
