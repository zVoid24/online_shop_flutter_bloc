import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/login/bloc/login_bloc.dart';
import 'package:online_shop/features/sign_up/ui/sign_up.dart';

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
        backgroundColor: Colors.black,
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (previous, current) => current is LoginActionState,
        buildWhen:
            (previous, current) =>
                current is! LoginActionState || current is LoginFailure,
        bloc: loginBloc,
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is LoginNavigateToSignUp) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUp()),
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
                      'assets/images/undraw_bus-stop_m7q9.png',
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
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            loginBloc.add(PasswordObscured());
                          },
                          icon:
                              state.isPasswordObscured
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                        ),
                      ),
                      obscureText: state.isPasswordObscured,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        loginBloc.add(
                          LoginButtonPressed(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: const Text(
                            'Log In',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    customButton(
                      context,
                      'Sign Up',
                      () => loginBloc.add(SignUpButtonClicked()),
                    ),
                  ],
                ),
              );
            case LoginLoading:
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );
            default:
              return const SizedBox.shrink(); // Default case to handle other states
          }
        },
      ),
    );
  }

  Widget customButton(BuildContext context, String text, Function() function) {
    return GestureDetector(
      onTap: () {
        // Add your onTap logic here
        function();
      },
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
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
