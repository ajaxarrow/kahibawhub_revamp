import 'package:dio/dio.dart';
import 'package:kahibawhub_revamp/models/user_profile.dart';
import '../plugins/dio.config.dart';

class AppUserController{
  Future<UserProfile> getUserProfile({required String userID}) async {
    try {
      print(userID);
      final response = await dio.get(
        '/apiUserProfiling/getUserProfile/$userID',
      );
      final data = response.data;
      return UserProfile.fromMap(data);
    } catch (e) {
      print('Fetching of User Profile failed: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await dio.put(
        '/apiUserProfiling/updateUserProfile/$userId',
        data: profileData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Update User Profile failed: $e');
      rethrow;
    }
  }

  Future<void> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'userImage': await MultipartFile.fromFile(imagePath),
      });

      final response = await dio.post(
        '/apiUserProfiling/upload-image/$userId',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload Profile Image failed: $e');
      rethrow;
    }
  }
}