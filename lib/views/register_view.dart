import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _passwordVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
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
                    hintText: "Email Address", prefixIcon: Icon(Icons.email)),
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
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                ),
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                    if (context.mounted) {
                      Navigator.of(context).pushNamed(verifyEmailRoute);
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == "weak-password") {
                      await showErrorDialog(context, "Weak Password");
                    } else if (e.code == "email-already-in-use") {
                      showErrorDialog(context, "Email already in use");
                    } else if (e.code == "invalid-email") {
                      showErrorDialog(context, "Invalid Email Address");
                    } else {
                      showErrorDialog(context, "Error - ${e.code}");
                    }
                  } catch (e) {
                    showErrorDialog(context, e.toString());
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
