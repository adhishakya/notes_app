import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import '../utilities/show_error_dialog.dart';

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
    return Scaffold(
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
                    hintText: "Email Address", prefixIcon: Icon(Icons.email)),
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
                  hintText: "Password",
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
                    foregroundColor: MaterialStatePropertyAll(Colors.white)),
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await AuthService.firebase().logIn(
                      email: email,
                      password: password,
                    );
                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      //user is verified
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute,
                          (route) => false,
                        );
                      }
                    } else {
                      //user is not verified
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyEmailRoute,
                          (route) => false,
                        );
                      }
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(context, "User not found");
                  } on WrongPasswordAuthException {
                    await showErrorDialog(context, "Wrong credentials entered");
                  } on TooManyRequestsAuthException {
                    await showErrorDialog(context,
                        "Too many failed login attempts! Try again later");
                  } on GenericAuthException {
                    await showErrorDialog(context, "Authentication error");
                  }
                },
                child: const Text("Login")),
            Padding(
              padding: const EdgeInsets.only(left: 74),
              child: Row(
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, (route) => false);
                      },
                      child: const Text("Register Here"))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
