import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/models/learning_material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/learning_material_controller.dart';
import '../../data/material_related_selections_data.dart';
import '../../models/contributor.dart';
import '../../providers/auth_provider.dart';
import '../../screens/success_screen.dart';
import '../../themes/colors.dart';
import '../../utils/ui_builter_utils.dart';
import '../custom_text_form_field.dart';

class MaterialUpdateRequestDialog extends ConsumerStatefulWidget {
  const MaterialUpdateRequestDialog({
    super.key,
    required this.material,
    required this.id,
  });

  final LearningMaterial material;
  final String id;

  @override
  ConsumerState<MaterialUpdateRequestDialog> createState() => _MaterialUpdateRequestDialogState();
}

class _MaterialUpdateRequestDialogState extends ConsumerState<MaterialUpdateRequestDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LearningMaterialController _controller = LearningMaterialController();

  // Controllers for form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // File variables
  File? _materialFile;
  File? _materialImage;
  String? _materialFileName;
  String? _imageFileName;
  String? _technicalFormat;
  String selectedMaterialType = 'Not Specified';
  String _primaryAuthorID = '';

  // Selection variables
  List<String> _selectedTargetAudience = [];
  List<String> _selectedDisciplines = [];
  List<String> _selectedAccessibility = [];
  List<String> _selectedContributors = [];

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMaterialData();
  }

  void _loadMaterialData() {
    final material = widget.material;
    _titleController.text = material.title ?? '';
    _descriptionController.text = material.description ?? '';
    _materialFileName = material.title ?? '';
    _imageFileName = material.title ?? '';
    _technicalFormat = material.technicalFormat;
    selectedMaterialType = material.type ?? 'Not Specified';
    _selectedTargetAudience = List<String>.from(material.targetAudience ?? []);
    _selectedDisciplines = List<String>.from(material.disciplines ?? []);
    _selectedAccessibility = List<String>.from(material.accessibility ?? []);
    _selectedContributors = List<String>.from(material.contributorIds ?? []);
    _primaryAuthorID = material.authorData?.id ?? '';
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


  void _submit() async {
    if (!_formKey.currentState!.validate()) {
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
      final user = ref.watch(userProvider);

      final result = await _controller.sendMaterialUpdateRequest(
        userId: user!.id!,
        materialId: widget.id,
        updatedMaterialFile: _materialFile,
        updatedMaterialImage: _materialImage,
        updatedMaterialTitle: _titleController.text,
        updatedMaterialDescription: _descriptionController.text,
        updatedMaterialType: selectedMaterialType,
        updatedTechnicalType: _technicalFormat ?? widget.material.technicalFormat ?? '',
        updatedDisciplines: _selectedDisciplines,
        updatedTargetAudience: _selectedTargetAudience,
        primaryAuthorID: _primaryAuthorID,
        updatedContributors: _selectedContributors,
      );

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              path: '/my-materials',
              description: 'Your material update request has been sent successfully! The collaborators will review and approve your changes.',
              buttonContent: 'View My Materials',
            ),
          ),
        );
      }
    } catch (error) {
      showError(
        context: context,
        errorMessage: error.toString(),
        errorTitle: 'Update Request Error',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send update request: ${error.toString()}')),
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
        height: MediaQuery.of(context).size.height * 0.9,
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
                    const Text(
                      'Request Material Update',
                      style: TextStyle(
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

              // Info Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.info, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your update request will be sent to all collaborators for approval. Changes will only be applied once approved.',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                                'Update Material File (Optional)',
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
                                          _materialFileName ?? 'Click Here to Upload New Material File',
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
                                'Leave empty to keep current file. Supported: PDF, DOC, DOCX, PPT, PPTX, TXT, EPUB',
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
                                'Update Material Image (Optional)',
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
                                      _imageFileName ?? 'Click Here to Upload New Material Image',
                                      style: TextStyle(
                                        color: _materialImage != null ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Leave empty to keep current image',
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
                      buildDropdown(
                        label: 'Material Type',
                        value: selectedMaterialType,
                        items: materialTypeOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedMaterialType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Contributors Section
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.all(16),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey.shade300),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           const Text(
                      //             'Contributors',
                      //             style: TextStyle(
                      //               fontWeight: FontWeight.w600,
                      //               fontSize: 14,
                      //             ),
                      //           )
                      //         ],
                      //       ),
                      //       const SizedBox(height: 8),
                      //       if (_selectedContributors.isEmpty)
                      //         Text(
                      //           'No contributors added',
                      //           style: TextStyle(
                      //             color: Colors.grey.shade600,
                      //             fontStyle: FontStyle.italic,
                      //           ),
                      //         )
                      //       else
                      //         Column(
                      //           children: _selectedContributors.map((contributor) {
                      //             return Container(
                      //               margin: const EdgeInsets.only(bottom: 8),
                      //               padding: const EdgeInsets.all(12),
                      //               decoration: BoxDecoration(
                      //                 color: Colors.grey.shade100,
                      //                 borderRadius: BorderRadius.circular(8),
                      //               ),
                      //               child: Row(
                      //                 children: [
                      //                   Icon(PhosphorIconsRegular.user, size: 20),
                      //                   const SizedBox(width: 8),
                      //                   Expanded(
                      //                     child: Column(
                      //                       crossAxisAlignment: CrossAxisAlignment.start,
                      //                       children: [
                      //                         Text(
                      //                           '${contributor.firstName} ${contributor.lastName}',
                      //                           style: const TextStyle(fontWeight: FontWeight.w500),
                      //                         ),
                      //                         if (contributor.primaryInstitution != null)
                      //                           Text(
                      //                             contributor.primaryInstitution!,
                      //                             style: TextStyle(
                      //                               fontSize: 12,
                      //                               color: Colors.grey.shade600,
                      //                             ),
                      //                           ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             );
                      //           }).toList(),
                      //         ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 20),

                      // Target Audience Multi-Select
                      buildMultiSelectDropdown(
                        context: context,
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
                      buildMultiSelectDropdown(
                        context: context,
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
                      buildMultiSelectDropdown(
                        label: 'Accessibility Features',
                        options: accessibilityOptions,
                        selectedValues: _selectedAccessibility,
                        onChanged: (values) {
                          setState(() {
                            _selectedAccessibility = values;
                          });
                        },
                        context: context,
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
                        : const Text(
                      "Send Update Request",
                      style: TextStyle(
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
