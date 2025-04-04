import 'package:cloud_firestore/cloud_firestore.dart';

class UserDatabase {
  final String uid;
  UserDatabase({required this.uid});
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

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
      // Reference to the cart item document
      final cartItemRef = userCollection
          .doc(uid)
          .collection('cart')
          .doc(productId);

      // Check if the product already exists in the cart
      final cartItemSnapshot = await cartItemRef.get();

      if (cartItemSnapshot.exists) {
        // If it exists, increment the quantity

        await cartItemRef.update({'quantity': FieldValue.increment(1)});
      } else {
        // If it doesn’t exist, add it with quantity 1
        await cartItemRef.set({
          'productId': productId,
          'quantity': 1, // Initial quantity
        });
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
}
