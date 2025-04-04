import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_shop/models/product.dart';

class ProductDatabase {
  final CollectionReference productCollection = FirebaseFirestore.instance
      .collection('products');

  // One-time fetch (for other uses if needed)
  Future<List<Product>> fetchProducts() async {
    try {
      final QuerySnapshot snapshot = await productCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['Name'] as String? ?? '',
          description: data['Description'] as String? ?? '',
          price: (data['Price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['Image'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Stream for real-time updates
  Stream<List<Product>> fetchProductsStream() {
    return productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['Name'] as String? ?? '',
          description: data['Description'] as String? ?? '',
          price: (data['Price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['Image'] as String? ?? '',
        );
      }).toList();
    });
  }
}
