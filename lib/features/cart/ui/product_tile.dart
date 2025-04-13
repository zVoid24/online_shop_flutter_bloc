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
          // child: Card(
          //   //color: const Color(0xFFEAECCC),
          //   //color: const Color(0xFFF9F6F7),
          //   //elevation: 1.5,
          //   //shadowColor: Colors.black,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                //color: const Color(0xFFF9F6F7),
                borderRadius: BorderRadius.circular(8.0),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            "\$${(product.price * product.quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 70, // Minimum width for small quantities
                          maxWidth: 200, // Maximum width for large quantities
                        ),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // Shrink-wrap content
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                color: Colors.red,
                                icon:
                                    product.quantity == 1
                                        ? Icon(Icons.delete)
                                        : Icon(Icons.remove),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                constraints:
                                    const BoxConstraints(), // Remove default constraints
                                onPressed: () async {
                                  if(product.quantity==1)
                                  {
                                    cartBloc.add(RemoveFromCartEvent(productId: product.id));
                                  }
                                  else
                                  {
                                    cartBloc.add(
                                    OneQuantityRemoveFromCartEvent(
                                      productName: product.name,
                                      productId: product.id,
                                    ),
                                  );
                                  }
                                },
                              ),
                              const VerticalDivider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  "${product.quantity}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              const VerticalDivider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                              IconButton(
                                color: Colors.green,
                                icon: const Icon(Icons.add),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                constraints:
                                    const BoxConstraints(), // Remove default constraints
                                onPressed: () async {
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            // ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
