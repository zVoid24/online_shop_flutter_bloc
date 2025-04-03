import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/sign_up/bloc/sign_up_bloc.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SignUpBloc signUpBloc = SignUpBloc();

  @override
  void initState() {
    signUpBloc.add(SignUpInitialEvent(isPasswordObscured: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: BlocConsumer<SignUpBloc, SignUpState>(
        listenWhen: (previous, current) => current is SignUpActionState,
        buildWhen:
            (previous, current) =>
                current is! SignUpActionState || current is SignUpFailure,
        bloc: signUpBloc,
        listener: (context, state) {
          if (state is SignUpFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(30),
            child: ListView(
              children: [
                Image.asset(
                  'assets/images/undraw_sign-up_qamz.png',
                  height: 200,
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Your Full Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    labelText: 'Name',
                  ),
                  keyboardType: TextInputType.name,
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey),
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(
                      onPressed: () {
                        signUpBloc.add(SignUpObscuredButtonClicked());
                      },
                      icon:
                          state.isPasswordObscured
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                    ),
                  ),
                  obscureText: state.isPasswordObscured,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
