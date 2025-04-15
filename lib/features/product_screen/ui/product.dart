import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/product_screen/bloc/product_screen_bloc.dart';
import 'package:online_shop/models/product.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductScreenBloc _productScreenBloc = ProductScreenBloc();

  @override
  void initState() {
    super.initState();
    _productScreenBloc.add(ProductScreenInitialEvent());
  }

  @override
  void dispose() {
    _productScreenBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<ProductScreenBloc, ProductScreenState>(
        bloc: _productScreenBloc,
        listenWhen: (previous, current) => current is ProductScreenActionState,
        buildWhen: (previous, current) => current is! ProductScreenActionState,
        listener: (context, state) {
          if (state is ProductScreenAddToCartSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.product.name} to cart!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
            _productScreenBloc.add(ProductScreenInitialEvent());
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case ProductLoadedState:
              return Scaffold(
                appBar: AppBar(
                  leading: BackButton(color: Colors.grey),
                  title: Text(
                    "Product Details",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  //foregroundColor: Color(0xFF328E6E),
                  foregroundColor: Colors.black87,
                  actions: [
                    IconButton(
                      icon: Icon(color: Colors.grey, Icons.shopping_cart),
                      onPressed: () {
                        // Define your action here
                        print('Cart button pressed');
                      },
                    ),
                  ],
                ),
                backgroundColor: Colors.white,
                body: ListView(
                  children: [
                    Hero(
                      tag: 'product_image_${widget.product.id}',
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: double.infinity,
                            child: Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                      child: Text(
                        widget.product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                      child: Text(
                        widget.product.description,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Divider(thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(
                                20.0,
                              ), // Rounded corners
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
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
                                        if (state is ProductLoadedState &&
                                            state.units > 0) {
                                          _productScreenBloc.add(
                                            ProductScreenRemoveButtonPressed(
                                              units: (state).units,
                                            ),
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.remove,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${(state as ProductLoadedState).units}",
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
                                        _productScreenBloc.add(
                                          ProductScreenAddButtonPressed(
                                            units: (state).units,
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              if (state.units > 0) {
                                _productScreenBloc.add(
                                  ProductScreenAddToCartButtonPressed(
                                    productId: widget.product.id,
                                    quantity: state.units,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.shopping_basket),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            default:
              return Center(child: Text("Error State"));
          }
        },
      ),
    );
  }
}
