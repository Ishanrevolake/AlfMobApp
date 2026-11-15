import 'client_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/workout_controller.dart';

class ClientWorkoutSessionScreen extends ConsumerWidget {
  final String dayOfWeek;
  final bool showBack;

  const ClientWorkoutSessionScreen({
    super.key,
    required this.dayOfWeek,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutPlanState = ref.watch(workoutControllerProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          dayOfWeek,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(letterSpacing: 0),
        ),
      ),
      body: workoutPlanState.when(
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('No plan found.'));
          }

          final dayIndex = plan.days.indexWhere(
            (d) => d.dayOfWeek == dayOfWeek,
          );
          if (dayIndex == -1) {
            return const Center(child: Text('Day not found in plan.'));
          }

          final day = plan.days[dayIndex];
          if (day.rest) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'REST DAY',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontFamily: 'AppSans',
                  ),
                ),
                _dayNotes(context, day.trainerNotes),
              ],
            );
          }

          final total = day.exercises.length;
          final doneCount = day.exercises.where((e) => e.done).length;
          final pct = total > 0 ? doneCount / total : 0.0;
          final allDone = total > 0 && doneCount == total;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              const SizedBox(height: 16),
              Text(
                day.title.toUpperCase(),
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$total ${total == 1 ? 'exercise' : 'exercises'}',
                style: const TextStyle(
                  fontFamily: 'AppSans',
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 5,
                  backgroundColor: AppColors.primaryPanel,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryRed,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap an exercise to watch the demo and log your sets.',
              ),
              const SizedBox(height: 24),
              _dayNotes(context, day.trainerNotes),
              ...List.generate(day.exercises.length, (exerciseIndex) {
                final exercise = day.exercises[exerciseIndex];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ClientExerciseScreen(
                        plan: plan,
                        dayIndex: dayIndex,
                        exerciseIndex: exerciseIndex,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.subtleBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: exercise.done
                                  ? AppColors.primaryRed
                                  : AppColors.strongBorder,
                              width: 1.5,
                            ),
                            color: exercise.done
                                ? AppColors.primaryRed
                                : Colors.transparent,
                          ),
                          child: exercise.done
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.darkTextOverRed,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: exercise.done
                                      ? AppColors.mutedText
                                      : AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${exercise.sets} sets × ${exercise.reps}',
                                style: const TextStyle(
                                  fontFamily: 'AppSans',
                                  fontSize: 12,
                                  color: AppColors.faintText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'View exercise details',
                          icon: const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.faintText,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ClientExerciseScreen(
                                  plan: plan,
                                  dayIndex: dayIndex,
                                  exerciseIndex: exerciseIndex,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: allDone
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session completed!')),
                          );
                          context.pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allDone
                        ? AppColors.primaryRed
                        : Colors.transparent,
                    foregroundColor: allDone
                        ? AppColors.darkTextOverRed
                        : AppColors.primaryText,
                    side: allDone
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.strongBorder),
                  ),
                  child: Text(
                    allDone
                        ? 'FINISH SESSION'
                        : '$doneCount/$total EXERCISES CHECKED OFF',
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _dayNotes(BuildContext context, String notes) => Card(
    margin: const EdgeInsets.only(bottom: 16, top: 8),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trainer notes for this day',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            notes.trim().isEmpty
                ? 'No notes from your trainer for this day yet.'
                : notes,
          ),
        ],
      ),
    ),
  );
}
