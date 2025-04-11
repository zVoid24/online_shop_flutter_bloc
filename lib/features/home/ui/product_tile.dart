import 'package:flutter/material.dart';
import 'package:online_shop/features/home/bloc/home_bloc.dart';
import 'package:online_shop/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final HomeBloc homeBloc;
  const ProductTile({super.key, required this.product, required this.homeBloc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('Product tapped: ${product.name}');
        homeBloc.add(HomeProductTapEvent(product: product));
      },
      child: Card(
        color: const Color(0xFFF9F6F7),
        elevation: 1.5,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_image_${product.id}',
              child: Container(
                height: 100, // Fixed height for consistency
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAECCC), // Background color
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Circular shape
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          color: const Color(0xFF328E6E),
                          padding: const EdgeInsets.all(4), // Tight padding
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ), // Smaller size
                          onPressed: () {
                            homeBloc.add(
                              HomeAddToCartEvent(productId: product.id),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
