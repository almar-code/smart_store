import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// نتيجة بحث واحدة
typedef PlaceResult = ({String name, String address, LatLng latLng});

class MapService {
  final String _apiKey = dotenv.env['MAPS_API_KEY'] ?? '';

  // البحث عبر Places API الجديد، وعند فشله نستخدم Geocoding
  Future<List<PlaceResult>> searchPlaces(String query, String lang, LatLng near) async {
    try {
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:searchText'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.location',
        },
        body: jsonEncode({
          'textQuery': query,
          'languageCode': lang,
          'maxResultCount': 6,
          // تفضيل النتائج القريبة من مكان الخريطة
          'locationBias': {
            'circle': {
              'center': {'latitude': near.latitude, 'longitude': near.longitude},
              'radius': 50000.0,
            }
          },
        }),
      );

      // طباعة سبب الرفض لمعرفته من الكونسول
      if (response.statusCode != 200) throw Exception(response.body);

      final places = (jsonDecode(response.body)['places'] as List?) ?? [];
      return places.map<PlaceResult>((p) => (
      name: p['displayName']?['text'] ?? '',
      address: p['formattedAddress'] ?? '',
      latLng: LatLng(p['location']['latitude'], p['location']['longitude']),
      )).toList();
    } catch (e) {
      debugPrint('Places search error: $e');
      return _geocodeSearch(query, lang);
    }
  }

  // بحث احتياطي بالعناوين والمدن عبر Geocoding API
  Future<List<PlaceResult>> _geocodeSearch(String query, String lang) async {
    final response = await http.get(Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': query,
      'language': lang,
      'key': _apiKey,
    }));
    final data = jsonDecode(response.body);
    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      debugPrint('Geocode search error: ${response.body}');
      throw Exception(data['status']);
    }

    return (data['results'] as List).map<PlaceResult>((r) {
      final address = r['formatted_address'] as String;
      final loc = r['geometry']['location'];
      return (name: address.split(',').first, address: address, latLng: LatLng(loc['lat'], loc['lng']));
    }).toList();
  }

  // نص العنوان المختصر لمكان المؤشر
  Future<String> addressOf(LatLng loc, String lang) async {
    final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=${loc.latitude},${loc.longitude}&key=$_apiKey&language=$lang',
    ));
    final results = jsonDecode(response.body)['results'] as List?;
    return (results != null && results.isNotEmpty) ? results.first['formatted_address'] : '';
  }
}