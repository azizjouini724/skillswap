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
import 'features/matching/domain/usecases/get_matches_usecase.dart';
import 'features/matching/presentation/bloc/match_bloc.dart';
import 'features/exchanges/data/datasources/exchange_remote_datasource.dart';
import 'features/exchanges/data/repositories/exchange_repository_impl.dart';
import 'features/exchanges/domain/repositories/exchange_repository.dart';
import 'features/exchanges/domain/usecases/propose_session_usecase.dart';
import 'features/exchanges/domain/usecases/send_exchange_request_usecase.dart';
import 'features/exchanges/domain/usecases/update_exchange_status_usecase.dart';
import 'features/exchanges/domain/usecases/update_session_status_usecase.dart';
import 'features/exchanges/domain/usecases/watch_exchanges_usecase.dart';
import 'features/exchanges/domain/usecases/watch_sessions_usecase.dart';
import 'features/exchanges/presentation/bloc/exchange_bloc.dart';
import 'package:skillswap/features/exchanges/domain/usecases/counter_propose_session_usecase.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/create_notification_usecase.dart';
import 'features/notifications/domain/usecases/mark_notifications_read_usecase.dart';
import 'features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/mark_chat_read_usecase.dart';
import 'features/chat/domain/usecases/open_chat_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/domain/usecases/watch_chat_usecase.dart';
import 'features/chat/domain/usecases/watch_chats_usecase.dart';
import 'features/chat/domain/usecases/watch_messages_usecase.dart';
import 'features/chat/presentation/bloc/chat_list_bloc.dart';
import 'features/chat/presentation/bloc/chat_room_bloc.dart';
import 'features/credits/data/datasources/credits_remote_datasource.dart';
import 'features/credits/data/repositories/credits_repository_impl.dart';
import 'features/credits/domain/repositories/credits_repository.dart';
import 'features/credits/domain/usecases/credits_usecases.dart';
import 'features/credits/presentation/bloc/credits_bloc.dart';
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
    // Matching
  sl.registerLazySingleton(() => GetMatchesUseCase(sl<DiscoverRepository>()));
  sl.registerFactory<MatchBloc>(
    () => MatchBloc(getMatches: sl<GetMatchesUseCase>()),
  );
    // Exchanges
  sl.registerLazySingleton<ExchangeRemoteDataSource>(
    () => ExchangeRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ExchangeRepository>(
    () => ExchangeRepositoryImpl(sl<ExchangeRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => WatchExchangesUseCase(sl<ExchangeRepository>()));
  sl.registerLazySingleton(() => WatchSessionsUseCase(sl<ExchangeRepository>()));
  sl.registerLazySingleton(
      () => SendExchangeRequestUseCase(sl<ExchangeRepository>()));
  sl.registerLazySingleton(
      () => UpdateExchangeStatusUseCase(sl<ExchangeRepository>()));
  sl.registerLazySingleton(() => ProposeSessionUseCase(sl<ExchangeRepository>()));
  sl.registerLazySingleton(
      () => UpdateSessionStatusUseCase(sl<ExchangeRepository>()));
  sl.registerLazySingleton(
      () => CounterProposeSessionUseCase(sl<ExchangeRepository>()));
  sl.registerFactory<ExchangeBloc>(
    () => ExchangeBloc(
      watchExchanges: sl<WatchExchangesUseCase>(),
      watchSessions: sl<WatchSessionsUseCase>(),
      sendRequest: sl<SendExchangeRequestUseCase>(),
      updateExchangeStatus: sl<UpdateExchangeStatusUseCase>(),
      proposeSession: sl<ProposeSessionUseCase>(),
      updateSessionStatus: sl<UpdateSessionStatusUseCase>(),
      counterProposeSession: sl<CounterProposeSessionUseCase>(),
      createNotification: sl<CreateNotificationUseCase>(),
    ),
  );
    // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDataSource>()),
  );
  sl.registerLazySingleton(
      () => WatchNotificationsUseCase(sl<NotificationRepository>()));
  sl.registerLazySingleton(
      () => CreateNotificationUseCase(sl<NotificationRepository>()));
  sl.registerLazySingleton(
      () => MarkNotificationsReadUseCase(sl<NotificationRepository>()));
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      watchNotifications: sl<WatchNotificationsUseCase>(),
      markRead: sl<MarkNotificationsReadUseCase>(),
    ),
  );
    // Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl<ChatRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => WatchChatsUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => WatchChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => WatchMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => OpenChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => MarkChatReadUseCase(sl<ChatRepository>()));
  sl.registerFactory<ChatListBloc>(
    () => ChatListBloc(watchChats: sl<WatchChatsUseCase>()),
  );
  sl.registerFactory<ChatRoomBloc>(
    () => ChatRoomBloc(
      openChat: sl<OpenChatUseCase>(),
      watchChat: sl<WatchChatUseCase>(),
      watchMessages: sl<WatchMessagesUseCase>(),
      sendMessage: sl<SendMessageUseCase>(),
      markChatRead: sl<MarkChatReadUseCase>(),
    ),
  );
    // Credits
  sl.registerLazySingleton<CreditsRemoteDataSource>(
    () => CreditsRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<CreditsRepository>(
    () => CreditsRepositoryImpl(sl<CreditsRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => WatchTransactionsUseCase(sl<CreditsRepository>()));
  sl.registerLazySingleton(() => WatchCompletedSessionsUseCase(sl<CreditsRepository>()));
  sl.registerLazySingleton(() => ClaimProfileBonusUseCase(sl<CreditsRepository>()));
  sl.registerLazySingleton(() => ClaimSessionCreditsUseCase(sl<CreditsRepository>()));
  sl.registerFactory<CreditsBloc>(
    () => CreditsBloc(
      watchTransactions: sl<WatchTransactionsUseCase>(),
      watchCompletedSessions: sl<WatchCompletedSessionsUseCase>(),
      claimBonus: sl<ClaimProfileBonusUseCase>(),
      claimSession: sl<ClaimSessionCreditsUseCase>(),
    ),
  );
}