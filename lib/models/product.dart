class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int quantity;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    required this.category
  });
}
