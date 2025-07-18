import 'package:kahibawhub_revamp/models/image_data.dart';

import '../utils/fallback_utils.dart';

class UserProfile {
  UserProfile({
    this.id,
    this.userID,
    this.firstName,
    this.lastName,
    this.primaryInstitution,
    this.userType,
    this.disciplines,
    this.description,
    this.phoneNumber,
    this.personalWebUrl,
    this.province,
    this.cityOrBarangay,
    this.zipCode,
    this.userImage,
    this.fbLink,
    this.twitterLink,
    this.instagramLink,
    this.linkedinLink,
    this.email,
    this.occupation
  });

  final String? id;
  final String? userID;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? occupation;
  final String? primaryInstitution;
  final String? userType;
  final List<String>? disciplines;
  final String? description;
  final String? phoneNumber;
  final String? personalWebUrl;
  final String? province;
  final String? cityOrBarangay;
  final String? zipCode;
  final ImageData? userImage;
  final String? fbLink;
  final String? twitterLink;
  final String? instagramLink;
  final String? linkedinLink;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['_id'],
      userID: map['userId'],
      firstName: fallbackIfEmpty(map['firstName']),
      lastName: fallbackIfEmpty(map['lastName']),
      primaryInstitution: fallbackIfEmpty(map['primaryInstitution']),
      userType: map['userType'],
      disciplines: List<String>.from(map['disciplines'] ?? []),
      description: fallbackIfEmpty(map['description']),
      phoneNumber: fallbackIfEmpty(map['phoneNumber']),
      personalWebUrl: fallbackIfEmpty(map['personalWebUrl']),
      province: fallbackIfEmpty(map['province']),
      cityOrBarangay: fallbackIfEmpty(map['cityOrBarangay']),
      zipCode: fallbackIfEmpty(map['zipCode']),
      userImage: map['userImage'] != null
          ? ImageData.fromMap(map['userImage'] as Map<String, dynamic>)
          : null,
      fbLink: map['fbLink'],
      twitterLink: map['twitterLink'],
      instagramLink: map['instagramLink'],
      linkedinLink: map['linkedinLink'],
      email: map['email'],
      occupation: map['occupation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userID,
      'firstName': firstName,
      'lastName': lastName,
      'primaryInstitution': primaryInstitution,
      'userType': userType,
      'disciplines': disciplines,
      'description': description,
      'phoneNumber': phoneNumber,
      'personalWebUrl': personalWebUrl,
      'province': province,
      'cityOrBarangay': cityOrBarangay,
      'zipCode': zipCode,
      'userImage': userImage?.toMap(),
      'fbLink': fbLink,
      'twitterLink': twitterLink,
      'instagramLink': instagramLink,
      'linkedinLink': linkedinLink,
      'email': email,
      'occupation': occupation,
    };
  }


  @override
  String toString() {
    return 'UserProfile(id: $id, userID: $userID, firstName: $firstName, lastName: $lastName, '
        'primaryInstitution: $primaryInstitution, userType: $userType, disciplines: $disciplines, '
        'description: $description, phoneNumber: $phoneNumber, personalWebUrl: $personalWebUrl, '
        'province: $province, cityOrBarangay: $cityOrBarangay, zipCode: $zipCode)'
        'fbLink: $fbLink, twitterLink: $twitterLink, instagramLink: $instagramLink, '
        'linkedinLink: $linkedinLink, email: $email, occupation: $occupation';
  }
}
