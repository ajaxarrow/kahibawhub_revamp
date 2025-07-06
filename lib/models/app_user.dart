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
      email: map['email'],
      dateRegistered: map['dateRegistered'],
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
    };
  }



  // toString override
  @override
  String toString() {
    return '''
    Author{
      id: $id, 
      firstName: $firstName, 
      lastName: $lastName, 
      email: $email, 
      dateRegistered: $dateRegistered}
    ''';
  }
}
