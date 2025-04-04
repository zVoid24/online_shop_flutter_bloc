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
        Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
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
                    "\$${product.price}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_shopping_cart),
                    onPressed: () {
                      cartBloc.add(RemoveFromCartEvent(productId: product.id));
                    },
                  ),
                ],
              ),
              Text(
                "Quantity: ${product.quantity}",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
