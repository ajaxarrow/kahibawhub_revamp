class Contributor {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? primaryInstitution;

  Contributor({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.primaryInstitution,
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      id: json['_id'],
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      primaryInstitution: json['primaryInstitution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      if (email != null) 'email': email,
      if (primaryInstitution != null) 'primaryInstitution': primaryInstitution,
    };
  }

  @override
  String toString() {
    return 'Contributor(id: $id, userId: $userId, name: $firstName $lastName, '
        'email: ${email ?? "N/A"}, institution: ${primaryInstitution ?? "N/A"})';
  }
}
