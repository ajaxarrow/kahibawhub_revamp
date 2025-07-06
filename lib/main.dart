import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/landing_screen.dart';
import 'themes/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/landing',
      routes: {
        // '/redirect': (context) => const RedirectScreen(),
        '/landing': (context) => const LandingScreen(),
        '/auth': (context) => const AuthScreen(),
        // '/complete-profile': (context) => const CompleteProfileScreen(),
        // '/dashboard': (context) => const DashboardScreen(),
        // '/engagements': (context) => const EngagementScreen(),
        // '/engagements/materials': (context) => const MaterialsEngagementScreen(),
        // '/engagements/users': (context) => const UsersEngagementScreen(),
        // '/my-materials': (context) => const MyMaterialsScreen(),
        // '/collaborations': (context) => const CollaborationsScreen(),
        // '/profile': (context) => ProfileScreen(author: AppUser(firstName: 'John', lastName: 'Doe')),
        // '/all-materials': (context) => const AllMaterialsScreen(),
      },
    );
  }
}