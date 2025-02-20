import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/pets_screen.dart';
import '../presentation/screens/home/map_screen.dart';
import '../presentation/screens/home/profile_screen.dart';
import '../features/organization/screens/organization_screen.dart';
import '../features/organization/screens/organization_details_screen.dart';
import '../features/organization/screens/register_organization_screen.dart';
import '../presentation/screens/rescue_request/rescue_request_screen.dart';
import '../presentation/screens/feeding_points/feeding_points_screen.dart';
import '../presentation/screens/feeding_points/add_feeding_point_screen.dart';
import '../presentation/screens/feeding_points/feeding_point_details_screen.dart';
import '../presentation/screens/veterinary/veterinary_screen.dart';
import '../presentation/screens/veterinary/add_veterinary_screen.dart';
import '../presentation/screens/veterinary/veterinary_details_screen.dart';
import '../presentation/screens/pet/add_pet_screen.dart';
import '../presentation/screens/pet/pet_details_screen.dart';
import '../presentation/screens/profile/activity_history_screen.dart';
import '../presentation/screens/profile/favorites_screen.dart';
import '../presentation/screens/profile/my_pets_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/profile/profile_edit_screen.dart';
import '../presentation/screens/profile/notification_settings_screen.dart';
import '../presentation/screens/health_prediction/health_prediction_screen.dart';
import '../presentation/screens/donation/donation_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/screens/chat/chat_detail_screen.dart';
import '../core/models/chat_model.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(
          initialPath: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home/pets',
          builder: (context, state) => const PetsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddPetScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                return PetDetailsScreen(
                  petId: state.pathParameters['id']!,
                  userId: userId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/home/organizations',
          builder: (context, state) => const OrganizationScreen(),
          routes: [
            GoRoute(
              path: 'register',
              builder: (context, state) => const RegisterOrganizationScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => OrganizationDetailsScreen(
                organizationId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/home/rescue-requests',
          builder: (context, state) => const RescueRequestScreen(),
        ),
        GoRoute(
          path: '/home/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/home/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'my-pets',
              builder: (context, state) => const MyPetsScreen(),
            ),
            GoRoute(
              path: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: 'activity-history',
              builder: (context, state) => const ActivityHistoryScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const ProfileEditScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) =>
                      const NotificationSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Additional routes that don't use the bottom navigation bar
    GoRoute(
      path: '/feeding-points',
      builder: (context, state) => const FeedingPointsScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddFeedingPointScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => FeedingPointDetailsScreen(
            pointId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/veterinaries',
      builder: (context, state) => const VeterinaryScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddVeterinaryScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => VeterinaryDetailsScreen(
            vetId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/health-prediction',
      builder: (context, state) => const HealthPredictionScreen(),
    ),
    GoRoute(
      path: '/donations/:petId',
      builder: (context, state) => DonationScreen(
        petId: state.pathParameters['petId']!,
      ),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
      routes: [
        GoRoute(
          path: ':chatId',
          builder: (context, state) {
            final chat = state.extra as ChatModel;
            return ChatDetailScreen(chat: chat);
          },
        ),
      ],
    ),
  ],
);
