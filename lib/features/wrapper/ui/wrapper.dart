import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/home/ui/home.dart';
import 'package:online_shop/features/login/ui/login.dart';
import 'package:online_shop/features/wrapper/bloc/bloc/wrapper_bloc.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final WrapperBloc wrapperBloc = WrapperBloc();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WrapperBloc, WrapperState>(
      bloc: wrapperBloc,
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged in!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return Home();
        } else {
          return Login();
        }
      },
    );
  }
}
