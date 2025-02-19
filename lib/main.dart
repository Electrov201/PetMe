import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Core imports
import 'core/models/chat_model.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';
import 'core/routes.dart';
import 'core/config/app_config.dart';

// Feature imports
import 'features/organization/screens/organization_screen.dart';
import 'features/organization/screens/register_organization_screen.dart';
import 'features/organization/screens/organization_details_screen.dart';

// Presentation imports
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/home/pets_screen.dart';
import 'presentation/screens/home/map_screen.dart';
import 'presentation/screens/home/profile_screen.dart';
import 'presentation/screens/profile/activity_history_screen.dart';
import 'presentation/screens/profile/favorites_screen.dart';
import 'presentation/screens/profile/my_pets_screen.dart';
import 'presentation/screens/profile/settings_screen.dart';
import 'presentation/screens/rescue_request/rescue_request_screen.dart';
import 'presentation/screens/feeding_point/feeding_point_screen.dart';
import 'presentation/screens/veterinary/veterinary_screen.dart';
import 'presentation/screens/donation/donation_screen.dart';
import 'presentation/screens/health_prediction/health_prediction_screen.dart';
import 'presentation/screens/pet/add_pet_screen.dart';
import 'presentation/screens/pet/pet_details_screen.dart';
import 'presentation/screens/profile/profile_edit_screen.dart';
import 'presentation/screens/profile/notification_settings_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/chat/chat_detail_screen.dart';
import 'presentation/screens/veterinary/add_veterinary_screen.dart';
import 'presentation/screens/veterinary/veterinary_details_screen.dart';
import 'presentation/screens/feeding_point/add_feeding_point_screen.dart';
import 'presentation/screens/feeding_point/feeding_point_details_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const SplashScreen(),
    redirect: (context, state) {
      // Add any global redirection logic here if needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'pets',
            name: 'pets',
            builder: (context, state) => const PetsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-new-pet',
                builder: (context, state) => const AddPetScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'pet-details',
                builder: (context, state) {
                  final petId = state.pathParameters['id']!;
                  final userId = state.extra as String? ??
                      FirebaseAuth.instance.currentUser?.uid ??
                      '';
                  return PetDetailsScreen(
                    petId: petId,
                    userId: userId,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'organizations',
            name: 'organizations',
            builder: (context, state) => const OrganizationScreen(),
            routes: [
              GoRoute(
                path: 'register',
                name: 'register-organization',
                builder: (context, state) => const RegisterOrganizationScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'organization-details',
                builder: (context, state) => OrganizationDetailsScreen(
                  organizationId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'map',
            name: 'map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'my-pets',
                name: 'my-pets',
                builder: (context, state) => const MyPetsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-my-pet',
                    builder: (context, state) => const AddPetScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'my-pet-details',
                    builder: (context, state) {
                      final petId = state.pathParameters['id']!;
                      final userId =
                          FirebaseAuth.instance.currentUser?.uid ?? '';
                      return PetDetailsScreen(
                        petId: petId,
                        userId: userId,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: 'activity-history',
                name: 'activity-history',
                builder: (context, state) => const ActivityHistoryScreen(),
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'profile-edit',
                    builder: (context, state) => const ProfileEditScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: 'notification-settings',
                    builder: (context, state) =>
                        const NotificationSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'rescue-requests',
            name: 'rescueRequests',
            builder: (context, state) => const RescueRequestScreen(),
          ),
          GoRoute(
            path: 'feeding-points',
            name: 'feedingPoints',
            builder: (context, state) => const FeedingPointScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-feeding-point',
                builder: (context, state) => const AddFeedingPointScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'feeding-point-details',
                builder: (context, state) => FeedingPointDetailsScreen(
                  pointId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'veterinaries',
            name: 'veterinaries',
            builder: (context, state) => const VeterinaryScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-veterinary',
                builder: (context, state) => const AddVeterinaryScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'veterinary-details',
                builder: (context, state) => VeterinaryDetailsScreen(
                  vetId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'donations/:petId',
            name: 'donations',
            builder: (context, state) {
              final petId = state.pathParameters['petId'] ?? '';
              return DonationScreen(petId: petId);
            },
          ),
          GoRoute(
            path: 'health-prediction',
            name: 'healthPrediction',
            builder: (context, state) => const HealthPredictionScreen(),
          ),
          GoRoute(
            path: 'chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
            routes: [
              GoRoute(
                path: ':chatId',
                name: 'chat-detail',
                builder: (context, state) => ChatDetailScreen(
                  chat: state.extra as ChatModel,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: AppConfig.firebaseApiKey,
      appId: AppConfig.firebaseAppId,
      messagingSenderId: AppConfig.firebaseMessagingSenderId,
      projectId: AppConfig.firebaseProjectId,
      storageBucket: AppConfig.firebaseStorageBucket,
      authDomain: AppConfig.firebaseAuthDomain,
    ),
  );

  // Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
