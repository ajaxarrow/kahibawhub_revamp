import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../controllers/learning_material_controller.dart';
import '../../layouts/main_layout.dart';
import '../../models/learning_material.dart';
import '../../providers/auth_provider.dart';
import '../../themes/colors.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/materials/material_item.dart';

class MyMaterialsScreen extends ConsumerStatefulWidget {
  const MyMaterialsScreen({super.key});

  @override
  ConsumerState<MyMaterialsScreen> createState() => _MyMaterialsScreenState();
}

class _MyMaterialsScreenState extends ConsumerState<MyMaterialsScreen> {
  final TextEditingController searchQueryController = TextEditingController();
  List<LearningMaterial> materials = [];
  List<LearningMaterial> filteredMaterials = [];
  bool isLoading = true;
  bool _hasInitialized = false;

  // Filter options (excluding authors)
  List<String> selectedDisciplines = [];
  List<String> selectedAccessibility = [];

  @override
  void initState() {
    super.initState();
    searchQueryController.addListener(_filterMaterials);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only fetch materials once when dependencies are available
    if (!_hasInitialized) {
      _hasInitialized = true;
      _fetchMaterials();
    }
  }

  @override
  void dispose() {
    searchQueryController.removeListener(_filterMaterials);
    searchQueryController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaterials() async {
    final user = ref.watch(userProvider);
    if (user?.id != null) {
      setState(() => isLoading = true);
      final materialsController = LearningMaterialController();
      final fetchedMaterials = await materialsController.fetchByUserID(userID: user!.id!);

      if (mounted) {
        setState(() {
          materials = fetchedMaterials;
          filteredMaterials = materials;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _filterMaterials() {
    setState(() => isLoading = true);
    final query = searchQueryController.text.toLowerCase();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          filteredMaterials = materials.where((material) {
            // Text search filter
            bool matchesSearch = query.isEmpty ||
                material.title?.toLowerCase().contains(query) == true ||
                material.description?.toLowerCase().contains(query) == true;

            // Disciplines filter
            bool matchesDisciplines = selectedDisciplines.isEmpty ||
                (material.disciplines != null &&
                    material.disciplines!.any((discipline) =>
                        selectedDisciplines.contains(discipline)));

            // Accessibility filter
            bool matchesAccessibility = selectedAccessibility.isEmpty ||
                (material.accessibility != null &&
                    material.accessibility!.any((access) =>
                        selectedAccessibility.contains(access)));

            return matchesSearch && matchesDisciplines && matchesAccessibility;
          }).toList();
          isLoading = false;
        });
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedDisciplines.clear();
      selectedAccessibility.clear();
      searchQueryController.clear();
    });
    _filterMaterials();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MyMaterialsFilterModal(
        selectedDisciplines: List.from(selectedDisciplines),
        selectedAccessibility: List.from(selectedAccessibility),
        onFiltersApplied: (disciplines, accessibility) {
          setState(() {
            selectedDisciplines = disciplines;
            selectedAccessibility = accessibility;
          });
          _filterMaterials();
        },
        onClearAll: _clearAllFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedDisciplines.isNotEmpty || selectedAccessibility.isNotEmpty;

    return MainLayout(
      index: 1,
      title: 'My Materials',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with search and filter
          UIHelpers.buildHeaderSection(
            searchController: searchQueryController,
            hasActiveFilters: hasActiveFilters,
            onFilterTap: _showFilterModal,
          ),

          // Active filters indicator
          UIHelpers.buildActiveFiltersRow(
            selectedDisciplinesCount: selectedDisciplines.length,
            selectedAccessibilityCount: selectedAccessibility.length,
            onClearAll: _clearAllFilters,
          ),

          // Materials list
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Materials',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${filteredMaterials.length} result${filteredMaterials.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredMaterials.isEmpty
                        ? const Center(
                      child: Text(
                        'No materials found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
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