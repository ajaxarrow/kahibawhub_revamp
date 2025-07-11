import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../layouts/material_details_layout.dart';
import '../../models/learning_material.dart';
import '../../utils/base64_image_utils.dart';

enum CardType {large, small}

class MaterialItem extends StatelessWidget {
  const MaterialItem({
    super.key,
    required this.material,
    required this.materialCardType
  });


  final LearningMaterial material;
  final CardType materialCardType;


  @override
  Widget build(BuildContext context) {
    String description = (material.description ?? 'N/A');
    int descLength = materialCardType == CardType.large ? 50 : 25;
    description = description.length > descLength ? '${description.substring(0, descLength)}...' : description;

    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MaterialDetailsLayout(material: material))
        );
      },
      child: materialCardType == CardType.large ? Card(
          elevation: 0,
          child: Container(
            width: MediaQuery.of(context).size.width - 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
              border: Border.all(
                color: const Color(0xffe4e4e4), // Border color
                width: 1, // Border width
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: material.image != null ? Image.memory(
                    base64ToBytes(material.image),
                      width: MediaQuery.of(context).size.width - 80,
                      height: 130,
                      fit: BoxFit.cover,
                    ) : Image.asset(
                    'lib/assets/images/placeholder.jpg',
                    width: MediaQuery.of(context).size.width - 80,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 4),
                      ],
                    ) : const SizedBox.shrink(),
                      Text(
                        material.title != null && material.title!.length > 25
                            ? '${material.title!.substring(0, 25)}...'
                            : material.title!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Color(0xff696974),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min, // Ensures the button size wraps its content
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const PhosphorIcon(
                                    PhosphorIconsDuotone.eye,
                                    size: 14,
                                    color: Color(0xff5856D6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                      material.views.toString()
                                  )

                                ],
                              ),
                              const SizedBox(width: 10),
                              const Text('|'),
                              const SizedBox(width: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const PhosphorIcon(
                                    color: Color(0xffFFCC00),
                                    PhosphorIconsDuotone.star,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                      material.ratings.toString()
                                  )

                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsDuotone.user,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              // Text(
                              //     '${material.primaryAuthor?.firstName ?? ''} ${material.primaryAuthor?.lastName ?? ''}'
                              // )
                              Text(material.author)
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
      ) : Card(
          elevation: 0,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
              border: Border.all(
                color: const Color(0xffe4e4e4), // Border color
                width: 1, // Border width
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  child: material.image != null ? Image.memory(
                    base64ToBytes(material.image),
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                  ): Image.asset(
                    'lib/assets/images/placeholder.jpg',
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 164,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.title != null && material.title!.length > 20
                              ? '${material.title!.substring(0, 20)}...'
                              : material.title!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          description,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff696974),
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min, // Ensures the button size wraps its content
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const PhosphorIcon(
                                      PhosphorIconsDuotone.eye,
                                      size: 12,
                                      color: Color(0xff5856D6),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      material.views.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    )

                                  ],
                                ),
                                const SizedBox(width: 10),
                                const Text('|', ),
                                const SizedBox(width: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const PhosphorIcon(
                                      color: Color(0xffFFCC00),
                                      PhosphorIconsDuotone.star,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                        material.ratings.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        )
                                    )

                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const PhosphorIcon(
                                  PhosphorIconsDuotone.user,
                                  size: 12,
                                ),
                                const SizedBox(width: 6),
                                // Text(
                                //     '${material.primaryAuthor?.firstName ?? ''} ${material.primaryAuthor?.lastName ?? ''}',
                                //     style: const TextStyle(
                                //       fontSize: 12,
                                //     )
                                // )
                                Text(material.author)

                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
