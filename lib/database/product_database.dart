import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_shop/models/product.dart';

class ProductDatabase {
  final CollectionReference productCollection =
      FirebaseFirestore.instance.collection('products');

  Future<List<Product>> fetchProducts({
    String? lastDocId,
    int limit = 10,
  }) async {
    try {
      Query query = productCollection
          .orderBy('Name')
          .orderBy(FieldPath.documentId)
          .limit(limit);

      if (lastDocId != null) {
        print('Fetching after lastDocId: $lastDocId');
        final lastDoc = await productCollection.doc(lastDocId).get();
        if (!lastDoc.exists) {
          print('Last document with ID $lastDocId does not exist, fetching from start');
          query = productCollection
              .orderBy('Name')
              .orderBy(FieldPath.documentId)
              .limit(limit);
        } else {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final QuerySnapshot snapshot = await query.get();
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['Name'] as String? ?? 'Unnamed Product',
          description: data['Description'] as String? ?? 'No description available',
          price: (data['Price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['Image'] as String? ?? '',
        );
      }).toList();
      print(
        'Fetched ${products.length} products: ${products.map((p) => p.name).toList()}',
      );
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<Product>> fetchProductsByCategory({
    required String category,
    String? lastDocId,
    int limit = 10,
  }) async {
    try {
      print('Querying category: $category');
      Query query = productCollection
          .where('Category', isEqualTo: category)
          .orderBy('Name')
          .orderBy(FieldPath.documentId)
          .limit(limit);

      if (lastDocId != null) {
        print('Fetching after lastDocId: $lastDocId for category: $category');
        final lastDoc = await productCollection.doc(lastDocId).get();
        if (!lastDoc.exists) {
          print('Last document with ID $lastDocId does not exist, fetching from start');
          query = productCollection
              .where('Category', isEqualTo: category)
              .orderBy('Name')
              .orderBy(FieldPath.documentId)
              .limit(limit);
        } else {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final QuerySnapshot snapshot = await query.get();
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['Name'] as String? ?? 'Unnamed Product',
          description: data['Description'] as String? ?? 'No description available',
          price: (data['Price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['Image'] as String? ?? '',
        );
      }).toList();
      print(
        'Fetched ${products.length} products for category $category: ${products.map((p) => p.name).toList()}',
      );
      return products;
    } catch (e) {
      print('Error fetching category products: $e');
      throw Exception('Failed to fetch category products: $e');
    }
  }

  Future<List<Product>> fetchProductInfo(String productId) async {
    try {
      final doc = await productCollection.doc(productId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return [
          Product(
            id: doc.id,
            name: data['Name'] as String? ?? 'Unnamed Product',
            description: data['Description'] as String? ?? 'No description available',
            price: (data['Price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: data['Image'] as String? ?? '',
          ),
        ];
      } else {
        throw Exception('Product with ID $productId does not exist');
      }
    } catch (e) {
      print('Error fetching product info: $e');
      throw Exception('Failed to fetch product info: $e');
    }
  }

  Future<int> getProductCount() async {
    try {
      final snapshot = await productCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting product count: $e');
      return 0;
    }
  }

  Future<int> getProductCountByCategory(String category) async {
    try {
      final snapshot = await productCollection
          .where('Category', isEqualTo: category)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting product count for category $category: $e');
      return 0;
    }
  }
}