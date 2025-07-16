import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/controllers/platform_metrics_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../controllers/learning_material_controller.dart';
import '../../layouts/main_layout.dart';
import '../../models/learning_material.dart';
import '../../models/platform_metrics.dart';
import '../../providers/auth_provider.dart';
import '../../themes/colors.dart';
import '../../widgets/materials/material_item.dart';

class DashboardScreen extends ConsumerStatefulWidget {

  const DashboardScreen({super.key, });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return MainLayout(
      index: 0,
      title: 'Dashboard',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xffe3d0ce),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Hello ${user != null ? user.firstName : 'User'}!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Explore KahibawHub’s curated selection of educational resources to broaden your horizons.',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 25, top: 10, right: 25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Analytics Overview',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.of(context).pushNamed('/engagements');
                        //   },
                        //   child: const Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Text('See All'),
                        //       SizedBox(width: 6),
                        //       PhosphorIcon(PhosphorIconsRegular.caretRight, size: 16),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    FutureBuilder<PlatformMetrics>(
                      future: PlatformMetricsController().fetchMetrics(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Center(child: Text('Error loading analytics data'));
                        }

                        final metrics = snapshot.data!;
                        final analyticsData = [
                          {
                            'label': 'Users',
                            'value': metrics.totalUsers,
                            'icon': PhosphorIconsRegular.users,
                            'color': primaryColor,
                          },
                          {
                            'label': 'Materials',
                            'value': metrics.totalMaterials,
                            'icon': PhosphorIconsRegular.books,
                            'color': successColor,
                          },
                          {
                            'label': 'Reads',
                            'value': metrics.totalReads,
                            'icon': PhosphorIconsRegular.eye,
                            'color': successColor,
                          },
                          {
                            'label': 'Institutions',
                            'value': metrics.totalInstitutions,
                            'icon': PhosphorIconsRegular.buildings,
                            'color': primaryColor,
                          },
                        ];

                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: analyticsData.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            mainAxisExtent: 140,
                          ),
                          itemBuilder: (context, index) {
                            final data = analyticsData[index];
                            final value = data['value'] as int;
                            final label = data['label'] as String;
                            final icon = data['icon'] as PhosphorIconData;
                            final color = data['color'] as Color;

                            return Card(
                              elevation: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: 1),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            value.toString(),
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: PhosphorIcon(
                                              icon,
                                              size: 20,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12.0),
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          color: Color(0xff696974),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      // Optional: Add a subtle progress indicator or accent line
                                      Container(
                                        height: 3,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Popular Materials',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/all-materials');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('See All'),
                              SizedBox(width: 6),
                              PhosphorIcon(PhosphorIconsRegular.caretRight, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder<List<LearningMaterial>>(
                      future: LearningMaterialController().fetchAll(limit: 2), // Fetching materials
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No materials available"));
                        } else {
                          // Display materials
                          return SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: MaterialItem(
                                    material: snapshot.data![index],
                                    materialCardType: CardType.large,
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
