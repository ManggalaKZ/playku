class FrameModel {
  final String id;
  final String name;
  final String imagePath;
  final int price;

  FrameModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Tanpa Nama',
      imagePath: json['asset_url'] as String? ?? '',
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}
