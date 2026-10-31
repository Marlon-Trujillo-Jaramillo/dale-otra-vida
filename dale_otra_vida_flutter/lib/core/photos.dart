import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';

/// Longest side of uploaded photos. With JPEG quality 78 this keeps files
/// well under the server's request size limit.
const _maxSide = 1440.0;

/// Lets the member pick a photo and returns it as resized JPEG bytes, or null
/// when they cancel. Works on phones and on the web (no file paths).
Future<Uint8List?> pickPhoto(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: _maxSide,
    maxHeight: _maxSide,
    imageQuality: 78,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  if (kIsWeb) return bytes;
  try {
    // Re-encode as JPEG: HEIC or PNG camera rolls get much smaller.
    return await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: _maxSide.toInt(),
      minHeight: _maxSide.toInt(),
      quality: 78,
      format: CompressFormat.jpeg,
    );
  } catch (_) {
    return bytes;
  }
}

/// Uploads [bytes] with a server-issued upload description.
Future<bool> uploadPhoto(String uploadDescription, Uint8List bytes) {
  return FileUploader(
    uploadDescription,
  ).upload(Stream.fromIterable([bytes]), bytes.length);
}
