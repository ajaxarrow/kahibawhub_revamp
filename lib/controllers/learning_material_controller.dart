import 'dart:io';

import 'package:dio/dio.dart';

import '../models/learning_material.dart';
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
      print(userID);
      final response = await dio.get(
        '/apiUpdatematerial/retrieveMaterialToUpdate/$userID/$materialID',
      );
      final data = response.data;
      return LearningMaterial.fromMap(data['material']);
    } catch (e) {
      print('Fetching of Learning Material failed: $e');
      rethrow;
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
      print('Fetching of Learning Material failed: $e');
      rethrow;
    }
  }

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
    required String technicalType
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
        // 'primaryInstitution': primaryInstitution,
        'targetAudience': targetAudience,
        'materialAccessibility': accessibility,
        'technicalType': technicalType,
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
      print("Error adding material: $e");
      throw Exception('Failed to add material: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateMaterial({
    required String materialId,
    required String userId,
    File? materialFile,
    File? materialImage,
    required String materialTitle,
    required String materialDescription,
    required String materialType,
    required List<String> disciplines,
    // required String primaryInstitution,
    List<String>? targetAudience,
    List<String>? accessibility,
    required String technicalType,
  }) async {
    try {
      // Create FormData for multipart upload
      FormData formData = FormData.fromMap({
        'materialTitle': materialTitle,
        'materialDescription': materialDescription,
        'materialType': materialType,
        'disciplines': disciplines,
        // 'primaryInstitution': primaryInstitution,
        'targetAudience': targetAudience,
        'materialAccessibility': accessibility,
        'technicalType': technicalType,
      });

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
        '/apiUpdatematerial/updateMaterial/$userId/$materialId',
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
      print("Error updating material: $e");
      throw Exception('Failed to update material: ${e.toString()}');
    }
  }

  Future<bool> deleteMaterial({
    required String materialId,
    required String userId,
  }) async {
    try {
      await dio.delete('/apiAddMaterial/deleteMaterial/$materialId/$userId');
      return true;
    } catch (e) {
      print("Error deleting material: $e");
      throw Exception('Failed to delete material: ${e.toString()}');
    }
  }

}
