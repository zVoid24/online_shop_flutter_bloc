import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_shop/models/product.dart'; // Import your Product model
import 'product_database.dart'; // Import ProductDatabase

class UserDatabase {
  final String uid;
  UserDatabase({required this.uid});
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');
  final ProductDatabase _productDatabase = ProductDatabase();

  Future<void> createUserData({
    required String name,
    required String email,
  }) async {
    try {
      await userCollection.doc(uid).set({'name': name, 'email': email});
    } catch (e) {
      throw Exception('Failed to create user data: $e');
    }
  }

  Future<void> addToCart({required String productId}) async {
    try {
      final cartItemRef = userCollection
          .doc(uid)
          .collection('cart')
          .doc(productId);
      final cartItemSnapshot = await cartItemRef.get();

      if (cartItemSnapshot.exists) {
        await cartItemRef.update({'quantity': FieldValue.increment(1)});
      } else {
        await cartItemRef.set({'productId': productId, 'quantity': 1});
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await userCollection.doc(uid).collection('cart').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<void> oneItemRemoveFromCart(String productId) async {
    try {
      final cartItemRef = userCollection
          .doc(uid)
          .collection('cart')
          .doc(productId);
      final cartItemSnapshot = await cartItemRef.get();

      if (cartItemSnapshot.exists) {
        final currentQuantity =
            cartItemSnapshot.data()?['quantity'] as int? ?? 0;
        if (currentQuantity > 1) {
          await cartItemRef.update({'quantity': FieldValue.increment(-1)});
        } else {
          await removeFromCart(productId);
        }
      }
    } catch (e) {
      throw Exception('Failed to remove one item from cart: $e');
    }
  }

  // Updated to return List<Product>
  Future<List<Product>> getCartItems() async {
    try {
      // Step 1: Fetch the cart items
      final QuerySnapshot cartSnapshot =
          await userCollection.doc(uid).collection('cart').get();

      if (cartSnapshot.docs.isEmpty) {
        return []; // Return empty list if cart is empty
      }

      // Step 2: Fetch all products
      final List<Product> allProducts = await _productDatabase.fetchProducts();

      // Step 3: Map cart items to Product objects with quantity
      final List<Product> cartItems =
          cartSnapshot.docs.map((doc) {
            final cartData = doc.data() as Map<String, dynamic>;
            final productId = cartData['productId'] as String;
            final quantity = cartData['quantity'] as int;

            // Find the matching product
            final product = allProducts.firstWhere(
              (p) => p.id == productId,
              orElse:
                  () => Product(
                    id: productId,
                    name: 'Unknown Product',
                    description: '',
                    price: 0.0,
                    imageUrl: '',
                    quantity: quantity, // Include quantity even in fallback
                  ),
            );

            // Return a new Product instance with quantity
            return Product(
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price,
              imageUrl: product.imageUrl,
              quantity: quantity, // Add the quantity from cart
            );
          }).toList();

      return cartItems;
    } catch (e) {
      throw Exception('Failed to fetch cart items: $e');
    }
  }
}
