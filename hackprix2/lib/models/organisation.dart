// lib/models/organisation.dart

class Organisation {
  final String orgId;
  final String name;
  final int totalSignups;
  final int totalCustomCountSum;
  // This will be managed on the client-side to update the UI after joining
  bool isJoined; 

  Organisation({
    required this.orgId,
    required this.name,
    required this.totalSignups,
    required this.totalCustomCountSum,
    this.isJoined = false,
  });

  factory Organisation.fromJson(Map<String, dynamic> json) {
    return Organisation(
      orgId: json['orgId'],
      name: json['name'],
      // FIXED: Provide a default value of 0 if the backend sends null.
      totalSignups: json['totalSignups'] ?? 0,
      totalCustomCountSum: json['totalCustomCountSum'] ?? 0,
    );
  }
}
