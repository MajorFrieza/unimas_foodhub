import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final _picker = ImagePicker();

  /// Opens the device gallery, compresses the selected image, and returns
  /// it as a base64 string. Returns null if the user cancels.
  static Future<String?> pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (picked == null) return null;
    final Uint8List bytes = await picked.readAsBytes();
    return base64Encode(bytes);
  }

  /// Returns true if [data] is a base64-encoded image (not a URL).
  static bool isBase64(String data) => !data.startsWith('http');

  /// Builds an image widget that handles both base64 strings and http URLs.
  /// Existing URL-based images continue to work unchanged.
  static Widget buildImage(
    String? imageData, {
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final fallback = placeholder ?? const SizedBox.shrink();
    if (imageData == null || imageData.isEmpty) return fallback;

    if (isBase64(imageData)) {
      try {
        return Image.memory(
          base64Decode(imageData),
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }

    return Image.network(
      imageData,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
