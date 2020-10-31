import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:flutter_firebase_login/import.dart';

part 'sign_up.g.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this.authenticationRepository)
      : assert(authenticationRepository != null),
        super(const SignUpState());

  final AuthenticationRepository authenticationRepository;

  void doEmailChanged(String value) {
    final emailInput = EmailInputModel.dirty(value);
    emit(state.copyWith(
      emailInput: emailInput,
      status: Formz.validate([
        emailInput,
        state.passwordInput,
        state.confirmedPasswordInput,
      ]),
    ));
  }

  void doPasswordChanged(String value) {
    final passwordInput = PasswordInputModel.dirty(value);
    final confirmedPasswordInput = ConfirmedPasswordInputModel.dirty(
      password: passwordInput.value,
      value: state.confirmedPasswordInput.value,
    );
    emit(state.copyWith(
      passwordInput: passwordInput,
      confirmedPasswordInput: confirmedPasswordInput,
      status: Formz.validate([
        state.emailInput,
        passwordInput,
        state.confirmedPasswordInput,
      ]),
    ));
  }

  void doConfirmedPasswordChanged(String value) {
    final confirmedPasswordInput = ConfirmedPasswordInputModel.dirty(
      password: state.passwordInput.value,
      value: value,
    );
    emit(state.copyWith(
      confirmedPasswordInput: confirmedPasswordInput,
      status: Formz.validate([
        state.emailInput,
        state.passwordInput,
        confirmedPasswordInput,
      ]),
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await authenticationRepository.signUp(
        email: state.emailInput.value,
        password: state.passwordInput.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}

@CopyWith()
class SignUpState extends Equatable {
  const SignUpState({
    this.emailInput = const EmailInputModel.pure(),
    this.passwordInput = const PasswordInputModel.pure(),
    this.confirmedPasswordInput = const ConfirmedPasswordInputModel.pure(),
    this.status = FormzStatus.pure,
  });

  final EmailInputModel emailInput;
  final PasswordInputModel passwordInput;
  final ConfirmedPasswordInputModel confirmedPasswordInput;
  // TODO: @CopyWithField(required: true)
  final FormzStatus status;

  @override
  List<Object> get props =>
      [emailInput, passwordInput, confirmedPasswordInput, status];
}
