import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/learning_material_controller.dart';
import '../../data/material_related_selections_data.dart';
import '../../providers/auth_provider.dart';
import '../../screens/success_screen.dart';
import '../../themes/colors.dart';
import '../../utils/ui_helpers.dart';
import '../custom_text_form_field.dart';

enum Mode { create, update }

class MaterialDialogForm extends ConsumerStatefulWidget {
  const MaterialDialogForm({
    super.key,
    required this.mode,
    this.materialId
  });

  final Mode mode;
  final String? materialId;

  @override
  ConsumerState<MaterialDialogForm> createState() => _MaterialDialogFormState();
}

class _MaterialDialogFormState extends ConsumerState<MaterialDialogForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LearningMaterialController _controller = LearningMaterialController();

  // Controllers for form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _primaryInstitutionController = TextEditingController();

  // File variables
  File? _materialFile;
  File? _materialImage;
  String? _materialFileName;
  String? _imageFileName;
  String? _technicalFormat;

  // Selection variables
  List<String> _selectedTargetAudience = [];
  List<String> _selectedDisciplines = [];
  List<String> _selectedAccessibility = [];

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _primaryInstitutionController.dispose();
    super.dispose();
  }


  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  Future<void> _pickMaterialFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'epub'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final extension = _getFileExtension(fileName);

        setState(() {
          _materialFile = file;
          _materialFileName = fileName;
          _technicalFormat = extension.toUpperCase();
        });
      }
    } catch (e) {
      showError(context: context, errorMessage: e.toString(), errorTitle: 'Error Picking File');
      print('Error picking file: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _materialImage = File(image.path);
          _imageFileName = image.name;
        });
      }
    } catch (e) {
      showError(context: context, errorMessage: e.toString(), errorTitle: 'Error Picking Image');
      print('Error picking image: $e');
    }
  }

  Widget _buildMultiSelectDropdown({
    required String label,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
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
                onTap: () => _showMultiSelectDialog(
                  title: 'Select $label',
                  options: options,
                  selectedValues: selectedValues,
                  onChanged: onChanged,
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

  Future<void> _showMultiSelectDialog({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
  }) async {
    final List<String> tempSelected = List.from(selectedValues);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = tempSelected.contains(option);

                    return CheckboxListTile(
                      title: Text(option),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.add(option);
                          } else {
                            tempSelected.remove(option);
                          }
                        });
                      },
                      activeColor: primaryColor,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onChanged(tempSelected);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required file for create mode
    if (widget.mode == Mode.create && _materialFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a material file')),
      );
      return;
    }

    // Validate required selections
    if (_selectedTargetAudience.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one target audience')),
      );
      return;
    }

    if (_selectedDisciplines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one discipline')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _formKey.currentState!.save();

    try {
      Map<String, dynamic> result;

      final user = ref.watch(userProvider);

      if (widget.mode == Mode.create) {
        result = await _controller.addMaterial(
          userId: user!.id!,
          materialFile: _materialFile!,
          materialImage: _materialImage,
          materialTitle: _titleController.text,
          materialDescription: _descriptionController.text,
          materialType: _technicalFormat!,
          disciplines: _selectedDisciplines,
          targetAudience: _selectedTargetAudience,
          accessibility: _selectedAccessibility,
          primaryInstitution: _primaryInstitutionController.text,
        );
      } else {
        result = await _controller.updateMaterial(
          materialId: widget.materialId!,
          userId: user!.id!,
          materialFile: _materialFile,
          materialImage: _materialImage,
          materialTitle: _titleController.text,
          materialDescription: _descriptionController.text,
          materialType: _technicalFormat!,
          disciplines: _selectedDisciplines,
          targetAudience: _selectedTargetAudience,
          accessibility: _selectedAccessibility,
          primaryInstitution: _primaryInstitutionController.text,
        );
      }

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              path: '/my-materials',
              description: widget.mode == Mode.create
                  ? 'You have successfully added a material. You can check it in your materials page!'
                  : 'You have successfully updated the material. You can check it in your materials page!',
              buttonContent: 'View My Materials',
            ),
          ),
        );
      }
    } catch (error) {
      showError(
        context: context,
        errorMessage: error.toString(),
        errorTitle: 'Material ${widget.mode == Mode.create ? 'Creation' : 'Update'} Error',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${widget.mode == Mode.create ? 'add' : 'update'} material: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.mode == Mode.create ? 'Add Material' : 'Update Material',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : () {
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
                      // Material File Upload
                      GestureDetector(
                        onTap: _isLoading ? null : _pickMaterialFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upload Material *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.file,
                                    color: _materialFile != null ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _materialFileName ?? 'Click Here to Upload Material',
                                          style: TextStyle(
                                            color: _materialFile != null ? Colors.green : Colors.grey,
                                          ),
                                        ),
                                        if (_technicalFormat != null)
                                          Text(
                                            'Format: $_technicalFormat',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Supported formats: PDF, DOC, DOCX, PPT, PPTX, TXT, EPUB',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Image Upload
                      GestureDetector(
                        onTap: _isLoading ? null : _pickImage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upload Image',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.image,
                                    color: _materialImage != null ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _imageFileName ?? 'Click Here to Upload Material Image (Optional)',
                                      style: TextStyle(
                                        color: _materialImage != null ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Text Form Fields
                      CustomTextFormField(
                        controller: _titleController,
                        label: 'Material Title',
                        hintText: 'Enter Material Title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a material title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        isTextArea: true,
                        controller: _descriptionController,
                        label: 'Material Description',
                        hintText: 'Enter Material Description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a material description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _primaryInstitutionController,
                        label: 'Primary Institution',
                        hintText: 'Enter Primary Institution',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a primary institution';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Target Audience Multi-Select
                      _buildMultiSelectDropdown(
                        label: 'Target Audience',
                        options: targetAudienceOptions,
                        selectedValues: _selectedTargetAudience,
                        onChanged: (values) {
                          setState(() {
                            _selectedTargetAudience = values;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      // Disciplines Multi-Select
                      _buildMultiSelectDropdown(
                        label: 'Disciplines',
                        options: disciplineOptions,
                        selectedValues: _selectedDisciplines,
                        onChanged: (values) {
                          setState(() {
                            _selectedDisciplines = values;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      // Accessibility Multi-Select
                      _buildMultiSelectDropdown(
                        label: 'Accessibility Features',
                        options: accessibilityOptions,
                        selectedValues: _selectedAccessibility,
                        onChanged: (values) {
                          setState(() {
                            _selectedAccessibility = values;
                          });
                        },
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
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      widget.mode == Mode.create ? "Add Material" : "Update Material",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}