import 'package:playku/app/data/models/frame_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BorderService {
  static SupabaseClient client = Supabase.instance.client;
  static String tableName = 'border';

  static Future<List<FrameModel>> fetchBorders() async {
    try {
      final response = await client.from("border").select();

      if (response is List) {
        return response
            .map((item) => FrameModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print(
            'Unexpected response format from Supabase: ${response.runtimeType}');

        return [];
      }
    } catch (e) {
      print('Error fetching borders: $e');

      return [];
    }
  }
}
