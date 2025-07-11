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
}
