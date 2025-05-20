import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? address;

  const AuthRegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.address,
  });

  @override
  List<Object?> get props => [name, email, password, role, phoneNumber, address];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthUpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? phoneNumber;
  final String? address;
  final String? profileImage;

  const AuthUpdateProfileEvent({
    this.name,
    this.phoneNumber,
    this.address,
    this.profileImage,
  });

  @override
  List<Object?> get props => [name, phoneNumber, address, profileImage];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final UserModel user;

  const AuthAuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitialState()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthUpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());
      await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      final user = await _authRepository.getCurrentUser();
      emit(AuthAuthenticatedState(user: user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());
      await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());
      await _authRepository.logout();
      emit(AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoadingState());
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        emit(AuthAuthenticatedState(user: user));
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(AuthUpdateProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await _authRepository.updateProfile(
        name: event.name,
        phoneNumber: event.phoneNumber,
        address: event.address,
        profileImage: event.profileImage,
      );
      final user = await _authRepository.getCurrentUser();
      emit(AuthAuthenticatedState(user: user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
} 