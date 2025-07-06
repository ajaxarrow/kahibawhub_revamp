import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

class UserNotifier extends StateNotifier<AppUser?> {
  UserNotifier() : super(null);

  void setUser(AppUser user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  void updateUser(AppUser updatedUser) {
    state = updatedUser;
  }

}

final userProvider = StateNotifierProvider<UserNotifier, AppUser?>((ref) {
  return UserNotifier();
});

// Provider for checking if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  return user != null;
});