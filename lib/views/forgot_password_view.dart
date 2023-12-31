import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.emailSent) {
            _email.clear();
            final emailSentConfirmation = SnackBar(
              content: const Text("An email has been sent for password reset"),
              action: SnackBarAction(
                label: "Ok",
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(emailSentConfirmation);
          }
        }
      },
      child: Scaffold(
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
                    final email = _email.text;
                    context.read<AuthBloc>().add(
                          AuthEventResetPassword(email: email),
                        );
                  },
                  child: const Text("Reset Password"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    },
                    child: const Text("Back to Login")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
