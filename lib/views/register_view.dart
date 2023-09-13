import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
            const SizedBox(height: 14),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _password,
                obscureText: _passwordVisible,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Email Address",
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
            const SizedBox(height: 14),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _confirmPassword,
                obscureText: _confirmPasswordVisible,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    icon: Icon(_confirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
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
                  final confirmPassword = _confirmPassword.text;
                  if (password == confirmPassword) {
                    try {
                      await AuthService.firebase().createUser(
                        email: email,
                        password: password,
                      );
                      AuthService.firebase().sendEmailVerification();
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(verifyEmailRoute);
                      }
                    } on WeakPasswordAuthException {
                      await showErrorDialog(context, "Weak Password");
                    } on EmailAlreadyInUseAuthException {
                      await showErrorDialog(context, "Email already in use");
                    } on InvalidEmailAuthException {
                      await showErrorDialog(context, "Invalid Email Address");
                    } on GenericAuthException {
                      await showErrorDialog(context, "Failed to register");
                    }
                  } else {
                    await showErrorDialog(context, "Passwords do not match");
                  }
                },
                child: const Text("Register")),
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: Row(
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      },
                      child: const Text('Login here')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
