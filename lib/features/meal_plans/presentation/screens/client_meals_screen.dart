import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/plan_days.dart';
import '../controllers/meal_controller.dart';
import '../widgets/meal_details.dart';
import 'package:intl/intl.dart';

class ClientMealsScreen extends ConsumerStatefulWidget {
  final String? initialDay;
  const ClientMealsScreen({super.key, this.initialDay});

  @override
  ConsumerState<ClientMealsScreen> createState() => _ClientMealsScreenState();
}

class _ClientMealsScreenState extends ConsumerState<ClientMealsScreen> {
  String? selectedDay;
  bool logging = false;
  @override
  Widget build(BuildContext context) {
    final mealPlanState = ref.watch(mealControllerProvider);
    final currentDayStr = DateFormat('EEEE')
        .format(DateTime.now())
        .toUpperCase()
        .substring(0, 3); // 'MON', 'TUE', etc.

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALFA LEE',
          style: TextStyle(fontFamily: 'AppSans', color: AppColors.primaryRed),
        ),
      ),
      body: mealPlanState.when(
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('No meal plan assigned.'));
          }

          final dayIndex = plan.days.indexWhere(
            (d) =>
                shortPlanDay(d.dayOfWeek) ==
                (selectedDay ?? widget.initialDay ?? currentDayStr),
          );
          final day = dayIndex != -1 ? plan.days[dayIndex] : null;

          final totalKcal = day?.meals.fold(0, (sum, m) => sum + m.kcal) ?? 0;
          final eatenKcal =
              day?.meals
                  .where((m) => m.eaten)
                  .fold(0, (sum, m) => sum + m.kcal) ??
              0;
          final pct = totalKcal > 0 ? (eatenKcal / totalKcal) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullPlanDay(
                    selectedDay ?? widget.initialDay ?? currentDayStr,
                  ),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontFamily: 'AppSans',
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.focus,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPanel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: pct,
                              strokeWidth: 5,
                              backgroundColor: AppColors.primaryPanel,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          Text(
                            '${(pct * 100).round()}%',
                            style: const TextStyle(
                              fontFamily: 'AppSans',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DAILY TARGET',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$eatenKcal / $totalKcal kcal',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${day?.meals.where((m) => m.eaten).length ?? 0}/${day?.meals.length ?? 0} meals logged',
                              style: const TextStyle(
                                fontFamily: 'AppSans',
                                fontSize: 12,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Meal schedule',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontFamily: 'AppSans',
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Check-offs are saved on this device for this week.',
                ),
                const SizedBox(height: 12),
                if (plan.trainerNotes.isNotEmpty) Text(plan.trainerNotes),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final name in weekDays)
                      ChoiceChip(
                        label: Text(name.substring(0, 3)),
                        selected:
                            shortPlanDay(name) ==
                            (selectedDay ?? widget.initialDay ?? currentDayStr),
                        onSelected: logging
                            ? null
                            : (_) => setState(
                                () => selectedDay = shortPlanDay(name),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (day == null || day.meals.isEmpty)
                  const Text('No meals scheduled for this day.'),
                ...List.generate(day?.meals.length ?? 0, (index) {
                  final meal = day!.meals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => openMealDetails(context, meal),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPanel,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.subtleBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.redTint,
                                    AppColors.primaryRed,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                color: AppColors.darkTextOverRed,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: meal.eaten
                                          ? AppColors.mutedText
                                          : AppColors.primaryText,
                                      decoration: meal.eaten
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: AppColors.faintText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${meal.kcal} kcal · ${meal.protein}g protein · ${meal.time}',
                                    style: const TextStyle(
                                      fontFamily: 'AppSans',
                                      fontSize: 12,
                                      color: AppColors.faintText,
                                    ),
                                  ),
                                  for (final line
                                      in meal.source['items'] as List? ?? [])
                                    Text('$line'),
                                  if ('${meal.source['notes'] ?? ''}'
                                      .isNotEmpty)
                                    Text('${meal.source['notes']}'),
                                  Text(
                                    'Carbs ${meal.source['carbs'] ?? 0}g | Fat ${meal.source['fat'] ?? 0}g',
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: meal.eaten,
                              onChanged: logging
                                  ? null
                                  : (_) async {
                                      setState(() => logging = true);
                                      try {
                                        await ref
                                            .read(
                                              mealControllerProvider.notifier,
                                            )
                                            .toggleMealStatus(dayIndex, index);
                                      } catch (error) {
                                        if (context.mounted)
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text('$error')),
                                          );
                                      } finally {
                                        if (mounted)
                                          setState(() => logging = false);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
