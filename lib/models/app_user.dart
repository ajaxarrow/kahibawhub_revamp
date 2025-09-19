import 'package:kahibawhub_revamp/models/user_profile.dart';

class AppUser {
  AppUser({
    this.firstName,
    this.lastName,
    this.email,
    this.id,
    this.dateRegistered,
    this.userProfile,
    this.password,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? dateRegistered;
  UserProfile? userProfile;

  // fromMap factory
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['_id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['userName'],
      dateRegistered: map['dateRegistered'],
      userProfile: map['userProfile'] != null ? UserProfile.fromMap(map['userProfile']) : null,
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateRegistered': dateRegistered,
      'userProfile': userProfile?.toMap(),
    };
  }

  // Method to update user profile
  void updateUserProfile(UserProfile newProfile) {
    userProfile = newProfile;
  }

  // Method to check if profile is complete
  bool get isProfileComplete {
    return userProfile != null &&
        userProfile!.occupation != null &&
        userProfile!.primaryInstitution != null &&
        userProfile!.userType != null;
  }

  // toString override
  @override
  String toString() {
    return '''
    AppUser{
      id: $id, 
      firstName: $firstName, 
      lastName: $lastName, 
      email: $email, 
      dateRegistered: $dateRegistered,
      userProfile: $userProfile}
    ''';
  }
}