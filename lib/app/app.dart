import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'configuration/supabase_config.dart';
import '../shared/widgets/responsive_layout.dart';
import 'client_plan_sync.dart';

class AlfaleeApp extends ConsumerWidget {
  const AlfaleeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.isConfigured) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Supabase is not configured.\nProvide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Alfa Lee',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) => ClientPlanSync(
        child: AlfAppViewport(child: child ?? const SizedBox.shrink()),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
