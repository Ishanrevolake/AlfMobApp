import '../../meal_plans/data/models/meal_models.dart';
import '../../../shared/plan_days.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progress/data/daily_log_repository.dart';

class TrainerDailyLogs extends ConsumerStatefulWidget {
  final String clientId;
  final ClientMealPlan? plan;
  const TrainerDailyLogs({super.key, required this.clientId, this.plan});
  @override
  ConsumerState<TrainerDailyLogs> createState() => _TrainerDailyLogsState();
}

class _TrainerDailyLogsState extends ConsumerState<TrainerDailyLogs> {
  DateTime date = DateTime.now();
  late Future<List<Map<String, Map<String, dynamic>>>> logs = load();
  Future<List<Map<String, Map<String, dynamic>>>> load() => Future.wait([
    for (final kind in ['meal', 'exercise'])
      ref.read(dailyLogRepositoryProvider).read(widget.clientId, date, kind),
  ]);
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      TextButton.icon(
        icon: const Icon(Icons.calendar_month),
        label: Text(logDate(date)),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null && mounted) {
            setState(() {
              date = picked;
              logs = load();
            });
          }
        },
      ),
      FutureBuilder(
        future: logs,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TextButton(
              onPressed: () => setState(() => logs = load()),
              child: const Text('Unable to load activity. Retry'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final meals = snapshot.data![0].values.where(
            (m) => m['deleted'] != true && m['eaten'] == true,
          );
          final kcal = meals.fold<num>(
            0,
            (s, m) => s + (m['kcal'] as num? ?? 0),
          );
          final protein = meals.fold<num>(
            0,
            (s, m) => s + (m['protein'] as num? ?? 0),
          );
          final planned =
              widget.plan?.days
                  .where(
                    (d) =>
                        shortPlanDay(d.dayOfWeek) ==
                        shortPlanDay(weekDays[date.weekday - 1]),
                  )
                  .firstOrNull
                  ?.meals
                  .fold<int>(0, (sum, meal) => sum + meal.kcal) ??
              0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$planned kcal planned | $kcal kcal eaten • ${protein}g protein',
              ),
              for (final m in meals)
                ListTile(
                  title: Text('${m['name']}'),
                  subtitle: Text(
                    '${m['kcal']} kcal${m['extra'] == true ? ' • Extra meal' : ''}',
                  ),
                ),
              const Divider(),
              const Text('Exercise logs'),
              for (final e in snapshot.data![1].values)
                ListTile(
                  title: Text('${e['name']}'),
                  subtitle: Text(
                    (e['sets'] as List? ?? [])
                        .asMap()
                        .entries
                        .map(
                          (r) =>
                              'Set ${r.key + 1}: ${(r.value as Map)['reps']} reps/sec, ${r.value['kg']} kg${r.value['done'] == true ? ' ✓' : ''}',
                        )
                        .join('\n'),
                  ),
                ),
              if (meals.isEmpty && snapshot.data![1].isEmpty)
                const Text('No activity logged for this date.'),
            ],
          );
        },
      ),
    ],
  );
}
