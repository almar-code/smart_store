import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
abstract class AddressState {}
class AddressInitial extends AddressState {}
class AddressLoading extends AddressState {}
class AddressLoaded extends AddressState {
  final Map<String, dynamic> addressData;
  AddressLoaded(this.addressData);
}
class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}
class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressInitial());

  final String apiKey = dotenv.env['MAPS_API_KEY'] ?? '';

  Future<void> fetchAddressFromLocation(LatLng location, String lang) async {
    emit(AddressLoading());
    try {
      // إضافة &language=$lang في نهاية الرابط
      final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey&language=$lang";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final components = data['results'][0]['address_components'] as List;

          String find(String type) {
            final comp = components.firstWhere(
                  (c) => (c['types'] as List).contains(type),
              orElse: () => null,
            );
            return comp != null ? comp['long_name'] : '';
          }

          final addressMap = {
            'country': find('country'),
            'city': find('locality').isEmpty ? find('administrative_area_level_1') : find('locality'),
            'street': data['results'][0]['formatted_address']?.split(',')[0] ?? '',
            'postal_code': find('postal_code'),
          };
          emit(AddressLoaded(addressMap));
        } else {
          emit(AddressError("لم يتم العثور على عنوان"));
        }
      }
    } catch (e) {
      emit(AddressError("خطأ في الاتصال: $e"));
    }
  }
}