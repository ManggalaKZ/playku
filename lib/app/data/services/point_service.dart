import 'package:playku/app/data/local/shared_preference_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PointService {
  static const String baseUrl =
      'https://lvqfhlohgdaqudfuivqb.supabase.co/rest/v1/';
  static const Map<String, String> headers = {
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Content-Type': 'application/json',
  };

  static Future<int?> updateUserPoint(String userId) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('users').select('*').eq('id', userId).single();

      int currentPoint = response['point'] ?? 0;
      int newPoint = currentPoint + 5;

      await supabase.from('users').update({'point': newPoint}).eq('id', userId);
      await SharedPreferenceHelper.saveUserData(
        userId: response['id'],
        userName: response['username'],
        name: response['name'],
        userEmail: response['email'],
        avatar: response['avatar'] ?? "",
        point: newPoint,
      );

      print("User point updated in Supabase: $newPoint");
      return newPoint;
    } catch (e) {
      print("Error updating user point: $e");
      return null;
    }
  }
}
