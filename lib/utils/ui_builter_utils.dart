import 'package:flutter/material.dart';

import '../themes/colors.dart';

void showError({
  required BuildContext context,
  required String errorMessage,
  required String errorTitle,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(errorTitle),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: const Text('Okay'),
        )
      ],
    ),
  );
}

Widget buildMultiSelectDropdown({
  required String label,
  required List<String> options,
  required List<String> selectedValues,
  required Function(List<String>) onChanged,
  bool isRequired = false,
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label + (isRequired ? ' *' : ''),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedValues.isEmpty)
              Text(
                'Select $label',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedValues.map((value) {
                  return Chip(
                    label: Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      final newSelected = List<String>.from(selectedValues);
                      newSelected.remove(value);
                      onChanged(newSelected);
                    },
                    backgroundColor: primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: primaryColor),
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => showMultiSelectDialog(
                title: 'Select $label',
                options: options,
                selectedValues: selectedValues,
                onChanged: onChanged,
                context: context,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add $label',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.add,
                      color: primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

void showMultiSelectDialog({
  required String title,
  required List<String> options,
  required List<String> selectedValues,
  required Function(List<String>) onChanged,
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = selectedValues.contains(option);
                  return CheckboxListTile(
                    title: Text(option),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedValues.add(option);
                        } else {
                          selectedValues.remove(option);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  onChanged(selectedValues);
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget buildDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
  bool isRequired = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label + (isRequired ? ' *' : ''),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text('Select $label'),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}
