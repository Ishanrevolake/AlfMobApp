import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/workouts/presentation/controllers/workout_controller.dart';
import '../features/meal_plans/presentation/controllers/meal_controller.dart';

/// Realtime is the fast path. Polling also works when a server has not enabled
/// the tables in its Realtime publication or a socket temporarily disconnects.
final clientPlanChangesProvider = StreamProvider.autoDispose<int>((ref) {
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));
  final role = ref.watch(userRoleProvider).value;
  if (userId == null || role != 'client') return const Stream.empty();
  final client = ref.watch(supabaseProvider);
  final events = StreamController<int>();
  var revision = 0;
  var disposed = false;
  void changed() {
    if (!disposed) events.add(++revision);
  }

  final channel = client.channel('client-plans-$userId');
  for (final table in ['client_workout_plans', 'client_meal_plans']) {
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'client_id',
        value: userId,
      ),
      callback: (_) => changed(),
    );
  }
  channel.subscribe((status, error) {
    if (status == RealtimeSubscribeStatus.subscribed) changed();
  });
  final timer = Timer.periodic(const Duration(seconds: 30), (_) => changed());
  ref.onDispose(() {
    disposed = true;
    timer.cancel();
    unawaited(client.removeChannel(channel));
    unawaited(events.close());
  });
  return events.stream;
});

class ClientPlanSync extends ConsumerStatefulWidget {
  final Widget child;
  const ClientPlanSync({super.key, required this.child});
  @override
  ConsumerState<ClientPlanSync> createState() => _ClientPlanSyncState();
}

class _ClientPlanSyncState extends ConsumerState<ClientPlanSync>
    with WidgetsBindingObserver {
  bool foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void refresh() {
    ref.invalidate(workoutControllerProvider);
    ref.invalidate(mealControllerProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = state == AppLifecycleState.resumed;
    if (active && !foreground) refresh();
    setState(() => foreground = active);
  }

  @override
  Widget build(BuildContext context) {
    if (foreground) {
      ref.listen(clientPlanChangesProvider, (previous, next) {
        if (next.hasValue && next.value != previous?.value) refresh();
      });
    }
    return widget.child;
  }
}
