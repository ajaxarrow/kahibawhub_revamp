import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../models/collaboration_request.dart';
import '../models/contributor.dart';
import '../models/learning_material.dart';
import '../models/material_update_request.dart';
import '../plugins/dio.config.dart';

class LearningMaterialController {
  Future<List<LearningMaterial>> fetchAll({int? limit}) async {
    try {
      final res = await dio.get('/apiBrowsing/getAllMaterials?type=browse');
      final List<LearningMaterial> materials = [];

      for (var item in res.data['formattedMaterials']) {
        final material = LearningMaterial.fromMap(item);
        materials.add(material);
      }

      // Apply limit if provided
      if (limit != null && limit > 0 && limit < materials.length) {
        return materials.sublist(0, limit);
      }
      return materials;
    } catch (e) {
      print("Error fetching all materials: $e");
      return [];
    }
  }

  Future<List<LearningMaterial>> fetchByUserID({int? limit, String userID = ''}) async {
    try {
      final res = await dio.get('/apiBrowsing/getAllMaterials?type=uploaded&userId=$userID');
      final List<LearningMaterial> materials = [];

      for (var item in res.data['formattedMaterials']) {
        final material = LearningMaterial.fromMap(item);
        materials.add(material);
      }

      // Apply limit if provided
      if (limit != null && limit > 0 && limit < materials.length) {
        return materials.sublist(0, limit);
      }

      return materials;
    } catch (e) {
      print("Error fetching all materials: $e");
      return [];
    }
  }

  Future<LearningMaterial> fetchLearningMaterialByID({required String userID, required String materialID}) async {
    try {
      print('/apiUpdatematerial/retrieveMaterialToUpdate/$userID/$materialID');

      final response = await dio.get(
        '/apiUpdatematerial/retrieveMaterialToUpdate/$userID/$materialID',
      );
      final data = response.data;
      return LearningMaterial.fromMap(data['material']);
    } catch (e) {
      if (e is DioException) {
        // Print full response for debugging
        print("DioException occurred:");
        print("Data: ${e.response?.data}");
        throw Exception('Failed to fetching material: ${e.response?.data ?? e.message}');
      } else {
        print("Unexpected error: $e");
        throw Exception('Failed to fetching material: ${e.toString()}');
      }
    }
  }

  Future<LearningMaterial> fetchLearningMaterialByIDWithMaterialFile({required String userID, required String materialID, required String fileHash}) async {
    try {
      final response = await dio.get(
        '/apiOpenMaterial/getMaterialDetails/$materialID/$userID?fileHash=$fileHash',
      );
      final data = response.data;
      return LearningMaterial.fromMap(data['materialData']);
    } catch (e) {
      if (e is DioException) {
        // Print full response for debugging
        print("DioException occurred:");
        print("Data: ${e.response?.data}");
        throw Exception('Failed to fetching material: ${e.response?.data ?? e.message}');
      } else {
        print("Unexpected error: $e");
        throw Exception('Failed to fetching material: ${e.toString()}');
      }
    }
  }

