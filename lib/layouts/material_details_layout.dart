import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/learning_material.dart';
import '../screens/material_details/material_details_overview_screen.dart';
import '../themes/colors.dart';
import '../utils/base64_image_utils.dart';
import '../widgets/custom_appbar.dart';

class MaterialDetailsLayout extends StatefulWidget {
  const MaterialDetailsLayout({super.key, required this.material});

  final LearningMaterial material;

  @override
  _MaterialDetailsLayoutState createState() => _MaterialDetailsLayoutState();
}

class _MaterialDetailsLayoutState extends State<MaterialDetailsLayout> {
  bool _isLoading = false;
  int _selectedIndex = 0;

  final List<String> _tabTitles = [
    "Overview",
    "Authors",
    "Comments",
    "Reviews",
    // "Similar Materials"
  ];

  final List<Widget> _tabScreens = [];

  @override
  void initState() {
    super.initState();
    _tabScreens.addAll([
      MaterialDetailsOverviewScreen(material: widget.material),
      // MaterialDetailsAuthorsScreen(material: widget.material),
      // MaterialDetailsCommentsScreen(material: widget.material),
      // MaterialDetailsReviewScreen(material: widget.material),
      // MaterialDetailsSimilarMaterialsScreen(material: widget.material),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'Material Details', isForMain: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 25,
                    left: 25,
                    top: 10
                ),
                child: _tabScreens[_selectedIndex],
              )
          ),
          _buildViewSourceButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          child: widget.material.image != null ? Image.memory(
            base64ToBytes(widget.material.image),
            width: MediaQuery.of(context).size.width,
            height: 170,
            fit: BoxFit.cover,
          ) : Image.asset(
            'lib/assets/images/placeholder.jpg',
            width: MediaQuery.of(context).size.width,
            height: 170,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.material.title ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          _buildIconText(PhosphorIconsDuotone.eye, widget.material.views.toString(), const Color(0xff5856D6)),
          _buildSeparator(),
          _buildIconText(PhosphorIconsDuotone.star, widget.material.ratings.toString(), const Color(0xffFFCC00)),
        ]),
        Row(children: [
          _buildIcon(PhosphorIconsRegular.eye),
          _buildIcon(PhosphorIconsRegular.download),
          _buildIcon(PhosphorIconsRegular.printer),
          _buildIcon(PhosphorIconsRegular.share),
        ]),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        PhosphorIcon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: PhosphorIcon(icon, size: 12),
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text('|'),
    );
  }

  Widget _buildTabBar() {
    List<String> tabTitles = [
      "Overview",
      "Authors",
      "Comments",
      "Reviews",
      "Similar Materials"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
      height: 35, // Fixed height to prevent RenderFlex issues
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabTitles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                _tabTitles.length,
                    (index) => _buildTab(_tabTitles[index], index),
              ),
            ),
          );
        })
      )
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> viewOrDownloadMaterial() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a unique filename using slug format and timestamp
      String sanitizedTitle = widget.material.title!
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .trim();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileExtension = _detectFileType(widget.material.file.byteList);
      String fileName = '$sanitizedTitle-$timestamp.$fileExtension';

      // Get a temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, fileName);

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(widget.material.file.byteList);

      // Show Snackbar after saving
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Material saved: $fileName")),
        );
      }

      // Open the file
      OpenFilex.open(filePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save material: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _detectFileType(Uint8List bytes) {
    if (bytes.length < 4) return 'bin';

    // ZIP/Office formats (PK\x03\x04)
    if (bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04) {
      // For Office formats, we should check the internal file structure
      // But without extracting, we can't definitively know which Office format it is
      // Your observation of "ppt folder with xml data and docProps folder" confirms it's PPTX
      return 'pptx';
    }

    // All other file signatures...
    // PDF: %PDF (0x25 0x50 0x44 0x46)
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) return 'pdf';

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return 'jpg';

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return 'png';

    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) return 'gif';

    // GZIP: 1F 8B
    if (bytes[0] == 0x1F && bytes[1] == 0x8B) return 'gz';

    // Default when no match is found
    return 'bin';
  }

  Widget _buildViewSourceButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : viewOrDownloadMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Text("View Source Material", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}
