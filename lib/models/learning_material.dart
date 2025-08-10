import 'package:kahibawhub_revamp/models/contributor.dart';
import 'app_user.dart';

class LearningMaterial {
  LearningMaterial({
    this.id,
    this.file,
    this.title,
    this.description,
    this.primaryAuthorID,
    this.primaryAuthor,
    this.contributors,
    this.contributorIds, // Add this field for storing just IDs
    this.type,
    this.dateCreated,
    this.targetAudience,
    this.image,
    this.accessibility,
    this.authorPermission,
    this.views = 0,
    this.ratings = 0,
    this.disciplines,
    this.author = '',
    this.technicalFormat,
    this.primaryInstitution = '',
    this.authorData,
    this.canEdit = false,
    this.fileHash,
    this.hasPendingUpdates = false,
    this.materialFile
  });

  final dynamic id;
  dynamic file;
  final String? title;
  final String? fileHash;
  final String? description;
  final dynamic primaryAuthorID;
  AppUser? primaryAuthor;
  List<Contributor>? contributors;
  List<String>? contributorIds; // Add this field
  final String? type;
  final String? dateCreated;
  List<String>? targetAudience;
  final List<String>? disciplines;
  dynamic image;
  final List<String>? accessibility;
  final bool? authorPermission;
  final int views;
  final double ratings;
  final String author;
  final String? technicalFormat;
  final String primaryInstitution;
  bool canEdit;
  AppUser? authorData;
  final bool hasPendingUpdates;
  final String? materialFile;

  factory LearningMaterial.fromMap(Map<String, dynamic> map) {
    // Handle contributors conditionally
    List<Contributor>? contributorObjects;
    List<String>? contributorIdsList;

    if (map['contributors'] != null) {
      final contributorsData = map['contributors'] as List<dynamic>;
      if (contributorsData.isNotEmpty) {
        // Check if the first item is a string (ID) or object
        if (contributorsData.first is String) {
          // Contributors are stored as IDs
          contributorIdsList = contributorsData.cast<String>();
        } else {
          // Contributors are stored as objects
          contributorObjects = contributorsData
              .map((e) => Contributor.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return LearningMaterial(
      id: map['_id'],
      file: map['materialFile'],
      title: map['materialTitle'],
      description: map['materialDescription'],
      primaryAuthorID: map['primaryAuthor'] is String ? map['primaryAuthor'] as String : '',
      contributors: contributorObjects,
      contributorIds: contributorIdsList,
      type: map['materialType'],
      dateCreated: map['dateUploaded'],
      targetAudience: List<String>.from(map['targetAudience'] ?? []),
      disciplines: List<String>.from(map['disciplines'] ?? []),
      image: map['materialImage'],
      accessibility: List<String>.from(map['materialAccessibility'] ?? []),
      authorPermission: map['authorPermission'],
      views: map['totalReads'] ?? 0,
      ratings: (map['averageRatings'] as num?)?.toDouble() ?? 0.0,
      author: map['primaryAuthor'] is String ? map['primaryAuthor'] as String : '',
      technicalFormat: map['technicalType'] ?? '',
      primaryInstitution: map['primaryInstitution'] ?? '',
      fileHash: map['fileHash'] as String? ?? '',
      authorData: map['primaryAuthor'] is Map
          ? AppUser.fromMap(map['primaryAuthor'])
          : null,
      hasPendingUpdates: map['hasPendingUpdates'] ?? false,
      materialFile: map['materialFile'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'materialFile': file,
      'materialTitle': title,
      'materialDescription': description,
      'primaryAuthor': primaryAuthor,
      'contributors': contributorIds ?? contributors?.map((c) => c.toJson()).toList() ?? [],
      'materialType': type,
      'dateUploaded': dateCreated,
      'targetAudience': targetAudience ?? [],
      'disciplines': disciplines ?? [],
      'materialImage': image,
      'materialAccessibility': accessibility ?? [],
      'authorPermission': authorPermission,
      'totalComments': views,
      'averageRatings': ratings,
      'hasPendingUpdates': hasPendingUpdates,
    };
  }

  // Helper method to get contributor IDs regardless of how they're stored
  List<String> getContributorIds() {
    if (contributorIds != null && contributorIds!.isNotEmpty) {
      return contributorIds!;
    }
    if (contributors != null && contributors!.isNotEmpty) {
      return contributors!.map((c) => c.id).toList();
    }
    return [];
  }

  @override
  String toString() {
    return '''
    LearningMaterial(
      id: ${id.toString()},
      title: $title,
      description: $description,
      filePath: $file,
      primaryAuthor: $primaryAuthor,
      contributors: ${contributors?.map((e) => e).toList()},
      contributorIds: $contributorIds,
      type: $type,
      dateCreated: $dateCreated,
      targetAudience: $targetAudience,
      disciplines: $disciplines,
      image: $image,
      accessibility: $accessibility,
      authorPermission: $authorPermission,
      views: $views,
      ratings: $ratings,
      hasPendingUpdates: $hasPendingUpdates
    )''';
  }
}