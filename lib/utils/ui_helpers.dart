import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/material_related_selections_data.dart';
import '../themes/colors.dart';
import '../widgets/custom_text_form_field.dart';

class UIHelpers {
  /// Builds the active filters indicator row
  static Widget buildActiveFiltersRow({
    required int selectedDisciplinesCount,
    required int selectedAccessibilityCount,
    required VoidCallback onClearAll,
  }) {
    final totalFilters = selectedDisciplinesCount + selectedAccessibilityCount;

    if (totalFilters == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.funnel,
            size: 16,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$totalFilters filter${totalFilters > 1 ? 's' : ''} applied',
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClearAll,
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
      ),
    );
  }

  /// Builds the header section with search and filter button
  static Widget buildHeaderSection({
    required TextEditingController searchController,
    required bool hasActiveFilters,
    required VoidCallback onFilterTap,
  }) {
    return Container(
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
            'Explore KahibawHub\'s curated selection of educational resources to broaden your horizons.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: 'Search for Materials',
                  controller: searchController,
                  prefixIcon: PhosphorIconsRegular.magnifyingGlass,
                  borderColor: primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasActiveFilters ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.funnel,
                    color: hasActiveFilters ? Colors.white : primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Filter Modal for My Materials (without author filter)
class MyMaterialsFilterModal extends StatefulWidget {
  final List<String> selectedDisciplines;
  final List<String> selectedAccessibility;
  final Function(List<String>, List<String>) onFiltersApplied;
  final VoidCallback onClearAll;

  const MyMaterialsFilterModal({
    super.key,
    required this.selectedDisciplines,
    required this.selectedAccessibility,
    required this.onFiltersApplied,
    required this.onClearAll,
  });

  @override
  State<MyMaterialsFilterModal> createState() => _MyMaterialsFilterModalState();
}

class _MyMaterialsFilterModalState extends State<MyMaterialsFilterModal> {
  late List<String> tempSelectedDisciplines;
  late List<String> tempSelectedAccessibility;

  @override
  void initState() {
    super.initState();
    tempSelectedDisciplines = List.from(widget.selectedDisciplines);
    tempSelectedAccessibility = List.from(widget.selectedAccessibility);
  }

  void _applyFilters() {
    widget.onFiltersApplied(
      tempSelectedDisciplines,
      tempSelectedAccessibility,
    );
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
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
                  'Apply Filters (${tempSelectedDisciplines.length + tempSelectedAccessibility.length})',
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