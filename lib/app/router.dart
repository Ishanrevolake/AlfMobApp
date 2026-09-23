import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ask_alpha/data/models/ask_alpha_models.dart';
import '../features/ask_alpha/presentation/screens/ask_question_screen.dart';
import '../features/ask_alpha/presentation/screens/client_ask_alpha_screen.dart';
import '../features/ask_alpha/presentation/screens/client_thread_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/client_profile/data/models/profile_models.dart';
import '../features/client_profile/presentation/screens/client_profile_screen.dart';
import '../features/dashboard/presentation/screens/client_home_screen.dart';
import '../features/meal_plans/presentation/screens/client_meals_screen.dart';
import '../features/navigation/presentation/app_shells.dart';
import '../features/trainer/presentation/trainer_client_detail_screen.dart';
import '../features/trainer/presentation/trainer_pages.dart';
import '../features/workouts/presentation/screens/client_workout_library_screen.dart';
import '../features/workouts/presentation/screens/client_workout_session_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (auth.isLoading) return null;
      final loggedIn = user != null;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const _RoleGate()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => ClientAppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/client/home',
                builder: (_, __) => const ClientHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/client/train',
                builder: (_, __) => const ClientWorkoutLibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/client/ask-alpha',
                builder: (_, __) => const ClientAskAlphaScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/client/meals',
                builder: (_, __) => const ClientMealsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/client/profile',
                builder: (_, __) => const ClientProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/client/session/:day',
        builder: (_, state) => ClientWorkoutSessionScreen(
          dayOfWeek: state.pathParameters['day'] ?? 'MON',
        ),
      ),
      GoRoute(
        path: '/client/ask-alpha/new',
        builder: (_, __) => const AskQuestionScreen(),
      ),
      GoRoute(
        path: '/client/ask-alpha/thread/:id',
        builder: (_, state) => ClientThreadScreen(
          threadId: state.pathParameters['id']!,
          thread: state.extra is AskAlphaThread
              ? state.extra! as AskAlphaThread
              : null,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => TrainerAppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trainer/home',
                builder: (_, __) => const TrainerOverviewPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trainer/clients',
                builder: (_, __) => const TrainerClientsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trainer/programs',
                builder: (_, __) => const TrainerProgramsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trainer/library',
                builder: (_, __) => const TrainerLibraryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trainer/more',
                builder: (_, __) => const TrainerMorePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/trainer/client/:id',
        builder: (_, state) => TrainerClientDetailScreen(
          clientId: state.pathParameters['id']!,
          client: state.extra is ClientProfile
              ? state.extra! as ClientProfile
              : null,
        ),
      ),
      GoRoute(
        path: '/trainer/payments',
        builder: (_, __) => const TrainerPaymentsScreen(),
      ),
      GoRoute(
        path: '/trainer/ask-payments',
        builder: (_, __) => const TrainerPaymentsScreen(askAlpha: true),
      ),
      GoRoute(
        path: '/trainer/ask-inbox',
        builder: (_, __) => const TrainerAskInboxScreen(),
      ),
      GoRoute(
        path: '/trainer/ask-inbox/:id',
        builder: (_, state) => TrainerThreadScreen(
          threadId: state.pathParameters['id']!,
          thread: state.extra is Map<String, dynamic>
              ? state.extra! as Map<String, dynamic>
              : null,
        ),
      ),
      GoRoute(
        path: '/trainer/section/:section',
        builder: (_, state) => TrainerSectionScreen(
          section: state.pathParameters['section'] ?? 'analytics',
        ),
      ),
      GoRoute(path: '/ask-alpha', redirect: (_, __) => '/client/ask-alpha'),
      GoRoute(path: '/meals', redirect: (_, __) => '/client/meals'),
      GoRoute(path: '/profile', redirect: (_, __) => '/client/profile'),
      GoRoute(
        path: '/session/:day',
        redirect: (_, state) =>
            '/client/session/${state.pathParameters['day']}',
      ),
    ],
  );
});

class _RoleGate extends ConsumerWidget {
  const _RoleGate();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    return role.when(
      data: (value) {
        final trainer =
            value == 'admin' || value == 'trainer' || value == 'coach';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted)
            context.go(trainer ? '/trainer/home' : '/client/home');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Unable to load account role: $error')),
      ),
    );
  }
}
