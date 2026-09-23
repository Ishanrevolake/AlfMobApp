import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/workout_models.dart';

Future<void> showExerciseDetails(
  BuildContext context,
  AssignedExercise exercise,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (context) => ExerciseDetailsSheet(exercise: exercise),
);

class ExerciseDetailsSheet extends StatelessWidget {
  final AssignedExercise exercise;
  const ExerciseDetailsSheet({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final rest = exercise.source['rest']?.toString().trim() ?? '';
    final tempo = exercise.source['tempo']?.toString().trim() ?? '';
    final notes = exercise.cue.trim();
    final stats = <(IconData, String, String)>[
      (
        Icons.repeat,
        'Sets',
        exercise.sets.trim().isEmpty ? 'Not specified' : exercise.sets,
      ),
      (
        Icons.fitness_center,
        'Reps',
        exercise.reps.trim().isEmpty ? 'Not specified' : exercise.reps,
      ),
      (
        Icons.timer_outlined,
        'Rest between sets',
        rest.isEmpty ? 'Not specified' : rest,
      ),
      if (tempo.isNotEmpty) (Icons.speed, 'Tempo', tempo),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: AppColors.primaryRed,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your exercise',
                      style: theme.labelLarge?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close exercise details',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(exercise.name, style: theme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    exercise.done ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: exercise.done
                        ? AppColors.primaryRed
                        : AppColors.mutedText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    exercise.done ? 'Completed' : 'To complete',
                    style: theme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth < 280 ||
                          MediaQuery.textScalerOf(context).scale(14) > 21
                      ? 1
                      : 2;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final stat in stats)
                        SizedBox(
                          width: width,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryPanel,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.strongBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  stat.$1,
                                  color: AppColors.primaryRed,
                                  size: 22,
                                ),
                                const SizedBox(height: 12),
                                Text(stat.$3, style: theme.titleLarge),
                                const SizedBox(height: 4),
                                Text(stat.$2, style: theme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Coach notes', style: theme.titleMedium),
                const SizedBox(height: 8),
                Text(notes, style: theme.bodyLarge),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Back to workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
