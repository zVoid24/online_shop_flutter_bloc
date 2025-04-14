import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/database/product_database.dart';
import 'package:online_shop/features/search/bloc/search_bloc.dart';
import 'package:online_shop/features/search/ui/search_bar_widget.dart';

class Search extends StatelessWidget {
  final ProductDatabase productDatabase;

  const Search({required this.productDatabase, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(productDatabase),
      child: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SearchBody(searchBloc: context.read<SearchBloc>()),
          );
        },
      ),
    );
  }
}