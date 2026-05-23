import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show GoogleMapController, LatLng, CameraUpdate, CameraPosition, GoogleMap;
import 'package:http/http.dart' as http;

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/map/map_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../logic/map/address_cubit.dart';

class MapPickerDialog extends StatefulWidget {
  const MapPickerDialog({super.key});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  LatLng _selectedCenter = const LatLng(24.7136, 46.6753);
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  // دالة البحث والتحرك للموقع الجديد
  Future<void> _searchAndMove(String query) async {
    if (query.isEmpty) return;

    // الحصول على كود اللغة الحالية (ar أو en)
    String lang = context.locale.languageCode;

    final String apiKey = context.read<AddressCubit>().apiKey;
    // إضافة language=$lang للرابط
    final String url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey&language=$lang";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          _moveToLocation(LatLng(location['lat'], location['lng']));
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }
  void _moveToLocation(LatLng loc) {
    setState(() => _selectedCenter = loc);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(loc, 15));
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      _moveToLocation(LatLng(position.latitude, position.longitude));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الثيم
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:  EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 5, vertical: 50),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65, // القائمة صغيرة لا تغطي كامل الشاشة
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 1. الخريطة (الخلفية)
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _selectedCenter, zoom: 14),
              onMapCreated: (controller) {
                _mapController = controller;
                // استدعاء التنسيق من ملفك الخارجي
                if (isDarkMode) {
                  controller.setMapStyle(MapStyles.darkStyle);
                }
              },
              mapToolbarEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onCameraMove: (position) => _selectedCenter = position.target,
              onTap: (LatLng loc) => _moveToLocation(loc),
            ),
            // 2. مؤشر الموقع (السنتر)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 35),
                child: Icon(Icons.location_on, size: 45, color: Colors.red),
              ),
            ),

            // 3. شريط البحث وزر الإغلاق العلوي
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  // زر الإغلاق (خارج السيرتش)
                  AppIcon(icon: Icons.close, onPressed: () => Navigator.pop(context) ,),
                  const SizedBox(width: 10),
                  // حقل البحث
                  Expanded(
                    child: Container(
                      height: isDesktop ? 38 : 25,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(isDesktop ? 7 : 4,),
                      ),
                      child: TextField(
                        onSubmitted: (value) => _searchAndMove(value),
                        controller: _searchController,
                        style: TextStyle(color: AppColors.textColor, fontSize: isDesktop ? 14 : 10),
                        decoration: InputDecoration(
                          hintText: tr('searchHere'),
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize:isDesktop ? 13 : 10,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: isDesktop ? 18 : 15,
                          ),
                          contentPadding:  EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 5,),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isDesktop ? 7 : 4,),
                            borderSide: BorderSide(
                              color: AppColors.borderColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
// 4. زر جلب الموقع الحالي (يطفو فوق الخريطة)
            Positioned(
              bottom: 80,
              right: 15,
              child: FloatingActionButton.small(
                backgroundColor: AppColors.primary,
                elevation: 4,
                onPressed: _determinePosition,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
            // 5. زر التأكيد السفلي (يطفو فوق الخريطة)
            Positioned(
              bottom: 30,
              left: 15,
              right: 15,
              child: SizedBox(
                height: 30,
                child: AppButton(
                  label: tr('confirm_selection'),
                  onTap: () => Navigator.pop(context, _selectedCenter),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}