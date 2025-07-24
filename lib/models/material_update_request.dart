import 'package:kahibawhub_revamp/models/contributor.dart';

class MaterialUpdateRequest {
  final String id;
  final String materialId;
  final String materialTitle;
  final String materialDescription;
  final String requestedBy;
  final String requestedByName;
  final List<ContributorResponse> requestedTo;
  final String status; // 'pending', 'accepted', 'For Revision', 'expired'
  final String timeRemaining;
  final String formattedTime;
  final String? updatedMaterialTitle;
  final String? updatedMaterialDescription;
  final String? updatedMaterialType;
  final String? updatedTechnicalType;
  final List<String>? updatedTargetAudience;
  final List<String>? updatedDisciplines;
  final List<Contributor>? updatedContributors;

  MaterialUpdateRequest({
    required this.id,
    required this.materialId,
    required this.materialTitle,
    required this.materialDescription,
    required this.requestedBy,
    required this.requestedByName,
    required this.requestedTo,
    required this.status,
    required this.timeRemaining,
    required this.formattedTime,
    this.updatedMaterialTitle,
    this.updatedMaterialDescription,
    this.updatedMaterialType,
    this.updatedTechnicalType,
    this.updatedTargetAudience,
    this.updatedDisciplines,
    this.updatedContributors,
  });

  factory MaterialUpdateRequest.fromJson(Map<String, dynamic> json) {
    return MaterialUpdateRequest(
      id: json['_id'] ?? '',
      materialId: json['materialId'] ?? '',
      materialTitle: json['materialTitle'] ?? '',
      materialDescription: json['materialDescription'] ?? '',
      requestedBy: json['requestedBy'] ?? '',
      requestedByName: json['requestedByName'] ?? '',
      requestedTo: (json['requestedTo'] as List<dynamic>?)
          ?.map((e) => ContributorResponse.fromJson(e))
          .toList() ?? [],
      status: json['requestStatus'] ?? 'pending',
      timeRemaining: json['timeRemaining'] ?? '',
      formattedTime: json['formattedTime'] ?? '',
      updatedMaterialTitle: json['updatedMaterialTitle'],
      updatedMaterialDescription: json['updatedMaterialDescription'],
      updatedMaterialType: json['updatedMaterialType'],
      updatedTechnicalType: json['updatedTechnicalType'],
      updatedTargetAudience: json['updatedTargetAudience'] != null
          ? List<String>.from(json['updatedTargetAudience'])
          : null,
      updatedDisciplines: json['updatedDisciplines'] != null
          ? List<String>.from(json['updatedDisciplines'])
          : null,
      updatedContributors: (json['updatedContributors'] as List<dynamic>?)
          ?.map((e) => Contributor.fromJson(e))
          .toList(),
    );
  }
}

class ContributorResponse {
  final String authorId;
  final String authorName;
  final String authorAction; // 'pending', 'accepted', 'rejected'
  final String? rejectReason;

  ContributorResponse({
    required this.authorId,
    required this.authorName,
    required this.authorAction,
    this.rejectReason,
  });

  factory ContributorResponse.fromJson(Map<String, dynamic> json) {
    return ContributorResponse(
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAction: json['authorAction'] ?? 'pending',
      rejectReason: json['rejectReason'],
    );
  }
}

class UpdateRequestPreview {
  final String materialId;
  final String requestId;
  final String channelId;
  final String timeRemaining;
  final String formattedTime;
  final String status;
  final String updatedTitle;
  final String updatedDescription;
  final String updatedType;
  final String updatedTechnicalType;
  final List<String> updatedTargetAudience;
  final List<String> updatedDisciplines;
  final String updatedPrimaryAuthor;
  final List<Contributor> updatedContributors;
  final String? fileBase64;
  final String? imageBase64;
  final int? pageCount;
  final int? wordCount;

  UpdateRequestPreview({
    required this.materialId,
    required this.requestId,
    required this.channelId,
    required this.timeRemaining,
    required this.formattedTime,
    required this.status,
    required this.updatedTitle,
    required this.updatedDescription,
    required this.updatedType,
    required this.updatedTechnicalType,
    required this.updatedTargetAudience,
    required this.updatedDisciplines,
    required this.updatedPrimaryAuthor,
    required this.updatedContributors,
    this.fileBase64,
    this.imageBase64,
    this.pageCount,
    this.wordCount,
  });

  factory UpdateRequestPreview.fromJson(Map<String, dynamic> json) {
    return UpdateRequestPreview(
      materialId: json['materialId'] ?? '',
      requestId: json['requestId'] ?? '',
      channelId: json['channelId'] ?? '',
      timeRemaining: json['timeRemaining'] ?? '',
      formattedTime: json['formattedTime'] ?? '',
      status: json['requestStatus'] ?? '',
      updatedTitle: json['updatedTitle'] ?? '',
      updatedDescription: json['updatedDescription'] ?? '',
      updatedType: json['updatedType'] ?? '',
      updatedTechnicalType: json['updatedTechnicalType'] ?? '',
      updatedTargetAudience: List<String>.from(json['updatedTargetAudience'] ?? []),
      updatedDisciplines: List<String>.from(json['updatedDisciplines'] ?? []),
      updatedPrimaryAuthor: json['updatedPrimaryAuthor'] ?? '',
      updatedContributors: (json['updatedContributors'] as List<dynamic>?)
          ?.map((e) => Contributor.fromJson(e))
          .toList() ?? [],
      fileBase64: json['fileBase64'],
      imageBase64: json['imageBase64'],
      pageCount: json['pageCount'],
      wordCount: json['wordCount'],
    );
  }
}