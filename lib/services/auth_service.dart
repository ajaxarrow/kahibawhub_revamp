import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/controllers/app_user_controller.dart';
import '../models/app_user.dart';
import '../models/user_profile.dart';
import '../plugins/dio.config.dart';

class AuthService{

  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/apiAuthentication/newRegistration',
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
        },
      );

      final data = response.data;
      final userMap = data['user'];
      final profileMap = data['profile'];

      final user = AppUser.fromMap(userMap);
      user.userProfile = UserProfile.fromMap(profileMap);

      return user;
    } catch (e) {
      print('Registration failed: $e');
      rethrow;
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/apiAuthentication/userLogin',
        data: {
          "email": email,
          "password": password,
        },
      );

      final data = response.data;
      final userID = data['userId'];

      final userProfile = await AppUserController().getUserProfile(userID: userID);
      final user = AppUser(
        id: userID,
        firstName: userProfile.firstName,
        lastName: userProfile.lastName,
        email: userProfile.email,
      );
      user.userProfile = userProfile;

      return user;
    } catch (e) {
      print('User Login failed: $e');
      rethrow;
    }
  }



}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});