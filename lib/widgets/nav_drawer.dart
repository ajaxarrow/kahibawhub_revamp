import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:typed_data';
import '../providers/auth_provider.dart';
import '../themes/colors.dart';

class NavDrawer extends ConsumerStatefulWidget {
  const NavDrawer({super.key});

  @override
  ConsumerState<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends ConsumerState<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);

    // Get image data from user profile
    final imageData = user?.userProfile?.userImage?.data;

    return Drawer(
      shape: const UnderlineInputBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              isLoggedIn && user != null
                  ? '${user.firstName} ${user.lastName}'
                  : 'Guest',
            ),
            accountEmail: Text(
              '',
            ),
            currentAccountPicture: CircleAvatar(
              radius: 12,
              backgroundColor: primaryColor,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: (imageData != null && imageData.isNotEmpty)
                        ? MemoryImage(Uint8List.fromList(imageData.cast<int>()))
                        : const AssetImage('lib/assets/images/user-placeholder.jpg'),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Optional: log or handle the error
                      print('Error loading profile image: $exception');
                    },
                  ),
                ),
              ),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, highlightColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const PhosphorIcon(PhosphorIconsRegular.user),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          if (isLoggedIn)
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.signOut),
              title: const Text('Logout'),
              onTap: () {
                ref.read(userProvider.notifier).clearUser();
                Navigator.of(context).pushReplacementNamed('/auth');
              },
            ),
        ],
      ),
    );
  }
}