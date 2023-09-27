import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_service.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _email;

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            const Text("Please enter your email address."),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _email,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: "Email address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email)),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: TextButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.purple),
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                ),
                onPressed: () async {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  final emailSentConfirmation = SnackBar(
                    content:
                        const Text("An email has been sent for password reset"),
                    // behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: "Ok",
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (route) => false,
                        );
                      },
                    ),
                  );
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(emailSentConfirmation);
                  final email = _email.text;
                  await AuthService.firebase().resetPassword(
                    email: email,
                  );
                },
                child: const Text("Reset Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
