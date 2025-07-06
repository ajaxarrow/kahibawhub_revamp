class ImageData{
  ImageData({this.type, required this.data});

  final String? type;
  final List<dynamic> data;

  factory ImageData.fromMap(Map<String, dynamic> map) {
    return ImageData(
      type: map['type'],
      data: List<dynamic>.from(map['data'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
    };
  }


}