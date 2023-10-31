import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';
import 'package:notes_app/utilities/dialogs/error_dialog.dart';
import 'package:notes_app/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _passwordVisible = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, "User not found.");
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, "Wrong Credentials.");
          } else if (state.exception is TooManyRequestsAuthException) {
            await showErrorDialog(context, "Too many unsuccessful attempts.");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              SizedBox(
                width: 360,
                child: TextField(
                  controller: _email,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              SizedBox(
                width: 360,
                child: TextField(
                  controller: _password,
                  obscureText: _passwordVisible,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.purple),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                  ),
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    context.read<AuthBloc>().add(
                          AuthEventLogIn(
                            email: email,
                            password: password,
                          ),
                        );
                  },
                  child: const Text("Login")),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventShouldResetPassword(),
                      );
                },
                child: const Text("Forgot Password"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 74),
                child: Row(
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthEventShouldRegister(),
                              );
                        },
                        child: const Text("Register Here"))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
