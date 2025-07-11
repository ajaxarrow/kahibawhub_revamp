

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
  });

  final dynamic id;
  final dynamic file;
  final String? title;
  final String? description;
  final dynamic primaryAuthorID;
  AppUser? primaryAuthor;
  final List<dynamic>? contributors;
  final String? type;
  final DateTime? dateCreated;
  final List<String>? targetAudience;
  final List<String>? disciplines;
  final dynamic image;
  final List<String>? accessibility;
  final bool? authorPermission;
  final int views;
  final double ratings;
  final String author;
  final String? technicalFormat;
  final String primaryInstitution;


  factory LearningMaterial.fromMap(Map<String, dynamic> map) {
    return LearningMaterial(
      id: map['_id'],
      file: map['materialFile'],
      title: map['materialTitle'],
      description: map['materialDescription'],
      primaryAuthorID: map['primaryAuthor'],
      contributors: List<dynamic>.from(map['contributors'] ?? []),
      type: map['materialType'],
      dateCreated: map['dateUploaded'] ,
      targetAudience: List<String>.from(map['targetAudience'] ?? []),
      disciplines: List<String>.from(map['disciplines'] ?? []),
      image: map['materialImage'],
      accessibility: List<String>.from(map['materialAccessibility'] ?? []),
      authorPermission: map['authorPermission'],
      views: map['totalReads'] ?? 0,
      ratings: (map['averageRatings'] as num?)?.toDouble() ?? 0.0,
      author: map['primaryAuthor'],
      technicalFormat: map['technicalType'] ?? '',
      primaryInstitution: map['primaryInstitution'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'materialFile': file,
      'materialTitle': title,
      'materialDescription': description,
      'primaryAuthor': primaryAuthor,
      'contributors': contributors ?? [],
      'materialType': type,
      'dateUploaded': dateCreated?.toIso8601String(),
      'targetAudience': targetAudience ?? [],
      'disciplines': disciplines ?? [],
      'materialImage': image,
      'materialAccessibility': accessibility ?? [],
      'authorPermission': authorPermission,
      'totalComments': views,
      'averageRatings': ratings,
    };
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
      type: $type,
      dateCreated: ${dateCreated?.toIso8601String()},
      targetAudience: $targetAudience,
      disciplines: $disciplines,
      image: $image,
      accessibility: $accessibility,
      authorPermission: $authorPermission,
      views: $views,
      ratings: $ratings
    )''';
  }
}
