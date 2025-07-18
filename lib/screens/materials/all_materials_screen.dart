import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../controllers/learning_material_controller.dart';
import '../../data/material_related_selections_data.dart';
import '../../models/learning_material.dart';
import '../../themes/colors.dart';
import '../../utils/ui_helpers.dart';
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

  // Filter options
  List<String> availableAuthors = [];
  List<String> selectedAuthors = [];
  List<String> selectedDisciplines = [];
  List<String> selectedAccessibility = [];

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

    // Extract unique authors from materials
    Set<String> authorsSet = {};
    for (var material in fetchedMaterials) {
      if (material.author.isNotEmpty) {
        authorsSet.add(material.author);
      }
    }

    setState(() {
      materials = fetchedMaterials;
      filteredMaterials = materials;
      availableAuthors = authorsSet.toList()..sort();
      isLoading = false;
    });
  }

  void _filterMaterials() {
    setState(() => isLoading = true);
    final query = searchQueryController.text.toLowerCase();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        filteredMaterials = materials.where((material) {
          // Text search filter
          bool matchesSearch = query.isEmpty ||
              material.title?.toLowerCase().contains(query) == true ||
              material.description?.toLowerCase().contains(query) == true;

          // Author filter
          bool matchesAuthor = selectedAuthors.isEmpty ||
              selectedAuthors.contains(material.author);

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

          return matchesSearch && matchesAuthor && matchesDisciplines && matchesAccessibility;
        }).toList();
        isLoading = false;
      });
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedAuthors.clear();
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
      builder: (context) => AllMaterialsFilterModal(
        availableAuthors: availableAuthors,
        selectedAuthors: List.from(selectedAuthors),
        selectedDisciplines: List.from(selectedDisciplines),
        selectedAccessibility: List.from(selectedAccessibility),
        onFiltersApplied: (authors, disciplines, accessibility) {
          setState(() {
            selectedAuthors = authors;
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
    final hasActiveFilters = selectedAuthors.isNotEmpty ||
        selectedDisciplines.isNotEmpty ||
        selectedAccessibility.isNotEmpty;

    return Scaffold(
      appBar: const CustomAppbar(
        title: 'All Materials',
        isForMain: false,
        withAdditionalBottomContent: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with search and filter
          UIHelpers.buildHeaderSection(
            searchController: searchQueryController,
            hasActiveFilters: hasActiveFilters,
            onFilterTap: _showFilterModal,
          ),

          // Active filters indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                if (selectedAuthors.isNotEmpty || selectedDisciplines.isNotEmpty || selectedAccessibility.isNotEmpty) ...[
                  Icon(
                    PhosphorIconsRegular.funnel,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${selectedAuthors.length + selectedDisciplines.length + selectedAccessibility.length} filter${(selectedAuthors.length + selectedDisciplines.length + selectedAccessibility.length) > 1 ? 's' : ''} applied',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
                        'Popular Materials',
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
                            color: Colors.black54
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

/// Filter Modal for All Materials (with author filter)
class AllMaterialsFilterModal extends StatefulWidget {
  final List<String> availableAuthors;
  final List<String> selectedAuthors;
  final List<String> selectedDisciplines;
  final List<String> selectedAccessibility;
  final Function(List<String>, List<String>, List<String>) onFiltersApplied;
  final VoidCallback onClearAll;

  const AllMaterialsFilterModal({
    super.key,
    required this.availableAuthors,
    required this.selectedAuthors,
    required this.selectedDisciplines,
    required this.selectedAccessibility,
    required this.onFiltersApplied,
    required this.onClearAll,
  });

  @override
  State<AllMaterialsFilterModal> createState() => _AllMaterialsFilterModalState();
}

class _AllMaterialsFilterModalState extends State<AllMaterialsFilterModal> {
  late List<String> tempSelectedAuthors;
  late List<String> tempSelectedDisciplines;
  late List<String> tempSelectedAccessibility;

  @override
  void initState() {
    super.initState();
    tempSelectedAuthors = List.from(widget.selectedAuthors);
    tempSelectedDisciplines = List.from(widget.selectedDisciplines);
    tempSelectedAccessibility = List.from(widget.selectedAccessibility);
  }

  void _applyFilters() {
    widget.onFiltersApplied(
      tempSelectedAuthors,
      tempSelectedDisciplines,
      tempSelectedAccessibility,
    );
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
      tempSelectedAuthors.clear();
      tempSelectedDisciplines.clear();
      tempSelectedAccessibility.clear();
    });
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String, bool) onOptionToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) => onOptionToggle(option, selected),
              selectedColor: primaryColor,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Filter Materials',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Authors Filter
                  if (widget.availableAuthors.isNotEmpty)
                    _buildFilterSection(
                      title: 'Authors',
                      options: widget.availableAuthors,
                      selectedOptions: tempSelectedAuthors,
                      onOptionToggle: (author, selected) {
                        setState(() {
                          if (selected) {
                            tempSelectedAuthors.add(author);
                          } else {
                            tempSelectedAuthors.remove(author);
                          }
                        });
                      },
                    ),

                  // Disciplines Filter
                  _buildFilterSection(
                    title: 'Disciplines',
                    options: disciplineOptions,
                    selectedOptions: tempSelectedDisciplines,
                    onOptionToggle: (discipline, selected) {
                      setState(() {
                        if (selected) {
                          tempSelectedDisciplines.add(discipline);
                        } else {
                          tempSelectedDisciplines.remove(discipline);
                        }
                      });
                    },
                  ),

                  // Accessibility Filter
                  _buildFilterSection(
                    title: 'Accessibility',
                    options: accessibilityOptions,
                    selectedOptions: tempSelectedAccessibility,
                    onOptionToggle: (accessibility, selected) {
                      setState(() {
                        if (selected) {
                          tempSelectedAccessibility.add(accessibility);
                        } else {
                          tempSelectedAccessibility.remove(accessibility);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Apply Filters (${tempSelectedAuthors.length + tempSelectedDisciplines.length + tempSelectedAccessibility.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}