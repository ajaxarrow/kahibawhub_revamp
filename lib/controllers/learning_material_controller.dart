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

}
