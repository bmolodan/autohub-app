/// A photo attached to an order. Currently a local file path; future
/// remote-server adapters will swap this for an HTTP URL via the same
/// [PhotoStoragePort] interface.
class OrderPhoto {
  const OrderPhoto({required this.localPath, required this.takenAt});

  final String localPath;
  final DateTime takenAt;

  @override
  bool operator ==(Object other) =>
      other is OrderPhoto &&
      other.localPath == localPath &&
      other.takenAt == takenAt;

  @override
  int get hashCode => Object.hash(localPath, takenAt);
}
