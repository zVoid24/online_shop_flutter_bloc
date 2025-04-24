import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/login/bloc/login_bloc.dart';
import 'package:online_shop/features/sign_up/ui/sign_up.dart';
import 'package:online_shop/features/wrapper/ui/wrapper.dart';

class AppColors {
  static const primary = Color(0xFF328E6E);
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginBloc loginBloc = LoginBloc();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    loginBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    loginBloc.add(LoginInitialEvent(isPasswordObscured: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (previous, current) => current is LoginActionState,
        buildWhen: (previous, current) =>
            current is LoginInitial || current is LoginFailure || current is LoginLoading,
        bloc: loginBloc,
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LoginNavigateToSignUp) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUp()),
            );
          } else if (state is LoginSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Wrapper()), // Replace with your Wrapper
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case LoginInitial:
            case LoginFailure:
              return Padding(
                padding: const EdgeInsets.all(30),
                child: ListView(
                  children: [
                    Image.asset(
                      'assets/images/undraw_shopping-app_b80f.png',
                      height: 300,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@gmail.com',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            loginBloc.add(PasswordObscured());
                          },
                          icon: state.isPasswordObscured
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                      ),
                      obscureText: state.isPasswordObscured,
                    ),
                    const SizedBox(height: 20),
                    customButton(context, 'Sign In', () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter email and password'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      loginBloc.add(
                        LoginButtonPressed(
                          email: email,
                          password: password,
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    customButton(
                      context,
                      'Sign Up',
                      () => loginBloc.add(SignUpButtonClicked()),
                    ),
                  ],
                ),
              );
            case LoginLoading:
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget customButton(BuildContext context, String text, Function() function) {
    return GestureDetector(
      onTap: function,
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}