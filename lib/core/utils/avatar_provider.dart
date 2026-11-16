import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../widgets/image_helper.dart';

// صورة من رابط او Base64
ImageProvider? avatarProvider(String? image) {
  if (image == null || image.isEmpty) return null;
  if (image.startsWith('http')) return CachedNetworkImageProvider(image);
  try {
    return MemoryImage(ImageHelper.decodeBase64(image));
  } catch (_) {
    return null;
  }
}