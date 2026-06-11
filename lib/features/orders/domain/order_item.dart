enum OrderItemKind { service, product }

class OrderItem {
  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.priceUah,
    required this.discountUah,
    required this.sumUah,
    required this.kind,
  });

  final String id;
  final String name;
  final int quantity;
  final int priceUah;
  final int discountUah;
  final int sumUah;
  final OrderItemKind kind;

  @override
  bool operator ==(Object other) =>
      other is OrderItem &&
      other.id == id &&
      other.name == name &&
      other.quantity == quantity &&
      other.priceUah == priceUah &&
      other.discountUah == discountUah &&
      other.sumUah == sumUah &&
      other.kind == kind;

  @override
  int get hashCode =>
      Object.hash(id, name, quantity, priceUah, discountUah, sumUah, kind);
}
