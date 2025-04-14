import 'package:flutter/material.dart';
import 'package:online_shop/features/cart/bloc/cart_bloc.dart';
import 'package:online_shop/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final CartBloc cartBloc;
  ProductTile({super.key, required this.product, required this.cartBloc});

  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    _amount += product.quantity*product.price;
    return Column(
      children: [
        Dismissible(
          key: Key(product.id.toString()),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            cartBloc.add(RemoveFromCartEvent(productId: product.id));
          },
          background: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${(product.price * product.quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 36, // Reduced height for compactness
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(
                          20.0,
                        ), // Rounded corners
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.0),
                                onTap: () {
                                  if (product.quantity == 1) {
                                    cartBloc.add(
                                      RemoveFromCartEvent(
                                        productId: product.id,
                                      ),
                                    );
                                  } else {
                                    cartBloc.add(
                                      OneQuantityRemoveFromCartEvent(
                                        productName: product.name,
                                        productId: product.id,
                                      ),
                                    );
                                  }
                                },
                                child: Icon(
                                  product.quantity == 1
                                      ? Icons.delete
                                      : Icons.remove,
                                  size: 18,
                                  color:
                                      product.quantity == 1
                                          ? Colors.red
                                          : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              "${product.quantity}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.0),
                                onTap: () {
                                  cartBloc.add(
                                    CartAddToCartEvent(productId: product.id),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} added to cart!',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
