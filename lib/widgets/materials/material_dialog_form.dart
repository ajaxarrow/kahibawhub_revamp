import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../screens/success_screen.dart';
import '../../themes/colors.dart';
import '../custom_text_form_field.dart';

enum Mode { create, update }

class MaterialDialogForm extends StatelessWidget {
  const MaterialDialogForm({super.key, required this.mode});

  final Mode mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: formBGColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevents taking full height
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mode == Mode.create ? 'Add Material' : 'Update Material',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: PhosphorIcon(PhosphorIconsRegular.x),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    CustomTextFormField(
                      label: 'Upload Material',
                      hintText: 'Click Here to Upload Material',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Upload Image',
                      hintText: 'Click Here to Upload Material Image',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Material Title',
                      hintText: 'Enter Material Title',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Material Description',
                      hintText: 'Enter Material Description',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Technical Format',
                      hintText: 'Enter Format',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Target User',
                      hintText: 'Select Target User',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Discipline',
                      hintText: 'Select Disciplines',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Accessibility',
                      hintText: 'Select Accessibility',
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Submit Button (Fixed at Bottom)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SuccessScreen(
                        path: '/my-materials',
                        description: 'You have successfully added a material. You can check it in your materials page!',
                        buttonContent: 'View My Materials',
                      ))
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
