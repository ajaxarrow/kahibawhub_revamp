import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/controllers/app_user_controller.dart';
import 'package:kahibawhub_revamp/models/learning_material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/learning_material_controller.dart';
import '../../data/material_related_selections_data.dart';
import '../../models/contributor.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../screens/success_screen.dart';
import '../../themes/colors.dart';
import '../../utils/ui_builter_utils.dart';
import '../custom_text_form_field.dart';

enum Mode { create, update }

class MaterialDialogForm extends ConsumerStatefulWidget {
  const MaterialDialogForm({
    super.key,
    required this.mode,
    this.materialId,
    this.material
  });

  final Mode mode;
  final String? materialId;
  final LearningMaterial? material;

  @override
  ConsumerState<MaterialDialogForm> createState() => _MaterialDialogFormState();
}

class _MaterialDialogFormState extends ConsumerState<MaterialDialogForm> {
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

  // Selection variables
  List<String> _selectedTargetAudience = [];
  List<String> _selectedDisciplines = [];
  List<String> _selectedAccessibility = [];
  List<String> _selectedContributorIds = []; // Changed to list of IDs
  Map<String, UserProfile> _contributorProfiles = {}; // Cache for profiles

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

  Future<void> _loadMaterialData() async {
    if (widget.mode == Mode.update && widget.material != null) {
      final material = widget.material!;
      _titleController.text = material.title ?? '';
      _descriptionController.text = material.description ?? '';
      _materialFileName = material.title ?? '';
      _imageFileName = material.title ?? '';
      _technicalFormat = material.technicalFormat;
      selectedMaterialType = material.type ?? 'Not Specified';
      _selectedTargetAudience = List<String>.from(material.targetAudience ?? []);
      _selectedDisciplines = List<String>.from(material.disciplines ?? []);
      _selectedAccessibility = List<String>.from(material.accessibility ?? []);

      // Handle contributors based on their type
      if (material.contributors != null) {
        // Check if contributors are already Contributor objects or just IDs
        if (material.contributors!.isNotEmpty) {
          if (material.contributors!.first is String) {
            // Contributors are IDs
            _selectedContributorIds = List<String>.from(material.contributors!);
          } else {
            // Contributors are Contributor objects, extract IDs
            _selectedContributorIds = material.contributors!
                .map((contributor) => contributor.id)
                .toList();
          }
          // Load contributor profiles
          await _loadContributorProfiles();
        }
      }
    }
  }

  Future<void> _loadContributorProfiles() async {
    for (String contributorId in _selectedContributorIds) {
      if (!_contributorProfiles.containsKey(contributorId)) {
        try {
          final profile = await AppUserController().getUserProfile(userID: contributorId);
          setState(() {
            _contributorProfiles[contributorId] = profile;
          });
        } catch (e) {
          print('Error loading contributor profile for $contributorId: $e');
        }
      }
    }
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

  Future<void> _showContributorSearchModal() async {
    await showDialog(
      context: context,
      builder: (context) => _ContributorSearchModal(
        controller: _controller,
        onContributorSelected: (contributor) async {
          if (!_selectedContributorIds.contains(contributor.userId)) {
            setState(() {
              _selectedContributorIds.add(contributor.userId);
            });

            // Load the contributor's profile
            try {
              final profile = await AppUserController().getUserProfile(userID: contributor.userId);
              setState(() {
                _contributorProfiles[contributor.userId] = profile;
              });
            } catch (e) {
              print('Error loading contributor profile: $e');
            }
          }
        },
      ),
    );
  }

  void _removeContributor(String contributorId) {
    setState(() {
      _selectedContributorIds.removeWhere((id) => id == contributorId);
      _contributorProfiles.remove(contributorId);
    });
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
          materialType: selectedMaterialType,
          technicalType: _technicalFormat!,
          disciplines: _selectedDisciplines,
          targetAudience: _selectedTargetAudience,
          accessibility: _selectedAccessibility,
          contributorIds: _selectedContributorIds, // Pass IDs instead of objects
        );
      } else {
        result = await _controller.updateMaterial(
          materialId: widget.materialId!,
          userId: user!.id!,
          materialFile: _materialFile,
          materialImage: _materialImage,
          materialTitle: _titleController.text,
          materialDescription: _descriptionController.text,
          materialType: selectedMaterialType,
          technicalType: _technicalFormat!,
          disciplines: _selectedDisciplines,
          targetAudience: _selectedTargetAudience,
          accessibility: _selectedAccessibility,
          contributorIds: _selectedContributorIds, // Pass IDs instead of objects
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

                      // Contributors Section - Updated to show profiles
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Contributors',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _isLoading ? null : _showContributorSearchModal,
                                  icon: Icon(PhosphorIconsRegular.plus, size: 16),
                                  label: const Text('Add'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_selectedContributorIds.isEmpty)
                              Text(
                                'No contributors added',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              Column(
                                children: _selectedContributorIds.map((contributorId) {
                                  final profile = _contributorProfiles[contributorId];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(PhosphorIconsRegular.user, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                profile != null
                                                    ? '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim()
                                                    : 'Loading...',
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              if (profile?.primaryInstitution != null && profile!.primaryInstitution!.isNotEmpty)
                                                Text(
                                                  profile.primaryInstitution!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _removeContributor(contributorId),
                                          icon: Icon(PhosphorIconsRegular.x, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

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

// Updated contributor search modal
class _ContributorSearchModal extends StatefulWidget {
  final LearningMaterialController controller;
  final Function(Contributor) onContributorSelected;

  const _ContributorSearchModal({
    required this.controller,
    required this.onContributorSelected,
  });

  @override
  State<_ContributorSearchModal> createState() => _ContributorSearchModalState();
}

class _ContributorSearchModalState extends State<_ContributorSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Contributor> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchContributors(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await widget.controller.searchContributors(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching contributors: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search Contributors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(PhosphorIconsRegular.x),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _searchContributors(value);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Start typing to search contributors'
                      : 'No contributors found',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final contributor = _searchResults[index];
                  return ListTile(
                    leading: Icon(PhosphorIconsRegular.user),
                    title: Text('${contributor.firstName} ${contributor.lastName}'),
                    subtitle: contributor.primaryInstitution != null
                        ? Text(contributor.primaryInstitution!)
                        : null,
                    onTap: () {
                      widget.onContributorSelected(contributor);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}