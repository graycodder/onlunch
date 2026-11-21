class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String videoUrl;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.videoUrl,
    this.isActive = true,
  });

  factory BannerModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return BannerModel(
      id: id,
      title: map['title']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? '',
      isActive: map['isActive'] == null ? true : (map['isActive'] as bool),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isActive': isActive,
    };
  }
}

