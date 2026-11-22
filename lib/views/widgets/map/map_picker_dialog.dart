import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/map/map_styles.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../data/services/map_service.dart';

class MapPickerDialog extends StatefulWidget {
  const MapPickerDialog({super.key});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  final _service = MapService();
  final _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Timer? _debounce;

  LatLng _center = const LatLng(24.7136, 46.6753);
  MapType _mapType = MapType.normal;
  List<PlaceResult> _results = [];
  String _address = '';
  bool _moving = false;
  bool _searching = false;
  bool _locating = false;
  bool _showMyLocation = false;
  bool _errorShown = false;
  bool _noResults = false;
  String get _lang => context.locale.languageCode;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // البحث بعد توقف الكتابة نصف ثانية
  void _onSearchChanged(String text) {
    _debounce?.cancel();
    setState(() {});
    if (text.trim().length < 2) {
      return setState(() {
        _results = [];
        _noResults = false;
      });
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _searching = true);
      try {
        final results = await _service.searchPlaces(text.trim(), _lang, _center);
        if (!mounted) return;
        setState(() {
          _results = results;
          _noResults = results.isEmpty;
          _errorShown = false;
        });
      } catch (_) {
        // إظهار رسالة الخطأ مرة واحدة فقط
        if (mounted && !_errorShown) {
          _errorShown = true;
          AppToasts.showErrorToast(context, tr('internet_connection_error'));
        }
      }
      if (mounted) setState(() => _searching = false);
    });
  }

  void _selectResult(PlaceResult place) {
    FocusScope.of(context).unfocus();
    _searchController.text = place.name;
    setState(() {
      _results = [];
      _noResults = false;
    });
    _moveTo(place.latLng);
  }

  void _moveTo(LatLng loc) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(loc, 16));
  }

  // الذهاب لموقعي مع طلب الإذن، وعند الفتح لا نطلب الإذن
  Future<void> _goToMyLocation({bool ask = true}) async {
    var permission = await Geolocator.checkPermission();
    if (!ask && permission != LocationPermission.always && permission != LocationPermission.whileInUse) return;

    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw 'location_service_off';
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw 'location_permission_denied';
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      if (!mounted) return;
      setState(() => _showMyLocation = true);
      _moveTo(LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      if (mounted && ask) AppToasts.showErrorToast(context, tr(e is String ? e : 'location_error'));
    }
    if (mounted) setState(() => _locating = false);
  }

  // جلب العنوان عند توقف الخريطة
  Future<void> _onCameraIdle() async {
    setState(() => _moving = false);
    try {
      final address = await _service.addressOf(_center, _lang);
      if (mounted && !_moving) setState(() => _address = address);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isDesktop ? 40 : 10),
      child: Container(
        width: 900,
        height: size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // الخريطة
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 14),
              style: isDark ? MapStyles.darkStyle : null,
              mapType: _mapType,
              myLocationEnabled: _showMyLocation,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (c) {
                _mapController = c;
                // _goToMyLocation(ask: false);
              },
              onCameraMoveStarted: () => setState(() => _moving = true),
              onCameraMove: (p) => _center = p.target,
              onCameraIdle: _onCameraIdle,
              onTap: (loc) {
                FocusScope.of(context).unfocus();
                _moveTo(loc);
              },
            ),

            // المؤشر يرتفع أثناء التحريك
            IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      offset: Offset(0, _moving ? -0.25 : 0),
                      child: Icon(Icons.location_on, size: 50, color: AppColors.primary),
                    ),
                    Container(
                      width: _moving ? 8 : 14,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 55),
                  ],
                ),
              ),
            ),

            // شريط البحث والنتائج
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  _glassBox(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: AppColors.iconColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(color: AppColors.textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: tr('searchHere'),
                              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searching)
                          const Padding(padding: EdgeInsets.all(12), child: CircularProgress(size: 15))
                        else if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.backspace_outlined, size: 20, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _results = [];
                                _noResults = false;
                              });
                            },
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.search_rounded, color: AppColors.primary),
                          ),
                          ],
                    ),
                  ),
                  if (_results.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _glassBox(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderColor.withOpacity(0.4)),
                          itemBuilder: (_, i) {
                            final place = _results[i];
                            return ListTile(
                              onTap: () => _selectResult(place),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Icon(Icons.place_outlined, color: AppColors.primary, size: 20),
                              ),
                              title: Text(place.name,
                                  style: TextStyle(color: AppColors.textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                              subtitle: Text(place.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  // لا توجد نتائج
                  if (_noResults && !_searching) ...[
                    const SizedBox(height: 8),
                    _glassBox(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.search_off_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 10),
                          Text(tr('map_no_results'), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // نوع الخريطة وموقعي
            PositionedDirectional(
              end: 12,
              bottom: 150,
              child: Column(
                children: [
                  _roundButton(
                    icon: _mapType == MapType.normal ? Icons.satellite_alt_rounded : Icons.map_rounded,
                    onTap: () => setState(() =>
                    _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal),
                  ),
                  const SizedBox(height: 10),
                  _roundButton(
                    icon: Icons.my_location_rounded,
                    loading: _locating,
                    onTap: _goToMyLocation,
                  ),
                ],
              ),
            ),

            // بطاقة العنوان وزر التأكيد
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _glassBox(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _moving
                                ? tr('map_move_to_select')
                                : (_address.isEmpty ? tr('loading') : _address),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textColor, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 42 : 38,
                      child: AppButton(
                        label: tr('confirm_selection'),
                        icon: Icons.check_rounded,
                        onTap: _moving ? null : () => Navigator.pop(context, _center),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // صندوق زجاجي شفاف مثل تسجيل الدخول
  Widget _glassBox({required Widget child, EdgeInsets padding = EdgeInsets.zero}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Material(color: Colors.transparent, child: child),
        ),
      ),
    );
  }
  Widget _roundButton({required IconData icon, required VoidCallback onTap, bool loading = false}) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: loading ? null : onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child: loading
                ? const CircularProgress(size: 20)
                : Icon(icon, color: AppColors.primary, size: 22),
          ),
        ),
      ),
    );
  }
}