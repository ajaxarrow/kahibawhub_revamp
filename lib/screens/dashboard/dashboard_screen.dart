import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../controllers/learning_material_controller.dart';
import '../../layouts/main_layout.dart';
import '../../models/learning_material.dart';
import '../../widgets/materials/material_item.dart';

class DashboardScreen extends StatelessWidget {

  const DashboardScreen({super.key, });

  @override
  Widget build(BuildContext context) {
    final analyticsData = [
      {"label": "Users", "value": 230, "rate": 3.0, "indication": "down"},
      {"label": "Contributors", "value": 312, "rate": 3.0, "indication": "down"},
      {"label": "Read", "value": 558, "rate": 3.0, "indication": "up"},
      {"label": "Institutions", "value": 20, "rate": 3.7, "indication": "up"},
    ];

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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Hello User!',
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
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        mainAxisExtent: 140,
                      ),
                      itemCount: analyticsData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xffe4e4e4), width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (analyticsData[index]['value'] as int).toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    analyticsData[index]['label'] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xff696974)),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        analyticsData[index]['indication'] as String == 'up' ? '+' : '-',
                                        style: TextStyle(
                                          color: analyticsData[index]['indication'] as String == 'up'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      Text(
                                        (analyticsData[index]['rate'] as double).toString(),
                                        style: TextStyle(
                                          color: analyticsData[index]['indication'] as String == 'up'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      PhosphorIcon(
                                        analyticsData[index]['indication'] as String == 'up'
                                            ? PhosphorIconsRegular.arrowUp
                                            : PhosphorIconsRegular.arrowDown,
                                        size: 14,
                                        color: analyticsData[index]['indication'] as String == 'up'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
