import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'product_screen_event.dart';
part 'product_screen_state.dart';

class ProductScreenBloc extends Bloc<ProductScreenEvent, ProductScreenState> {
  ProductScreenBloc() : super(ProductScreenInitial());

  @override
  Stream<ProductScreenState> mapEventToState(ProductScreenEvent event) async* {
    // TODO: implement mapEventToState
  }
}
