import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../themes/colors.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/materials/material_dialog_form.dart';
import '../widgets/nav_drawer.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.index,
    required this.title,
    required this.content,
  });

  final int index;
  final String title;
  final Widget content;



  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': PhosphorIconsRegular.house,
      'label': 'Home',
    },
    // {
    //   'icon': PhosphorIconsRegular.chartBar,
    //   'label': 'Engagements',
    // },
    {
      'icon': PhosphorIconsRegular.handshake,
      'label': 'Profile',
    },
  ];

  final List<String> _navLinks = [
    '/dashboard',
    // '/engagements',
    '/my-materials',
    // '/collaborations'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedIndex = widget.index;
    });
  }

  void openMaterialFormDialog(){
    showModalBottomSheet(
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        builder: (ctx) => const MaterialDialogForm(mode: Mode.create)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: CustomAppbar(title: widget.title, isForMain: true),
      body: widget.content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            Navigator.of(context).pushReplacementNamed(_navLinks[index]);
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed, // Prevents movement
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xff888888),
        items: _navItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          return BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 24,
                  decoration: BoxDecoration(
                    color: _selectedIndex == idx ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                PhosphorIcon(item['icon'], size: 28,),
              ],
            ),
            label: item['label'],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openMaterialFormDialog,
        backgroundColor: primaryColor,
        child: const PhosphorIcon(PhosphorIconsRegular.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

