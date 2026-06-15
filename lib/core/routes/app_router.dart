import 'package:go_router/go_router.dart';
import 'package:service_finder/features/request/presentation/screens/my_requests_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';

import '../../features/provider/data/models/provider_model.dart';
import '../../features/provider/presentation/screens/provider_details_screen.dart';
import '../../features/provider/presentation/screens/provider_requests_screen.dart';
import '../../features/provider/presentation/screens/provider_screen.dart';

import '../../features/request/presentation/screens/create_request_screen.dart';

import '../../features/service/data/models/service_model.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/provider_application/presentation/screens/apply_provider_screen.dart';
import '../../features/provider_application/presentation/screens/my_provider_application_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/map/presentation/screens/providers_map_screen.dart';
import '../../features/provider/presentation/screens/my_provider_screen.dart';
import '../../features/notification/presentation/screens/notifications_screen.dart';
import '../../features/favorite/presentation/screens/my_favorites_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    GoRoute(
      path: '/providers',
      builder: (context, state) {
        final service = state.extra as ServiceModel;

        return ProvidersScreen(service: service);
      },
    ),

    GoRoute(
      path: '/provider-details',
      builder: (context, state) {
        final provider = state.extra as ProviderModel;

        return ProviderDetailsScreen(provider: provider);
      },
    ),

    GoRoute(
      path: '/create-request',
      builder: (context, state) {
        final provider = state.extra as ProviderModel;

        return CreateRequestScreen(provider: provider);
      },
    ),

    GoRoute(
      path: '/provider-requests',
      builder: (context, state) {
        final providerId = state.extra as int;

        return ProviderRequestsScreen(providerId: providerId);
      },
    ),
    GoRoute(
      path: '/apply-provider',
      builder: (context, state) {
        return const ApplyProviderScreen();
      },
    ),
    GoRoute(
      path: '/my-provider-application',
      builder: (context, state) {
        return const MyProviderApplicationScreen();
      },
    ),

    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) {
        return const AdminDashboardScreen();
      },
    ),

    GoRoute(
      path: '/providers-map',
      builder: (context, state) {
        return const ProvidersMapScreen();
      },
    ),

    GoRoute(
      path: '/my-provider',
      builder: (context, state) {
        return const MyProviderScreen();
      },
    ),

    GoRoute(
      path: '/my-requests',
      builder: (context, state) => const MyRequestsScreen(),
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) {
        return const NotificationsScreen();
      },
    ),

    GoRoute(
      path: '/favorites',
      builder: (context, state) {
        return const MyFavoritesScreen();
      },
    ),
  ],
);
