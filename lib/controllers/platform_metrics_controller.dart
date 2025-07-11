import 'package:kahibawhub_revamp/models/platform_metrics.dart';

import '../plugins/dio.config.dart';

class PlatformMetricsController {
  Future<PlatformMetrics> fetchMetrics() async {
    try {
      final res = await dio.get('/getAnalytics');
      return PlatformMetrics.fromMap(res.data);
    } catch (e) {
      print("Error fetching metrics: $e");
      return PlatformMetrics();
    }
  }
}