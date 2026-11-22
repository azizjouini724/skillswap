import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/add_skill_usecase.dart';
import 'features/profile/domain/usecases/remove_skill_usecase.dart';
import 'features/profile/domain/usecases/update_photo_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/watch_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';
import 'firebase_options.dart';
import 'features/discover/data/datasources/discover_remote_datasource.dart';
import 'features/discover/data/repositories/discover_repository_impl.dart';
import 'features/discover/domain/repositories/discover_repository.dart';
import 'features/discover/domain/usecases/get_discover_profiles_usecase.dart';
import 'features/discover/presentation/bloc/discover_bloc.dart';
final sl = GetIt.instance;

Future<void> init() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();

  // Externes
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
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

  // Thème : bloc (singleton, lu par MaterialApp)
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc(sl<SharedPreferences>()));

  // Profile : data
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // Profile : use cases
  sl.registerLazySingleton(() => WatchProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => AddSkillUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => RemoveSkillUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdatePhotoUseCase(sl<ProfileRepository>()));

  // Profile : bloc (factory : une nouvelle instance à chaque connexion)
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      watchProfile: sl<WatchProfileUseCase>(),
      updateProfile: sl<UpdateProfileUseCase>(),
      addSkill: sl<AddSkillUseCase>(),
      removeSkill: sl<RemoveSkillUseCase>(),
      updatePhoto: sl<UpdatePhotoUseCase>(),
    ),
  );
    // Discover
  sl.registerLazySingleton<DiscoverRemoteDataSource>(
    () => DiscoverRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<DiscoverRepository>(
    () => DiscoverRepositoryImpl(sl<DiscoverRemoteDataSource>()),
  );
  sl.registerLazySingleton(
    () => GetDiscoverProfilesUseCase(sl<DiscoverRepository>()),
  );
  sl.registerFactory<DiscoverBloc>(
    () => DiscoverBloc(getProfiles: sl<GetDiscoverProfilesUseCase>()),
  );
}