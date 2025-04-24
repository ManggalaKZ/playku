class FrameModel {
  final String id;
  final String name;
  final String imagePath; // Ini akan berisi URL dari Supabase Storage
  final int price;

  FrameModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
  });

  // Factory constructor untuk membuat instance FrameModel dari JSON
  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      // Pastikan nama kunci 'id', 'name', 'asset_url', 'price'
      // sesuai dengan nama kolom di tabel 'borders' Supabase Anda.
      id: json['id'] as String? ?? '', // Ambil 'id', default ke string kosong jika null
      name: json['name'] as String? ?? 'Tanpa Nama', // Ambil 'name', default jika null
      imagePath: json['asset_url'] as String? ?? '', // Ambil 'asset_url' untuk imagePath, default jika null
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price']?.toString() ?? '0') ?? 0, // Ambil 'price', handle jika bukan int
    );
  }

  // (Opsional) Anda bisa menambahkan method toJson jika perlu mengirim data FrameModel kembali
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'asset_url': imagePath, // Gunakan nama kolom Supabase
  //     'price': price,
  //   };
  // }
}
