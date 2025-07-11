import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../themes/colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: isForMain || withAdditionalBottomContent
          ? BorderRadius.zero
          : const BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffe3d0ce),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            if (isForMain){
              Scaffold.of(context).openDrawer();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: PhosphorIcon(
            isForMain ? PhosphorIconsRegular.list : PhosphorIconsFill.caretCircleLeft,
            color: primaryColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed('/profile');
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'lib/assets/images/user-placeholder.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
