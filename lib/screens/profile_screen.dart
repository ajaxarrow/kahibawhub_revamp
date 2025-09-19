import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../themes/colors.dart';
import '../themes/styles.dart';
import '../widgets/custom_appbar.dart';
import '../screens/complete_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userData, this.userId});

  final AppUser? userData;
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider);
    final bool isCurrentUser = currentUser?.id == userId;

    return Scaffold(
      appBar: CustomAppbar(
          title: "Author's Profile: ${userData?.userProfile?.firstName ?? userData?.firstName ?? ''} ${userData?.userProfile?.lastName ?? userData?.lastName ?? ''}",
          isForMain: false
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 25,
                    left: 25,
                    top: 25
                ),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: _buildUserImage(userData),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userData?.userProfile?.firstName ?? userData?.firstName ?? 'John'} ${userData?.userProfile?.lastName ?? userData?.lastName ?? 'Doe'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18
                                  ),
                                ),
                                Text(
                                  userData?.email ?? userData?.email ?? 'N/A',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildSocialMediaLinks(userData),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 16),
                        const Text(
                          'Overview',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 8),
                        userData?.userProfile?.disciplines != null && userData!.userProfile!.disciplines!.isNotEmpty
                            ? Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: userData!.userProfile!.disciplines!.map<Widget>((discipline) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xffDDDDDD),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                discipline,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff888888),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                            : const SizedBox.shrink(),
                        userData?.userProfile?.disciplines != null && userData!.userProfile!.disciplines!.isNotEmpty
                            ? const SizedBox(height: 16) : const SizedBox.shrink(),
                        Text(
                            userData?.userProfile?.description ?? 'John Smith is a seasoned software engineer with over 10 years of professional experience in software development, web technologies, and mobile app creation. With a strong background in computer science and a passion for teaching, John has worked with leading tech companies to build scalable, high-performance systems.',
                            textAlign: TextAlign.justify
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Additional Details',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Institution', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.primaryInstitution ?? 'N/A')
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('User Type', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.userType ?? 'N/A'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone Number', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.phoneNumber ?? 'N/A')
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Personal Web URL', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.personalWebUrl ?? 'N/A'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Occupation', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.occupation ?? 'N/A')
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()), // Empty space for alignment
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Address',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('City/Barangay', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.cityOrBarangay ?? 'N/A')
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Province', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.province ?? 'N/A'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Zipcode', style: detailsLabelStyle),
                                  Text(userData?.userProfile?.zipCode ?? 'N/A')
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()), // Empty space for alignment
                          ],
                        )
                      ]
                  ),
                ),
              )
          ),
          // Only show edit button if it's the current user's profile
          if (isCurrentUser)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showEditProfileModal(context, userData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserImage(AppUser? user) {
    final imageData = user?.userProfile?.userImage?.data;

    return (imageData == null || imageData.isEmpty)
        ? Image.asset(
      'lib/assets/images/user-placeholder.jpg',
      width: 80,
      height: 90,
      fit: BoxFit.cover,
    )
        : Image.memory(
      Uint8List.fromList(imageData.cast<int>()),
      width: 80,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'lib/assets/images/user-placeholder.jpg',
          width: 80,
          height: 90,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildSocialMediaLinks(AppUser? user) {
    final userProfile = user?.userProfile;

    return Row(
      children: [
        if (userProfile?.fbLink != null && userProfile!.fbLink!.isNotEmpty)
          GestureDetector(
            onTap: () => _launchURL(userProfile.fbLink!),
            child: const PhosphorIcon(
              PhosphorIconsRegular.facebookLogo,
              size: 18,
              color: Color(0xff007AFF),
            ),
          ),
        if (userProfile?.fbLink != null && userProfile!.fbLink!.isNotEmpty)
          const SizedBox(width: 8),

        if (userProfile?.twitterLink != null && userProfile!.twitterLink!.isNotEmpty)
          GestureDetector(
            onTap: () => _launchURL(userProfile.twitterLink!),
            child: const PhosphorIcon(
              PhosphorIconsRegular.xLogo,
              size: 18,
              color: Color(0xff000000),
            ),
          ),
        if (userProfile?.twitterLink != null && userProfile!.twitterLink!.isNotEmpty)
          const SizedBox(width: 8),

        if (userProfile?.instagramLink != null && userProfile!.instagramLink!.isNotEmpty)
          GestureDetector(
            onTap: () => _launchURL(userProfile.instagramLink!),
            child: const PhosphorIcon(
              PhosphorIconsRegular.instagramLogo,
              size: 18,
              color: Color(0xffAF52DE),
            ),
          ),
        if (userProfile?.instagramLink != null && userProfile!.instagramLink!.isNotEmpty)
          const SizedBox(width: 8),

        if (userProfile?.linkedinLink != null && userProfile!.linkedinLink!.isNotEmpty)
          GestureDetector(
            onTap: () => _launchURL(userProfile.linkedinLink!),
            child: const PhosphorIcon(
              PhosphorIconsRegular.linkedinLogo,
              size: 18,
              color: Color(0xff30B0C7),
            ),
          ),
      ],
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle error - maybe show a snackbar
      debugPrint('Could not launch $url');
    }
  }

  void _showEditProfileModal(BuildContext context, AppUser? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: CompleteProfileScreen(
          isCompleting: false,
          userId: user?.id,
        ),
      ),
    );
  }
}