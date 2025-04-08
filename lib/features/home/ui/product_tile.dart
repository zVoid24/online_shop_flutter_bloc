import 'package:flutter/material.dart';
import 'package:online_shop/features/home/bloc/home_bloc.dart';
import 'package:online_shop/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final HomeBloc homeBloc;
  const ProductTile({super.key, required this.product, required this.homeBloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Color(0xFFF9F6F7),
          //borderRadius: BorderRadius.circular(8.0),
          shadowColor: Colors.black,
          elevation: 1.5,
          child: GestureDetector(
            onTap: () {
              debugPrint('Product tapped: ${product.name}');
              homeBloc.add(HomeProductTapEvent(product: product));
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xFFF9F6F7),
                //border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: Container(
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
                  ),
                  Text(product.name, style: TextStyle(fontSize: 20)),
                  Text(product.description, style: TextStyle(fontSize: 15)),
                  Divider(color: Colors.grey, thickness: 1),
                  Row(
                    children: [
                      Text(
                        "\$${product.price}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Color(0xFFEAECCC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadowColor: Colors.black,
                          elevation: 1.5,
                        ),
                        onPressed: () {
                          homeBloc.add(
                            HomeAddToCartEvent(productId: product.id),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
