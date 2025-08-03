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
      if (e is DioException) {
        // Print full response for debugging
        print("DioException occurred:");
        print("Data: ${e.response?.data}");
        throw Exception('Fetching of User Profile failed: ${e.response?.data ?? e.message}');
      } else {
        print("Unexpected error: $e");
        throw Exception('Fetching of User Profile failed: ${e.toString()}');
      }
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

  /// Update social links separately
  Future<void> updateSocialLinks({
    required String userId,
    String? fbUrl,
    String? instagram,
    String? twitter,
    String? linkedin,
  }) async {
    try {
      final socialData = <String, dynamic>{};

      socialData['fbUrl'] = fbUrl ?? '';
      socialData['instagram'] = instagram ?? '';
      socialData['twitter'] = twitter ?? '';
      socialData['linkedin'] = linkedin ?? '';


      final response = await dio.post(
        '/apiUserProfiling/addSocials/$userId',
        data: socialData,
      );
      print(response.data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update social links: ${response.statusCode}');
      }
    } catch (e) {
      print('Update Social Links failed: $e');
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