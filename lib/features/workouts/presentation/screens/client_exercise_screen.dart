import '../../../../shared/plan_days.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/coach_video.dart';
import '../../../progress/data/daily_log_repository.dart';
import '../../data/models/workout_models.dart';
import '../controllers/workout_controller.dart';

int? recommendedSets(String value) => int.tryParse(value.trim());
num? recommendedReps(String value) {
  final matches = RegExp(r'\d+(?:\.\d+)?').allMatches(value).toList();
  if (matches.isEmpty) return null;
  // For ranges, achieving the lower bound meets the prescription.
  final target = num.tryParse(matches.first.group(0)!);
  return target == null
      ? null
      : RegExp(r'min(?:ute)?s?\b', caseSensitive: false).hasMatch(value)
      ? target * 60
      : target;
}

bool setsMeetTarget(List<Map<String, dynamic>> rows, String sets, String reps) {
  final count = recommendedSets(sets), target = recommendedReps(reps);
  return count != null &&
      count > 0 &&
      target != null &&
      target > 0 &&
      rows
              .where(
                (r) => r['done'] == true && (r['reps'] as num? ?? 0) >= target,
              )
              .length >=
          count;
}

class ClientExerciseScreen extends ConsumerStatefulWidget {
  final WorkoutPlan plan;
  final int dayIndex, exerciseIndex;
  const ClientExerciseScreen({
    super.key,
    required this.plan,
    required this.dayIndex,
    required this.exerciseIndex,
  });
  @override
  ConsumerState<ClientExerciseScreen> createState() =>
      _ClientExerciseScreenState();
}

class _ClientExerciseScreenState extends ConsumerState<ClientExerciseScreen> {
  List<Map<String, dynamic>> rows = [];
  bool busy = true;
  String? error;
  late final DateTime date = _sessionDate();
  DateTime _sessionDate() {
    final now = DateTime.now();
    final day = widget.plan.days[widget.dayIndex].dayOfWeek;
    final index = weekDays.indexWhere(
      (d) => shortPlanDay(d) == shortPlanDay(day),
    );
    return DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1 + (index < 0 ? 0 : index),
    );
  }

  AssignedExercise get exercise =>
      widget.plan.days[widget.dayIndex].exercises[widget.exerciseIndex];
  String get itemId =>
      '${logDate(widget.plan.startDate)}:${widget.plan.days[widget.dayIndex].dayOfWeek}:${exercise.source['id'] ?? widget.exerciseIndex}';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final logs = await ref
          .read(dailyLogRepositoryProvider)
          .read(widget.plan.clientId, date, 'exercise');
      final saved = logs[itemId]?['sets'] as List?;
      if (mounted) {
        setState(
          () => rows = saved == null
              ? List.generate(
                  (recommendedSets(exercise.sets) ?? 1).clamp(1, 50),
                  (_) => <String, dynamic>{'kg': '', 'reps': 0, 'done': false},
                )
              : saved.map((v) => Map<String, dynamic>.from(v as Map)).toList(),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Unable to load set logs. Please retry.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      final complete = setsMeetTarget(rows, exercise.sets, exercise.reps);
      await ref.read(dailyLogRepositoryProvider).save(
        widget.plan.clientId,
        date,
        'exercise',
        itemId,
        {'name': exercise.name, 'sets': rows, 'complete': complete},
      );
      final current = ref
          .read(workoutControllerProvider)
          .value
          ?.days[widget.dayIndex]
          .exercises[widget.exerciseIndex];
      if (current != null && current.done != complete) {
        await ref
            .read(workoutControllerProvider.notifier)
            .toggleExerciseStatus(widget.dayIndex, widget.exerciseIndex);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(complete ? 'Exercise completed!' : 'Sets saved'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save sets. Please retry.')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final video =
        '${exercise.source['video_url'] ?? exercise.source['videoUrl'] ?? ''}';
    final timed = RegExp(
      r'sec|second|hold|min|s\b',
      caseSensitive: false,
    ).hasMatch(exercise.reps);
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            '${exercise.sets} × ${exercise.reps} • Rest ${exercise.source['rest'] ?? 'not specified'}',
          ),
          const SizedBox(height: 20),
          if (video.isNotEmpty)
            CoachVideo(url: video)
          else
            const Text('Your trainer has not added a demo video yet.'),
          const SizedBox(height: 20),
          Text('How to do it', style: Theme.of(context).textTheme.titleLarge),
          Text(
            exercise.cue.isEmpty
                ? 'No instructions provided yet.'
                : exercise.cue,
          ),
          const SizedBox(height: 24),
          Text('Log your sets', style: Theme.of(context).textTheme.titleLarge),
          const Text(
            'Enter actual reps or seconds, then check each completed set. Save to update exercise completion.',
          ),
          if (busy) const LinearProgressIndicator(),
          if (error != null) ...[
            Text(error!),
            TextButton(onPressed: load, child: const Text('Retry')),
          ],
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text('${i + 1}'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '${rows[i]['kg']}',
                      enabled: !busy,
                      decoration: const InputDecoration(
                        labelText: 'kg (optional)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) => rows[i]['kg'] = num.tryParse(v) ?? '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '${rows[i]['reps']}',
                      enabled: !busy,
                      decoration: InputDecoration(
                        labelText: timed ? 'Seconds' : 'Reps',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => rows[i]['reps'] = num.tryParse(v) ?? 0,
                    ),
                  ),
                  Checkbox(
                    value: rows[i]['done'] == true,
                    onChanged: busy
                        ? null
                        : (v) => setState(() => rows[i]['done'] = v),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: busy || error != null
                ? null
                : () => setState(
                    () => rows.add({'kg': '', 'reps': 0, 'done': false}),
                  ),
            icon: const Icon(Icons.add),
            label: const Text('Add set'),
          ),
          FilledButton(
            onPressed: busy || error != null ? null : save,
            child: const Text('Save sets'),
          ),
        ],
      ),
    );
  }
}
