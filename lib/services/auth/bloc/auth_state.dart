import 'package:flutter/foundation.dart' show immutable;
import 'package:notes_app/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = "Please wait a moment",
  });
  get exception => null;
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  @override
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateForgotPassword extends AuthState {
  @override
  final Exception? exception;
  final bool emailSent;
  const AuthStateForgotPassword({
    required this.emailSent,
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  @override
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}
