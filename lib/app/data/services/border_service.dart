import 'package:playku/app/data/models/frame_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import model jika ada, contoh:
// import 'package:playku/app/data/models/border_model.dart';

class BorderService {
  static SupabaseClient client = Supabase.instance.client;
  static String tableName = 'border'; // Nama tabel Supabase Anda

  /// Mengambil semua data dari tabel 'border'.
  /// Anda bisa menambahkan parameter filter jika diperlukan.
  static Future<List<FrameModel>> fetchBorders() async {
    try {
      final response = await client.from("border").select();

      // Jika Anda menggunakan PostgREST response format (default)
      if (response is List) {
        // Ubah baris ini untuk melakukan mapping eksplisit
        return response
            .map((item) => FrameModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      // Handle format lain jika perlu, atau jika ada error spesifik dari Supabase
      else {
        print(
            'Unexpected response format from Supabase: ${response.runtimeType}');
        // Atau throw exception jika format tidak dikenali
        // throw Exception('Failed to load borders: Unexpected response format');
        return []; // Kembalikan list kosong jika format tidak sesuai
      }
    } catch (e) {
      // Handle error, misalnya log error atau tampilkan pesan ke user
      print('Error fetching borders: $e');
      // Anda bisa melempar ulang error atau mengembalikan list kosong
      // throw Exception('Failed to load borders: $e');
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  

  // Anda bisa menambahkan fungsi lain di sini sesuai kebutuhan,
  // misalnya untuk menambah, mengubah, atau menghapus data border.
  // Contoh:
  // Future<void> addBorder(BorderModel border) async { ... }
  // Future<void> updateBorder(String id, Map<String, dynamic> data) async { ... }
  // Future<void> deleteBorder(String id) async { ... }
}

// Jika Anda memiliki model data untuk Border, Anda bisa mengubah return type
// dari fetchBorders menjadi Future<List<BorderModel>> dan melakukan mapping
// dari Map<String, dynamic> ke BorderModel.
