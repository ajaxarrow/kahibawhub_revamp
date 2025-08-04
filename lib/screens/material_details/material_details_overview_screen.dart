import 'package:flutter/material.dart';

import '../../models/learning_material.dart';
import '../../themes/styles.dart';
import '../../controllers/app_user_controller.dart'; // Add this import
import '../../models/user_profile.dart'; // Add this import

class MaterialDetailsOverviewScreen extends StatefulWidget {
  const MaterialDetailsOverviewScreen({super.key, required this.material});

  final LearningMaterial material;

  @override
  State<MaterialDetailsOverviewScreen> createState() => _MaterialDetailsOverviewScreenState();
}

class _MaterialDetailsOverviewScreenState extends State<MaterialDetailsOverviewScreen> {
  final AppUserController _userController = AppUserController();
  List<UserProfile> contributors = [];
  bool isLoadingContributors = false;

  @override
  void initState() {
    super.initState();
    _loadContributors();
  }

  Future<void> _loadContributors() async {
    if (widget.material.contributorIds != null && widget.material.contributorIds!.isNotEmpty) {
      setState(() {
        isLoadingContributors = true;
      });

      try {
        List<UserProfile> loadedContributors = [];
        for (String contributorId in widget.material.contributorIds!) {
          try {
            final userProfile = await _userController.getUserProfile(userID: contributorId);
            loadedContributors.add(userProfile);
          } catch (e) {
            print('Error loading contributor $contributorId: $e');
            // Continue loading other contributors even if one fails
          }
        }

        setState(() {
          contributors = loadedContributors;
          isLoadingContributors = false;
        });
      } catch (e) {
        print('Error loading contributors: $e');
        setState(() {
          isLoadingContributors = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 8,),
            widget.material.disciplines!.isNotEmpty
                ? Column(
              children: [
                SizedBox(
                  height: 30, // Set a fixed height for the list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.material.disciplines!.length,
                    itemBuilder: (context, index) {
                      final discipline = widget.material.disciplines![index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                            color: Color(0xff888888),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ) : const SizedBox.shrink(),
            Text(
                widget.material.description ?? '',
                textAlign: TextAlign.justify
            ),
            const SizedBox(height: 16),

            // Contributors Section
            if (widget.material.contributorIds != null && widget.material.contributorIds!.isNotEmpty) ...[
              Text(
                'Contributors',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xffDDDDDD),
                    width: 1,
                  ),
                ),
                child: isLoadingContributors
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                    : contributors.isEmpty
                    ? const Text(
                  'No contributors data available',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contributors.map((contributor) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${contributor.firstName ?? ''} ${contributor.lastName ?? ''}'.trim(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (contributor.primaryInstitution != null &&
                              contributor.primaryInstitution!.isNotEmpty)
                            Text(
                              contributor.primaryInstitution!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Material Type', style: detailsLabelStyle),
                      Text(widget.material.type ?? 'N/A')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Primary Author', style: detailsLabelStyle),
                      Text(widget.material.author != '' ? widget.material.author : '${widget.material.authorData?.firstName ?? 'N/A'} ${widget.material.authorData?.lastName ?? 'N/A'}')
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target Audience', style: detailsLabelStyle),
                      Text(
                        (widget.material.targetAudience != null && widget.material.targetAudience!.isNotEmpty)
                            ? widget.material.targetAudience!.join(', ')
                            : 'N/A',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accessible By', style: detailsLabelStyle),
                      Text(widget.material.accessibility?.join(', ') ?? 'N/A',)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Technical Format', style: detailsLabelStyle),
                      Text(widget.material.technicalFormat ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ]
      ),
    );
  }
}