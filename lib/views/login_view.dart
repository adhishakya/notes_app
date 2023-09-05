import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    hintText: "Password", prefixIcon: Icon(Icons.key)),
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
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: password);
                    print(userCredential);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == "user-not-found") {
                      print("User not found");
                    } else if (e.code == "wrong-password") {
                      print("Incorrect password");
                    }
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
                            '/register/', (route) => false);
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
