import 'package:image_picker/image_picker.dart';

import '../../../../core/util/clock.dart';
import '../../application/ports/outbound/photo_storage_port.dart';
import '../../domain/order_photo.dart';

class ImagePickerPhotoStorage implements PhotoStoragePort {
  ImagePickerPhotoStorage({
    ImagePicker? picker,
    required Clock clock,
  })  : _picker = picker ?? ImagePicker(),
        _clock = clock;

  final ImagePicker _picker;
  final Clock _clock;

  @override
  Future<OrderPhoto?> pickFromCamera() => _pick(ImageSource.camera);

  @override
  Future<OrderPhoto?> pickFromGallery() => _pick(ImageSource.gallery);

  @override
  Future<List<OrderPhoto>> pickMultipleFromGallery({
    required int limit,
  }) async {
    if (limit <= 0) return const [];
    final files = await _picker.pickMultiImage(
      limit: limit,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (files.isEmpty) return const [];
    // pickMultiImage's `limit` is best-effort across platforms; trim
    // defensively so we never overflow the caller's quota.
    final trimmed = files.length > limit ? files.take(limit) : files;
    final at = _clock.now();
    return [
      for (final f in trimmed) OrderPhoto(localPath: f.path, takenAt: at),
    ];
  }

  Future<OrderPhoto?> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (file == null) return null;
    return OrderPhoto(localPath: file.path, takenAt: _clock.now());
  }

  @override
  Future<void> remove(OrderPhoto photo) async {
    // image_picker writes to OS-managed temp storage; nothing to do
    // locally. An HTTP adapter would issue DELETE here.
  }
}