  // Updated addMaterial method
  Future<Map<String, dynamic>> addMaterial({
    required String userId,
    required File materialFile,
    File? materialImage,
    required String materialTitle,
    required String materialDescription,
    required String materialType,
    required List<String> disciplines,
    required List<String> targetAudience,
    required List<String> accessibility,
    required String technicalType,
    required List<String> contributorIds, // Changed from List<Contributor> to List<String>
  }) async {
    try {
      // Create FormData for multipart upload
      FormData formData = FormData.fromMap({
        'materialFile': await MultipartFile.fromFile(
          materialFile.path,
          filename: materialFile.path.split('/').last,
        ),
        'materialTitle': materialTitle,
        'materialDescription': materialDescription,
        'materialType': materialType,
        'disciplines': disciplines,
        'targetAudience': targetAudience,
        'materialAccessibility': accessibility,
        'technicalType': technicalType,
        'contributors': contributorIds, // Send as list of IDs
        'authorPermission': true
      });

      // Add image if provided
      if (materialImage != null) {
        formData.files.add(MapEntry(
          'materialImage',
          await MultipartFile.fromFile(
            materialImage.path,
            filename: materialImage.path.split('/').last,
          ),
        ));
      }

      final response = await dio.post(
        '/apiAddMaterial/addMaterial/$userId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return {
        'success': true,
        'material': response.data['material'],
        'collabRequest': response.data['collabRequest'],
      };
    } catch (e) {
      if (e is DioException) {
        // Print full response for debugging
        print("DioException occurred:");
        print("Data: ${e.response?.data}");
        throw Exception('Failed to add material: ${e.response?.data ?? e.message}');
      } else {
        print("Unexpected error: $e");
        throw Exception('Failed to add material: ${e.toString()}');
      }
    }
  }

// Updated updateMaterial method
  Future<Map<String, dynamic>> updateMaterial({
    required String materialId,
    required String userId,
    File? materialFile,
    File? materialImage,
    required String materialTitle,
    required String materialDescription,
    required String materialType,
    required List<String> disciplines,
    required List<String> targetAudience,
    required List<String> accessibility,
    required String technicalType,
    required List<String> contributorIds, // Changed from List<Contributor> to List<String>
  }) async {
    try {
      // Create FormData for multipart upload
      Map<String, dynamic> formDataMap = {
        'materialTitle': materialTitle,
        'materialDescription': materialDescription,
        'materialType': materialType,
        'disciplines': disciplines,
        'targetAudience': targetAudience,
        'materialAccessibility': accessibility,
        'technicalType': technicalType,
        'contributors': contributorIds, // Send as list of IDs
        'authorPermission': true
      };

      FormData formData = FormData.fromMap(formDataMap);

      // Add material file if provided
      if (materialFile != null) {
        formData.files.add(MapEntry(
          'materialFile',
          await MultipartFile.fromFile(
            materialFile.path,
            filename: materialFile.path.split('/').last,
          ),
        ));
      }

      // Add image if provided
      if (materialImage != null) {
        formData.files.add(MapEntry(
          'materialImage',
          await MultipartFile.fromFile(
            materialImage.path,
            filename: materialImage.path.split('/').last,
          ),
        ));
      }


      final response = await dio.put(
        '/apiUpdateMaterial/updateMaterial/$materialId/$userId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );


      return {
        'success': true,
        'material': response.data['material'],
      };
    } catch (e) {
      if (e is DioException) {
        print("DioException occurred:");
        print("Data: ${e.response?.data}");
        throw Exception('Failed to update material: ${e.response?.data ?? e.message}');
      } else {
        print("Unexpected error: $e");
        throw Exception('Failed to update material: ${e.toString()}');
      }
    }
  }

  Future<bool> deleteMaterial({
    required String materialId,
  }) async {
    try {
      await dio.put('/apiMaterialTransactions/deleteMaterial/$materialId');
      return true;
    } catch (e) {
      print("Error deleting material: $e");
      throw Exception('Failed to delete material: ${e.toString()}');
    }
  }

  Future<List<Contributor>> searchContributors(String query) async {
    try {
      final response = await dio.get(
        '/apiMaterialTransactions/getSuggestedUsers',
        queryParameters: {'search': query},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Contributor.fromJson(json)).toList();
    } catch (e) {
      print("Error searching contributors: $e");
      throw Exception('Failed to search contributors: ${e.toString()}');
    }
  }

  // Add this method to your LearningMaterialController class
  Future<List<Map<String, dynamic>>> getMyCollaborationRequests({
    required String userId,
    String? materialId,
  }) async {
    try {
      final response = await dio.get(
        '/apiCollaborations/getMyCollaborationRequestToOtherAuthors/$userId',
      );

      List<Map<String, dynamic>> requests = List<Map<String, dynamic>>.from(response.data['data']);

      // Filter by materialId if provided
      if (materialId != null) {
        requests = requests.where((request) => request['materialId'] == materialId).toList();
      }

      return requests;
    } catch (e) {
      if (e is DioException) {
        throw Exception('Failed to fetch collaboration requests: ${e.response?.data ?? e.message}');
      } else {
        throw Exception('Failed to fetch collaboration requests: ${e.toString()}');
      }
    }
  }

  Future<List<CollaborationRequest>> getPendingCollabRequests({required String userID}) async {
    try {
      final response = await dio.get('/apiCollaborations/getPendingCollabRequestsFromOtherAuthors/$userID');
      final data = response.data;
      List<CollaborationRequest> collaborations = [];

      if (data['data'] != null) {
        for (var item in data['data']) {
          collaborations.add(CollaborationRequest.fromMap(item));
        }
      }

      return collaborations;
    } catch (e) {
      if (e is DioException) {
        throw Exception('Failed to fetch collaboration requests: ${e.response?.data ?? e.message}');
      } else {
        throw Exception('Failed to fetch collaboration requests: ${e.toString()}');
      }
    }
  }

  Future<void> acceptCollaboration({required String requestId, required String authorId}) async {
    try {
      await dio.post('/apiCollaborations/acceptCollaboration/$requestId/$authorId');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Failed to accept collaboration: ${e.response?.data ?? e.message}');
      } else {
        throw Exception('Failed to accept collaboration: ${e.toString()}');
      }
    }
  }

