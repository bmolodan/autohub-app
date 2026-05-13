import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/composition/auth_providers.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/phone_screen.dart';
import '../../features/booking/presentation/problem_form_screen.dart';
import '../../features/booking/presentation/service_picker_screen.dart';
import '../../features/cars/adapters/inbound/add_car_screen.dart';
import '../../features/cars/adapters/inbound/car_detail_screen.dart';
import '../../features/cars/adapters/inbound/cars_list_screen.dart';
import '../../features/history/adapters/inbound/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/orders/adapters/inbound/order_detail_screen.dart';
import '../../features/profile/adapters/inbound/register_client_screen.dart';
import '../../features/profile/composition/profile_providers.dart';
import '../../features/profile/presentation/account_delete_screen.dart';
import '../../features/profile/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../theme/theme_showcase.dart';
import '../widgets/app_shell.dart';
import '../widgets/states_showcase.dart';

/// Named route paths — referenced everywhere instead of raw strings.
class AppRoutes {
  AppRoutes._();
  static const onboarding = '/onboarding';
  static const phone = '/auth/phone';
  static const otp = '/auth/otp';
  static const register = '/register';
  static const profileEdit = '/profile/edit';

  // Shell tabs
  static const home = '/home';
  static const history = '/history';
  static const cars = '/cars';
  static const profile = '/profile';

  // Booking flow
  static const bookingService = '/booking/service';
  static const bookingProblem = '/booking/problem';

  // Cars sub-routes (outside the shell)
  static const carAdd = '/cars/add';
  static const carEdit = '/cars/edit';
  static const carDetail = '/cars/detail';

  // Profile sub-routes (outside the shell)
  static const profileNotifications = '/profile/notifications';
  static const profileAccountDelete = '/profile/account/delete';

  // Order detail (outside the shell)
  static const orderDetail = '/orders';

  static const showcase = '/dev/showcase';
  static const devStates = '/dev/states';
}

/// Routes accessible without a signed-in session.
const _publicRoutes = <String>{
  AppRoutes.onboarding,
  AppRoutes.phone,
  AppRoutes.otp,
  AppRoutes.showcase,
  AppRoutes.devStates,
};

/// Bridges Riverpod auth and profile state to GoRouter's Listenable-based
/// refresh API. Profile state needs to drive redirects too — first-time
/// users get bounced to /register after session is loaded but before
/// profile finishes loading.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen<AsyncValue<Object?>>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<AsyncValue<Object?>>(
      clientProfileControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

/// Single source of truth for navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authControllerProvider).asData?.value;
      final isPublic = _publicRoutes.any(
        (p) =>
            state.matchedLocation == p || state.matchedLocation.startsWith(p),
      );
      if (session == null && !isPublic) {
        return AppRoutes.onboarding;
      }
      if (session != null &&
          (state.matchedLocation == AppRoutes.onboarding ||
              state.matchedLocation == AppRoutes.phone ||
              state.matchedLocation == AppRoutes.otp)) {
        // Defer to the profile-required check below.
      }
      if (session != null) {
        final profileAsync = ref.read(clientProfileControllerProvider);
        final profile = profileAsync.asData?.value;
        final atRegister = state.matchedLocation == AppRoutes.register;
        if (profileAsync is AsyncData && profile == null && !atRegister) {
          return AppRoutes.register;
        }
        if (profile != null &&
            (state.matchedLocation == AppRoutes.onboarding ||
                state.matchedLocation == AppRoutes.phone ||
                state.matchedLocation == AppRoutes.otp ||
                atRegister)) {
          return AppRoutes.home;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.phone,
        builder: (_, __) => const PhoneScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
          challengeId: state.uri.queryParameters['challengeId'] ?? '',
        ),
      ),

      // Tabbed shell — Home / History / Cars / Profile share the bottom nav.
      ShellRoute(
        builder: (_, __, Widget child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.cars,
            builder: (_, __) => const CarsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Booking flow (outside the shell — full-screen modal feel)
      GoRoute(
        path: AppRoutes.bookingService,
        builder: (_, __) => const ServicePickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingProblem,
        builder: (_, state) => ProblemFormScreen(
          serviceId: state.uri.queryParameters['serviceId'] ?? '',
        ),
      ),

      // Cars detail / add (outside the shell)
      GoRoute(
        path: AppRoutes.carAdd,
        builder: (_, __) => const AddCarScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.carEdit}/:id',
        builder: (_, state) =>
            AddCarScreen(editVehicleId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '${AppRoutes.carDetail}/:id',
        builder: (_, state) => CarDetailScreen(
          vehicleId: state.pathParameters['id']!,
        ),
      ),

      // Order detail (outside the shell)
      GoRoute(
        path: '${AppRoutes.orderDetail}/:id',
        builder: (_, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),

      // Profile sub-routes (outside the shell)
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterClientScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (_, __) => const RegisterClientScreen(editMode: true),
      ),
      GoRoute(
        path: AppRoutes.profileNotifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileAccountDelete,
        builder: (_, __) => const AccountDeleteScreen(),
      ),

      // Dev-only routes.
      GoRoute(
        path: AppRoutes.showcase,
        builder: (_, __) => const ThemeShowcase(),
      ),
      GoRoute(
        path: AppRoutes.devStates,
        builder: (_, __) => const StatesShowcase(),
      ),
    ],
  );
});
