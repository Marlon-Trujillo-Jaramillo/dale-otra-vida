import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';

/// Longest side of uploaded photos. With quality 78 this keeps files well
/// under the server's upload limit.
const _maxSide = 1440.0;

/// WebP is about a third smaller than JPEG at the same quality, and every
/// current browser shows it. The Android app encodes it; the browser's own
/// resize (web) and iOS stay on JPEG.
bool get _encodeWebp =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// File extension to ask the server for, matching what [pickPhoto] returns.
String get photoExtension => _encodeWebp ? 'webp' : 'jpg';

/// Whether to offer "Tomar foto / Elegir de la galería" first. Phones get
/// the choice, also in the browser (the camera opens straight away); desktop
/// browsers only have the file dialog, opened right from the click.
bool get askPhotoSource =>
    !kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Lets the member pick a photo and returns it resized and compressed (see
/// [photoExtension]), or null when they cancel. Works on phones and on the
/// web (no file paths).
///
/// [selfie] opens the front camera; [jpeg] keeps JPEG on every platform (the
/// identity check stores `.jpg` files).
Future<Uint8List?> pickPhoto(
  ImageSource source, {
  bool selfie = false,
  bool jpeg = false,
}) async {
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: _maxSide,
    maxHeight: _maxSide,
    imageQuality: 78,
    preferredCameraDevice: selfie ? CameraDevice.front : CameraDevice.rear,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  if (kIsWeb) return bytes;
  try {
    // Re-encode: HEIC or PNG camera rolls get much smaller.
    return await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: _maxSide.toInt(),
      minHeight: _maxSide.toInt(),
      quality: 78,
      format: _encodeWebp && !jpeg ? CompressFormat.webp : CompressFormat.jpeg,
    );
  } catch (_) {
    // Decoders read the real format from the bytes, not the file name.
    return bytes;
  }
}

/// Uploads [bytes] with a server-issued upload description.
Future<bool> uploadPhoto(String uploadDescription, Uint8List bytes) {
  return FileUploader(
    uploadDescription,
  ).upload(Stream.fromIterable([bytes]), bytes.length);
}
