import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    //initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(
          const AuthStateNeedsVerification(isLoading: false),
        );
      } else {
        emit(
          AuthStateLoggedIn(user: user, isLoading: false),
        );
      }
    });

    //register
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    //email verification
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    //register
    on<AuthEventRegister>(
      (event, emit) async {
        final String email = event.email;
        final String password = event.password;
        try {
          await provider.createUser(
            email: email,
            password: password,
          );
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(
            isLoading: false,
          ));
        } on Exception catch (e) {
          emit(AuthStateRegistering(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );

    //reset password
    on<AuthEventResetPassword>(
      (event, emit) async {
        final String email = event.email;

        emit(
          const AuthStateForgotPassword(
            exception: null,
            emailSent: false,
            isLoading: false,
          ),
        );

        // ignore: unnecessary_null_comparison
        if (email == null) {
          return;
        } else {
          emit(
            const AuthStateForgotPassword(
              exception: null,
              emailSent: false,
              isLoading: true,
            ),
          );
        }

        bool didSendEmail;
        Exception? exception;
        try {
          await provider.resetPassword(email: email);
          didSendEmail = true;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
        }
        emit(
          AuthStateForgotPassword(
            exception: exception,
            emailSent: didSendEmail,
            isLoading: false,
          ),
        );
      },
    );

    //login
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: "Logging in",
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    //logout
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
  }
}
