import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../controllers/learning_material_controller.dart';
import '../../models/learning_material.dart';
import '../../themes/colors.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/materials/material_item.dart';


class AllMaterialsScreen extends StatefulWidget {
  const AllMaterialsScreen({super.key});

  @override
  State<AllMaterialsScreen> createState() => _AllMaterialsScreenState();
}

class _AllMaterialsScreenState extends State<AllMaterialsScreen> {
  final TextEditingController searchQueryController = TextEditingController();
  List<LearningMaterial> materials = [];
  List<LearningMaterial> filteredMaterials = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchQueryController.addListener(_filterMaterials);
    _fetchMaterials();
  }

  @override
  void dispose() {
    searchQueryController.removeListener(_filterMaterials);
    searchQueryController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaterials() async {
    setState(() => isLoading = true);
    final materialsController = LearningMaterialController();
    final fetchedMaterials = await materialsController.fetchAll();
    setState(() {
      materials = fetchedMaterials;
      filteredMaterials = materials;
      isLoading = false;
    });
  }

  void _filterMaterials() {
    setState(() => isLoading = true);
    final query = searchQueryController.text.toLowerCase();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        filteredMaterials = materials.where((material) {
          return material.title!.toLowerCase().contains(query) ||
              material.description!.toLowerCase().contains(query);
        }).toList();
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'All Materials', isForMain: false, withAdditionalBottomContent: true,),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xffe3d0ce),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Hello User!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Explore KahibawHub’s curated selection of educational resources to broaden your horizons.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 100,
                      child: CustomTextFormField(
                        hintText: 'Search for Materials',
                        controller: searchQueryController,
                        prefixIcon: PhosphorIconsRegular.magnifyingGlass,
                        borderColor: primaryColor,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton.outlined(
                        onPressed: () {},
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.sliders,
                          color: primaryColor,
                          size: 21,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 40,
                left: 25,
                top: 10,
                right: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Popular Materials',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredMaterials.isEmpty
                        ? const Center(
                      child: Text(
                        'No materials found',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                        : ListView.builder(
                      itemCount: filteredMaterials.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: MaterialItem(
                            material: filteredMaterials[index],
                            materialCardType: CardType.small,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
