import 'dart:typed_data';

import '../services/try_on_service.dart';

class TryOnRepo {
  final TryOnService service;

  TryOnRepo(this.service);

  Future<Uint8List> downloadGarment(String imageUrl) async {
    return await service.downloadGarment(imageUrl);
  }

  Future<Uint8List> tryOn({
    required Uint8List personImage,
    required Uint8List garmentImage,
    String clothType = 'overall',
  }) async {
    return await service.tryOn(
      personImage: personImage,
      garmentImage: garmentImage,
      clothType: clothType,
    );
  }
}
