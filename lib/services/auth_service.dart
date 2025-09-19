import 'package:dio/dio.dart';
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
          "userName": email,
          "password": password,
        },
      );

      final data = response.data;
      final userMap = data['user'];
      final profileMap = data['profile'];

      final user = AppUser.fromMap(userMap);
      user.userProfile = UserProfile.fromMap(profileMap);

      return user;
    } on DioException catch (e) {
      // Handle HTTP error responses (404, 401, etc.)
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Extract error message from response body
        String errorMessage = 'Login failed';
        if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
          errorMessage = responseData['error'] ?? errorMessage;
        }

        print('User Registration failed (Status: $statusCode): $errorMessage');

      } else {
        // Handle network errors (no response received)
        print('User Registration failed: Network error - ${e.message}');
        throw Exception('User Registration failed: Network error');
      }
      rethrow;
    } catch (e) {
      // Handle any other unexpected errors
      print('User Registration failed: $e');
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
          "userName": email,
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
    } on DioException catch (e) {
      // Handle HTTP error responses (404, 401, etc.)
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Extract error message from response body
        String errorMessage = 'Login failed';
        if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
          errorMessage = responseData['error'] ?? errorMessage;
        }

        print('User Login failed (Status: $statusCode): $errorMessage');

      } else {
        // Handle network errors (no response received)
        print('User Login failed: Network error - ${e.message}');
        throw Exception('Login failed: Network error');
      }
      rethrow;
    } catch (e) {
      // Handle any other unexpected errors
      print('User Login failed: $e');
      rethrow;
    }
  }



}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});