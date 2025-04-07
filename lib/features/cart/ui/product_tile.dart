import 'package:flutter/material.dart';
import 'package:online_shop/features/cart/bloc/cart_bloc.dart';
import 'package:online_shop/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final CartBloc cartBloc;
  const ProductTile({super.key, required this.product, required this.cartBloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: const Color(0xFFF9F6F7),
          elevation: 1.5,
          shadowColor: Colors.black,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F7),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(product.name, style: TextStyle(fontSize: 20)),
                Text(product.description, style: TextStyle(fontSize: 15)),
                Row(
                  children: [
                    Text(
                      "\$${(product.price * product.quantity).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      //padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: 200,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () async {
                              cartBloc.add(
                                OneQuantityRemoveFromCartEvent(
                                  productId: product.id,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} quantity decreased!',
                                  ),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          ),
                          VerticalDivider(color: Colors.grey, thickness: 1),
                          Text(
                            "${product.quantity}",
                            style: TextStyle(fontSize: 15),
                          ),
                          VerticalDivider(color: Colors.grey, thickness: 1),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              cartBloc.add(
                                CartAddToCartEvent(productId: product.id),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} added to cart!',
                                  ),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_shopping_cart_rounded),
                      onPressed: () {
                        cartBloc.add(
                          RemoveFromCartEvent(productId: product.id),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
