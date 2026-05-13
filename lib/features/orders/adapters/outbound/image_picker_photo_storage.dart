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
