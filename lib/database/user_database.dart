import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_shop/models/product.dart';
import 'package:online_shop/models/user.dart';
import 'product_database.dart';

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

  Future<UserData?> getUserData() async {
    try {
      final DocumentSnapshot userSnapshot = await userCollection.doc(uid).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        return UserData(
          uid: uid,
          name: data['name'] ?? 'Unknown',
          email: data['email'] ?? 'Unknown',
        );
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
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

  Future<List<Product>> getCartItems() async {
    try {
      final QuerySnapshot cartSnapshot =
          await userCollection.doc(uid).collection('cart').get();

      if (cartSnapshot.docs.isEmpty) {
        return [];
      }

      // Fetch each product's details using fetchProductInfo
      final cartItems = <Product>[];
      for (var doc in cartSnapshot.docs) {
        final cartData = doc.data() as Map<String, dynamic>;
        final productId = cartData['productId'] as String;
        final quantity = cartData['quantity'] as int;

        final productInfo = await _productDatabase.fetchProductInfo(productId);
        final product =
            productInfo.first; // fetchProductInfo returns a List with one item
        cartItems.add(
          Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl,
            quantity: quantity, // Add quantity from cart
          ),
        );
      }

      print(
        'Fetched ${cartItems.length} cart items: ${cartItems.map((p) => p.name).toList()}',
      );
      return cartItems;
    } catch (e) {
      print('Error fetching cart items: $e');
      throw Exception('Failed to fetch cart items: $e');
    }
  }
}
