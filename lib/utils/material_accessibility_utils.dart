import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/learning_material.dart';
import '../models/app_user.dart';
import '../themes/colors.dart';

class MaterialAccessibilityUtils {
  /// Checks if a user can access a material based on their user type and the material's accessibility settings
  static bool canUserAccessMaterial(AppUser? user, LearningMaterial material) {
    // If no user is logged in, deny access
    if (user == null) return false;
    
    // Primary author and contributors can always access
    if (material.primaryAuthorID == user.id) return true;
    if (material.getContributorIds().contains(user.id)) return true;
    
    // If material has no accessibility restrictions, allow access to authors/contributors only
    if (material.accessibility == null || material.accessibility!.isEmpty) {
      return false; // Only authors and contributors can view
    }
    
    // Check user's profile type against material accessibility
    final userType = user.userProfile?.userType?.toLowerCase();
    if (userType == null) return false;
    
    // Convert accessibility list to lowercase for case-insensitive comparison
    final accessibilityTypes = material.accessibility!.map((type) => type.toLowerCase()).toList();
    
    // Check if user type matches any of the accessibility types
    switch (userType) {
      case 'faculty':
        return accessibilityTypes.contains('faculty');
      case 'student':
        return accessibilityTypes.contains('student');
      default:
        return false;
    }
  }
  
  /// Gets the accessibility restriction message for display
  static String getAccessibilityMessage(LearningMaterial material) {
    if (material.accessibility == null || material.accessibility!.isEmpty) {
      return 'This material is only accessible to the author and contributors.';
    }
    
    final accessibilityTypes = material.accessibility!;
    if (accessibilityTypes.length == 1) {
      return 'This material is only accessible to: ${accessibilityTypes.first}';
    } else {
      final lastType = accessibilityTypes.last;
      final otherTypes = accessibilityTypes.sublist(0, accessibilityTypes.length - 1).join(', ');
      return 'This material is only accessible to: $otherTypes and $lastType';
    }
  }
  
  /// Shows accessibility denied dialog
  static void showAccessibilityDialog(BuildContext context, LearningMaterial material) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              PhosphorIcon(
                PhosphorIconsRegular.lockKey,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Access Restricted',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getAccessibilityMessage(material),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.info,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Contact the author if you need access to this material.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Understood',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}