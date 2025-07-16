import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../layouts/circle_background.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../themes/colors.dart';
import '../widgets/custom_text_form_field.dart';
import '../controllers/app_user_controller.dart';
import '../models/user_profile.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  final bool isCompleting;
  final String? userId;

  const CompleteProfileScreen({
    super.key,
    this.isCompleting = true,
    this.userId,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  File? _pickedImage;
  String imagePath = 'lib/assets/images/user-placeholder.jpg';
  bool _isLoading = false;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _primaryInstitutionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _personalWebUrlController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityOrBarangayController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _fbLinkController = TextEditingController();
  final _twitterLinkController = TextEditingController();
  final _instagramLinkController = TextEditingController();
  final _linkedinLinkController = TextEditingController();

  // Dropdown values
  String? selectedUserType;
  List<String> selectedDisciplines = [];

  // Sample data for dropdowns
  final List<String> userTypes = [
    'Not Specified',
    'Researcher',
    'Student',
    'Faculty',
    'Professional',
    'Industry Expert',
    'Other'
  ];

  final List<String> disciplineOptions = [
    'Computer Science',
    'Engineering',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Medicine',
    'Psychology',
    'Business',
    'Economics',
    'Literature',
    'History',
    'Philosophy',
    'Art',
    'Music',
    'Other'
  ];

  UserProfile? currentProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (widget.userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appUserController = AppUserController();
      currentProfile = await appUserController.getUserProfile(userID: widget.userId!);
      print(currentProfile.toString());

      // Populate controllers with existing data
      _firstNameController.text = currentProfile?.firstName ?? '';
      _lastNameController.text = currentProfile?.lastName ?? '';
      _occupationController.text = currentProfile?.occupation ?? '';
      _primaryInstitutionController.text = currentProfile?.primaryInstitution ?? '';
      _descriptionController.text = currentProfile?.description ?? '';
      _phoneNumberController.text = currentProfile?.phoneNumber ?? '';
      _personalWebUrlController.text = currentProfile?.personalWebUrl ?? '';
      _provinceController.text = currentProfile?.province ?? '';
      _cityOrBarangayController.text = currentProfile?.cityOrBarangay ?? '';
      _zipCodeController.text = currentProfile?.zipCode ?? '';
      _fbLinkController.text = currentProfile?.fbLink ?? '';
      _twitterLinkController.text = currentProfile?.twitterLink ?? '';
      _instagramLinkController.text = currentProfile?.instagramLink ?? '';
      _linkedinLinkController.text = currentProfile?.linkedinLink ?? '';

      selectedUserType = userTypes.contains(currentProfile?.userType)
          ? currentProfile?.userType
          : 'Not Specified';
      selectedDisciplines = currentProfile?.disciplines ?? [];

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    XFile? xfilePick = pickedFile;
    setState(() {
      if (xfilePick != null) {
        _pickedImage = File(xfilePick.path);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
      }
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(userProvider);
      final userId = widget.userId ?? user?.id;

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final profileData = {
        'occupation': _occupationController.text,
        'primaryInstitution': _primaryInstitutionController.text,
        'userType': selectedUserType,
        'disciplines': selectedDisciplines,
        'description': _descriptionController.text,
        'phoneNumber': _phoneNumberController.text,
        'personalWebUrl': _personalWebUrlController.text,
        'province': _provinceController.text,
        'cityOrBarangay': _cityOrBarangayController.text,
        'zipCode': _zipCodeController.text,
        'fbLink': _fbLinkController.text,
        'twitterLink': _twitterLinkController.text,
        'IGLink': _instagramLinkController.text,
        'INLink': _linkedinLinkController.text,
      };

      // Update user profile using controller
      final appUserController = AppUserController();
      await appUserController.updateUserProfile(
        userId: userId,
        profileData: profileData,
      );

      // Upload image if selected
      if (_pickedImage != null) {
        await appUserController.uploadProfileImage(
          userId: userId,
          imagePath: _pickedImage!.path,
        );
      }

      // Update the user provider with the new profile
      if (user != null) {
        final updatedProfile = await appUserController.getUserProfile(userID: userId);
        final updatedUser = AppUser(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          dateRegistered: user.dateRegistered,
          userProfile: updatedProfile,
        );
        ref.read(userProvider.notifier).updateUser(updatedUser);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // Navigate based on context
      if (widget.isCompleting) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDropdown({
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

  void _showMultiSelectDialog({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
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

  @override
  Widget build(BuildContext context) {
    return CircleBackground(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 75),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.isCompleting
                          ? "Complete Your Profile Information"
                          : "Update Your Profile",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Align(
                      alignment: Alignment.center,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 125.0,
                            height: 125.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 5.0,
                              ),
                              image: DecorationImage(
                                image: _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : AssetImage(imagePath) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 80,
                            right: 0,
                            child: Container(
                              width: 25.0,
                              height: 25.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Theme.of(context).colorScheme.primary),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextFormField(
                    label: 'First Name',
                    hintText: 'Enter your first name',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_2_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Last Name',
                    hintText: 'Enter your last name',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_2_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Occupation',
                    hintText: 'Enter your occupation',
                    controller: _occupationController,
                    prefixIcon: Icons.work_outline,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Primary Institution',
                    hintText: 'Enter your primary institution',
                    controller: _primaryInstitutionController,
                    prefixIcon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    label: 'User Type',
                    value: selectedUserType,
                    items: userTypes,
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMultiSelectDropdown(
                    label: 'Disciplines',
                    options: disciplineOptions,
                    selectedValues: selectedDisciplines,
                    onChanged: (values) {
                      setState(() {
                        selectedDisciplines = values;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Description',
                    hintText: 'Enter your description',
                    controller: _descriptionController,
                    prefixIcon: Icons.description_outlined,
                    maxLines: 5,
                    isTextArea: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Phone Number',
                    hintText: 'Enter your phone number',
                    controller: _phoneNumberController,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Personal Website URL',
                    hintText: 'Enter your website URL',
                    controller: _personalWebUrlController,
                    prefixIcon: Icons.web_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Province',
                    hintText: 'Enter your province',
                    controller: _provinceController,
                    prefixIcon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'City or Barangay',
                    hintText: 'Enter your city or barangay',
                    controller: _cityOrBarangayController,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Zip Code',
                    hintText: 'Enter your zip code',
                    controller: _zipCodeController,
                    prefixIcon: Icons.pin_drop_outlined,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Social Media Links',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Facebook',
                    hintText: 'Enter your Facebook URL',
                    controller: _fbLinkController,
                    prefixIcon: Icons.facebook_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Twitter',
                    hintText: 'Enter your Twitter URL',
                    controller: _twitterLinkController,
                    prefixIcon: Icons.alternate_email_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Instagram',
                    hintText: 'Enter your Instagram URL',
                    controller: _instagramLinkController,
                    prefixIcon: Icons.camera_alt_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'LinkedIn',
                    hintText: 'Enter your LinkedIn URL',
                    controller: _linkedinLinkController,
                    prefixIcon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        widget.isCompleting ? "Finish Setup" : "Update Profile",
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _occupationController.dispose();
    _primaryInstitutionController.dispose();
    _descriptionController.dispose();
    _phoneNumberController.dispose();
    _personalWebUrlController.dispose();
    _provinceController.dispose();
    _cityOrBarangayController.dispose();
    _zipCodeController.dispose();
    _fbLinkController.dispose();
    _twitterLinkController.dispose();
    _instagramLinkController.dispose();
    _linkedinLinkController.dispose();
    super.dispose();
  }
}