  Future<void> rejectCollaboration({required String requestId, required String authorId}) async {
    try {
      await dio.post('/apiCollaborations/rejectCollaboration/$requestId/$authorId');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Failed to reject collaboration: ${e.response?.data ?? e.message}');
      } else {
        throw Exception('Failed to reject collaboration: ${e.toString()}');
      }
    }
  }

  // Send material update request (for contributors)
  Future<Map<String, dynamic>> sendMaterialUpdateRequest({
    required String userId,
    required String materialId,
    File? updatedMaterialFile,
    File? updatedMaterialImage,
    required String updatedMaterialTitle,
    required String updatedMaterialDescription,
    required String updatedMaterialType,
    required String updatedTechnicalType,
    required List<String> updatedTargetAudience,
    required List<String> updatedDisciplines,
    required String primaryAuthorID,
    required List<String> updatedContributors,
    int timeSet = 604800,
  }) async {
    try {
      print(updatedContributors);
      FormData formData = FormData.fromMap({
        'UpdatedMaterialTitle': updatedMaterialTitle,
        'UpdatedMaterialDescription': updatedMaterialDescription,
        'UpdatedMaterialType': updatedMaterialType,
        'UpdatedTechnicalType': updatedTechnicalType,
        'UpdatedTargetAudience': jsonEncode(updatedTargetAudience),
        'UpdatedDisciplines': jsonEncode(updatedDisciplines),
        'UpdatedContributors': updatedContributors,
        'UpdatedPrimaryAuthor': primaryAuthorID,
        'timeSet': timeSet.toString(),
        // 'requestedTo': jsonEncode([
        //   {'authorId': primaryAuthorID}
        // ]),
      });

      // Add files if provided
      if (updatedMaterialFile != null) {
        formData.files.add(MapEntry(
          'UpdatedMaterialFile',
          await MultipartFile.fromFile(
            updatedMaterialFile.path,
            filename: updatedMaterialFile.path.split('/').last,
          ),
        ));
      }

      if (updatedMaterialImage != null) {
        formData.files.add(MapEntry(
          'UpdatedMaterialImage',
          await MultipartFile.fromFile(
            updatedMaterialImage.path,
            filename: updatedMaterialImage.path.split('/').last,
          ),
        ));
      }

      print("=== Raw FormData ===");
      formData.fields.forEach((field) {
        print("${field.key}: ${field.value}");
      });
      formData.files.forEach((file) {
        print("${file.key}: ${file.value.filename}");
      });
      print('/apiUpdatematerial/sendMaterialUpdateRequest/$userId/$materialId');
      final response = await dio.post(
        '/apiUpdatematerial/sendMaterialUpdateRequest/$userId/$materialId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',

        ),
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Update request sent successfully',
        'data': response.data
      };
    } catch (e) {
      if (e is DioException) {
        print("Error sending update request failed: ${e.response?.data}");
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to send update request'
        };
      }
      return {
        'success': false,
        'message': 'Error sending update request: $e'
      };
    }
  }

  // Get all update requests for a user (as reviewer/collaborator)
  Future<List<MaterialUpdateRequest>> getAllUpdateRequests(String userId) async {
    try {
      final response = await dio.get(
        '/apiUpdatematerial/getAllUpdateRequests/$userId',
      );

      if (response.data['success'] == true) {
        final List<dynamic> requestsData = response.data['data'] ?? [];
        return requestsData
            .map((data) => MaterialUpdateRequest.fromJson(data))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching update requests: $e');
    }
  }

  // Get all my requests to update (as requester)
  Future<List<MaterialUpdateRequest>> getAllMyRequestToUpdate(String userId) async {
    try {
      final response = await dio.get(
        '/apiUpdatematerial/getAllMyRequestToUpdate/$userId',
      );

      if (response.data['success'] == true) {
        final List<dynamic> requestsData = response.data['data'] ?? [];
        return requestsData
            .map((data) => MaterialUpdateRequest.fromJson(data))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching my update requests: $e');
    }
  }

  // Get contributor responses for a specific material update request
  Future<MaterialUpdateRequest?> getContributorResponses(
      String userId, String materialId) async {
    try {
      final response = await dio.get(
        '/apiUpdatematerial/getContributorResponses/$userId/$materialId',
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return MaterialUpdateRequest.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching contributor responses: $e');
    }
  }

  // Review material update (preview the pending update)
  Future<UpdateRequestPreview?> reviewMaterialUpdate(
      String userId, String materialId) async {
    try {
      final response = await dio.get(
        '/apiUpdatematerial/reviewMaterialUpdate/$userId/$materialId',
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return UpdateRequestPreview.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Error reviewing material update: $e');
    }
  }

  // Accept update request
  Future<Map<String, dynamic>> acceptUpdate(
      String userId, String materialId) async {
    try {
      final response = await dio.post(
        '/apiUpdatematerial/acceptUpdate/$userId/$materialId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Update accepted successfully',
        'data': response.data
      };
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to accept update'
        };
      }
      return {
        'success': false,
        'message': 'Error accepting update: $e'
      };
    }
  }

  // Reject update request
  Future<Map<String, dynamic>> rejectUpdate(
      String userId, String materialId, String reason) async {
    try {
      final response = await dio.post(
        '/apiUpdatematerial/rejectUpdate/$userId/$materialId',
        data: {'reason': reason},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Update rejected successfully',
        'data': response.data
      };
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to reject update'
        };
      }
      return {
        'success': false,
        'message': 'Error rejecting update: $e'
      };
    }
  }

  // Revise update request
  Future<Map<String, dynamic>> reviseUpdateRequest({
    required String userId,
    required String materialId,
    File? updatedMaterialFile,
    File? updatedMaterialImage,
    required String updatedMaterialTitle,
    required String updatedMaterialDescription,
    required String updatedMaterialType,
    required String updatedTechnicalType,
    required List<String> updatedTargetAudience,
    required List<String> updatedDisciplines,
    required List<Contributor> updatedContributors,
  }) async {
    try {
      // Create FormData for multipart upload
      FormData formData = FormData.fromMap({
        'UpdatedMaterialTitle': updatedMaterialTitle,
        'UpdatedMaterialDescription': updatedMaterialDescription,
        'UpdatedMaterialType': updatedMaterialType,
        'UpdatedTechnicalType': updatedTechnicalType,
        'UpdatedTargetAudience': jsonEncode(updatedTargetAudience),
        'UpdatedDisciplines': jsonEncode(updatedDisciplines),
        'UpdatedContributors': jsonEncode(
            updatedContributors.map((c) => c.toJson()).toList()
        ),
      });

      // Add files if provided
      if (updatedMaterialFile != null) {
        formData.files.add(MapEntry(
          'UpdatedMaterialFile',
          await MultipartFile.fromFile(
            updatedMaterialFile.path,
            filename: updatedMaterialFile.path.split('/').last,
          ),
        ));
      }

      if (updatedMaterialImage != null) {
        formData.files.add(MapEntry(
          'UpdatedMaterialImage',
          await MultipartFile.fromFile(
            updatedMaterialImage.path,
            filename: updatedMaterialImage.path.split('/').last,
          ),
        ));
      }

      final response = await dio.put(
        '/apiUpdatematerial/reviseUpdateRequest/$userId/$materialId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Update request revised successfully',
        'data': response.data
      };
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to revise update request'
        };
      }
      return {
        'success': false,
        'message': 'Error revising update request: $e'
      };
    }
  }

  // Delete update request
  Future<Map<String, dynamic>> deleteUpdateRequest(String materialId) async {
    try {
      final response = await dio.delete(
        '/apiUpdatematerial/deleteUpdateRequest/$materialId',
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Update request deleted successfully',
        'data': response.data
      };
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to delete update request'
        };
      }
      return {
        'success': false,
        'message': 'Error deleting update request: $e'
      };
    }
  }
}