import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:flutter_firebase_login/import.dart';

part 'login.g.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository)
      : assert(_repository != null),
        super(const LoginState());

  final AuthenticationRepository _repository;

  void doEmailChanged(String value) {
    final emailInput = EmailInputModel.dirty(value);
    emit(state.copyWith(
      emailInput: emailInput,
      status: Formz.validate([emailInput, state.passwordInput]),
    ));
  }

  void doPasswordChanged(String value) {
    final passwordInput = PasswordInputModel.dirty(value);
    emit(state.copyWith(
      passwordInput: passwordInput,
      status: Formz.validate([state.emailInput, passwordInput]),
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _repository.logInWithEmailAndPassword(
        email: state.emailInput.value,
        password: state.passwordInput.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _repository.logInWithGoogle();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
      // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }
}

@CopyWith()
class LoginState extends Equatable {
  const LoginState({
    this.emailInput = const EmailInputModel.pure(),
    this.passwordInput = const PasswordInputModel.pure(),
    this.status = FormzStatus.pure,
  });

  final EmailInputModel emailInput;
  final PasswordInputModel passwordInput;
  // TODO: @CopyWithField(required: true)
  final FormzStatus status;

  @override
  List<Object> get props => [emailInput, passwordInput, status];
}
