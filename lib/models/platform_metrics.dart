class PlatformMetrics {
  final int totalUsers;
  final int totalMaterials;
  final int totalReads;
  final int totalInstitutions;

  PlatformMetrics({
    this.totalUsers = 0,
    this.totalMaterials = 0,
    this.totalReads = 0,
    this.totalInstitutions = 0,
  });

  factory PlatformMetrics.fromMap(Map<String, dynamic> map) {
    return PlatformMetrics(
      totalUsers: map['totalUsers'] ?? 0,
      totalMaterials: map['totalMaterials'] ?? 0,
      totalReads: map['totalReads'] ?? 0,
      totalInstitutions: map['totalInstitutions'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalMaterials': totalMaterials,
      'totalReads': totalReads,
      'totalInstitutions': totalInstitutions,
    };
  }

  @override
  String toString() {
    return 'PlatformMetrics(totalUsers: $totalUsers, totalMaterials: $totalMaterials, totalReads: $totalReads, totalInstitutions: $totalInstitutions)';
  }
}
