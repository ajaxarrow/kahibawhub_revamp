import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/collaboration/collaborations_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/materials/all_materials_screen.dart';
import 'screens/materials/my_materials_screen.dart';
import 'themes/theme.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/landing',
      routes: {
        // '/redirect': (context) => const RedirectScreen(),
        '/landing': (context) => const LandingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/profile': (context) => const ProfileScreen(), // Temporary route for profile
        // '/complete-profile': (context) => const CompleteProfileScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // '/engagements': (context) => const EngagementScreen(),
        // '/engagements/materials': (context) => const MaterialsEngagementScreen(),
        // '/engagements/users': (context) => const UsersEngagementScreen(),
        '/my-materials': (context) => const MyMaterialsScreen(),
        '/collaborations': (context) => const CollaborationsScreen(),
        // '/profile': (context) => ProfileScreen(author: AppUser(firstName: 'John', lastName: 'Doe')),
        '/all-materials': (context) => const AllMaterialsScreen(),
      },
    );
  }
}