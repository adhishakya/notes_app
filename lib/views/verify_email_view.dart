import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify email"),
      ),
      body: Column(
        children: [
          const Text(
              "A verification link has been sent to your email address. Please Click the link to verify your email address."),
          const Text(
              "If you haven't received a link yet, click here to receive it."),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
            },
            child: const Text("Click here to get a link"),
          ),
          TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
              },
              child: const Text("Restart the registration process"))
        ],
      ),
    );
  }
}
