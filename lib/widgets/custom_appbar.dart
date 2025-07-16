import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/screens/profile_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../providers/auth_provider.dart';
import '../screens/complete_profile_screen.dart';
import '../themes/colors.dart';

class CustomAppbar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    required this.title,
    required this.isForMain,
    this.withAdditionalBottomContent = false
  });

  final String title;
  final bool isForMain;
  final bool withAdditionalBottomContent;

  @override
  ConsumerState<CustomAppbar> createState() => _CustomAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppbarState extends ConsumerState<CustomAppbar> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return ClipRRect(
      borderRadius: widget.isForMain || widget.withAdditionalBottomContent
          ? BorderRadius.zero
          : const BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffe3d0ce),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            if (widget.isForMain){
              Scaffold.of(context).openDrawer();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: PhosphorIcon(
            widget.isForMain ? PhosphorIconsRegular.list : PhosphorIconsFill.caretCircleLeft,
            color: primaryColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userData: user,
                    userId: user?.id,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (user?.userProfile?.userImage?.data == null ||
                    user!.userProfile!.userImage!.data.isEmpty)
                    ? Image.asset(
                  'lib/assets/images/user-placeholder.jpg',
                  fit: BoxFit.cover,
                )
                    : Image.memory(
                  Uint8List.fromList(user.userProfile!.userImage!.data.cast<int>()),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}