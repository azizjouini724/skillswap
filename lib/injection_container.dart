import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import 'core/services/auth_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<AuthService>(() => AuthService(sl<FirebaseAuth>()));

  // Auth : data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      authService: sl<AuthService>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Auth : use cases
  sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl<AuthRepository>()));

  // Auth : bloc (singleton, car le routeur en a besoin)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      watchAuthState: sl<WatchAuthStateUseCase>(),
      signIn: sl<SignInUseCase>(),
      signUp: sl<SignUpUseCase>(),
      signOut: sl<SignOutUseCase>(),
      resetPassword: sl<ResetPasswordUseCase>(),
    ),
  );
}