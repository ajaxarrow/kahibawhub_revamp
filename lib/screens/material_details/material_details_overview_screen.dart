import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/learning_material.dart';
import '../../themes/styles.dart';


class MaterialDetailsOverviewScreen extends StatelessWidget {
  const MaterialDetailsOverviewScreen({super.key, required this.material});

  final LearningMaterial material;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 8,),
            material.disciplines!.isNotEmpty
                ? Column(
              children: [
                SizedBox(
                  height: 30, // Set a fixed height for the list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: material.disciplines!.length,
                    itemBuilder: (context, index) {
                      final discipline = material.disciplines![index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xffDDDDDD),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          discipline,
                          style: const TextStyle(
                            color: Color(0xff888888),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ) : const SizedBox.shrink(),
            Text(
              material.description ?? '',
                textAlign: TextAlign.justify

            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Material Type', style: detailsLabelStyle),
                      Text(material.type ?? 'N/A')
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Primary Author', style: detailsLabelStyle),
                      // Text(
                      //   '${material.primaryAuthor?.firstName ?? 'N/A'} ${material.primaryAuthor?.lastName ?? 'N/A'}',
                      // ),
                      Text(material.author)
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('Date Added', style: detailsLabelStyle),
            //           Text(DateFormat('MMMM d, y').format(material.dateCreated!)?? 'N/A')
            //         ],
            //       ),
            //     ),
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('Date Modified', style: detailsLabelStyle),
            //           Text(DateFormat('MMMM d, y').format(material.dateCreated!)?? 'N/A')
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text('Primary Audience', style: detailsLabelStyle),
                //       Text(
                //         material.targetAudience?.join(', ') ?? 'N/A',
                //       ),
                //     ],
                //   ),
                // ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accessible By', style: detailsLabelStyle),
                      Text(material.accessibility?.join(', ') ?? 'N/A',)],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Technical Format', style: detailsLabelStyle),
                      Text(material.technicalFormat ?? 'N/A'),
                      // Text('N/A')
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Primary Institution', style: detailsLabelStyle),
                      Text(material.primaryInstitution ?? '0'),
                    ],
                  ),
                ),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text('Page Numbers', style: detailsLabelStyle),
                //       // Text(material.title ?? '0'),
                //       const Text('N/A')
                //     ],
                //   ),
                // ),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text('Word Count', style: detailsLabelStyle),
                //       // Text(material.title ?? 'N/A'),
                //       const Text('N/A')
                //     ],
                //   ),
                // ),
              ],
            ),
          ]
        ),
      );
  }
}
