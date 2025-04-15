import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_shop/models/product.dart';
import 'package:online_shop/models/user.dart';
import 'package:online_shop/models/order.dart' as shop;
import 'product_database.dart';

class UserDatabase {
  final String uid;
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');
  final CollectionReference conversationsCollection = FirebaseFirestore.instance
      .collection('conversations');
  UserDatabase({required this.uid});
  // Removed duplicate declaration of userCollection
  final ProductDatabase _productDatabase = ProductDatabase();

  Future<void> sendMessage(String text, String sender) async {
    try {
      final conversationRef = conversationsCollection.doc(uid);
      final messagesRef = conversationRef.collection('messages');

      // Add the new message to the messages subcollection
      await messagesRef.add({
        'sender': sender, // 'user' or 'admin'
        'text': text,
        'timestamp': Timestamp.now(),
      });

      // Update the conversation document with the last message details
      await conversationRef.set({
        'userId': uid,
        'lastMessage': text,
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': sender,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> syncEmailAfterVerification(String newEmail) async {
    try {
      await userCollection.doc(uid).update({'email': newEmail});
      print('Firestore email updated to $newEmail for UID: $uid');
    } catch (e) {
      print('Error syncing Firestore email: $e');
      throw Exception('Failed to sync email: $e');
    }
  }

  // Get a stream of messages for a conversation
  Stream<List<Map<String, dynamic>>> getMessagesStream() {
    print('Fetching messages for UID: $uid');
    return conversationsCollection
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          try {
            var messages =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'sender': data['sender']?.toString() ?? 'unknown',
                    'text': data['text']?.toString() ?? '',
                    'timestamp':
                        (data['timestamp'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                  };
                }).toList();
            print('Messages fetched: $messages');
            return messages;
          } catch (e) {
            print('Error mapping messages: $e');
            return [];
          }
        });
  }

  Stream<List<Map<String, dynamic>>> getAllConversationsStream() {
    return conversationsCollection
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'userId': data['userId'] as String,
              'lastMessage': data['lastMessage'] as String,
              'lastMessageTime':
                  (data['lastMessageTime'] as Timestamp?)?.toDate(),
              'lastMessageSender': data['lastMessageSender'] as String,
            };
          }).toList();
        });
  }

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

  Future<void> addToCart({required String productId,int quantity=1}) async {
    try {
      final cartItemRef = userCollection
          .doc(uid)
          .collection('cart')
          .doc(productId);
      final cartItemSnapshot = await cartItemRef.get();

      if (cartItemSnapshot.exists) {
        await cartItemRef.update({'quantity': FieldValue.increment(quantity)});
      } else {
        await cartItemRef.set({'productId': productId, 'quantity': quantity});
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<String> confirmOrder(List<Product> products, double amount) async {
    try {
      final orderRef = userCollection.doc(uid).collection('orders').doc();

      final List<Map<String, dynamic>> orderItems =
          products.map((product) {
            return {
              'productId': product.id,
              'name': product.name,
              'quantity': product.quantity,
              'price': product.price,
            };
          }).toList();

      await orderRef.set({
        'orderId': orderRef.id,
        'items': orderItems,
        'total': amount,
        'date': Timestamp.now(),
        'status': 'completed',
      });

      await deleteCartSubcollection();
      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to confirm order: $e');
    }
  }

  Future<List<shop.Order>> fetchOrder() async {
    try {
      final orderSnapshot = await userCollection.doc(uid).collection('orders').orderBy('date', descending: true).get();
      final orders = <shop.Order>[];
      for (var doc in orderSnapshot.docs) {
        final data = doc.data();
        final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);
        final items = itemsData.map((item) {
          return Product(
            id: item['productId'] as String,
            name: item['name'] as String,
            description: '', 
            price: (item['price'] as num).toDouble(),
            imageUrl: '', 
            quantity: item['quantity'] as int,
            category: '', 
          );
        }).toList();

        orders.add(shop.Order(
          orderId: data['orderId'] as String,
          date: data['date'] as Timestamp,
          items: items,
          status: data['status'] as String,
          amount: (data['total'] as num).toDouble(),
        ));
      }

      print('Fetched ${orders.length} orders for UID: $uid');
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> deleteCartSubcollection() async {
    try {
    
      final cartRef = userCollection.doc(uid).collection('cart');

      final snapshot = await cartRef.get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete cart subcollection: $e');
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
            category: product.category,
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

  Future<double> fetchCheckOutAmount() async {
    try {
      final cartItems = await getCartItems();
      final totalAmount = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      return totalAmount;
    } catch (e) {
      throw Exception('Failed to fetch checkout amount: $e');
    }
  }
}
