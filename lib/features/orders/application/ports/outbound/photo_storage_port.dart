import '../../../domain/order_photo.dart';

/// Outbound port: pick + detach photos. Implementations live in
/// `adapters/outbound/` (image_picker today; an HTTP-aware adapter
/// when the backend lands and uploads via multipart).
abstract interface class PhotoStoragePort {
  /// Returns null if the user cancels the picker.
  Future<OrderPhoto?> pickFromCamera();

  /// Returns null if the user cancels the picker.
  Future<OrderPhoto?> pickFromGallery();

  /// Detach the photo. For local image_picker temp files this is a
  /// no-op — the OS reclaims temp files. For HTTP-backed photos this
  /// would issue a DELETE. Kept on the port so a server adapter
  /// doesn't need a separate interface.
  Future<void> remove(OrderPhoto photo);
}
