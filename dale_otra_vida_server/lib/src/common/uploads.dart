import 'package:serverpod/serverpod.dart';

/// Limits for photo uploads (listing photos and avatars). The app compresses
/// photos well below this; the cap stops anyone filling the bucket through a
/// signed upload URL, and a path can't be overwritten once uploaded.
const photoUploadOptions = UploadOptions(
  maxFileSize: 5 * 1024 * 1024,
  preventOverwrite: true,
);
