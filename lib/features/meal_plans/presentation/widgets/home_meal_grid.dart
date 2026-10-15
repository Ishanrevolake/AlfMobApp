import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/meal_models.dart';
import 'meal_details.dart';

const homeMealCategories = [
  'Breakfast',
  'Lunch',
  'Dinner',
  'Snacks',
  'Pre-Workout',
  'Post-Workout',
];
String _category(String value) {
  final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  return normalized == 'snack' ? 'snacks' : normalized;
}

class HomeMealGrid extends StatefulWidget {
  final List<AssignedMeal> meals;
  final Future<void> Function(int)? onToggle;
  const HomeMealGrid({super.key, required this.meals, this.onToggle});
  @override
  State<HomeMealGrid> createState() => _HomeMealGridState();
}

class _HomeMealGridState extends State<HomeMealGrid> {
  bool saving = false;
  List<AssignedMeal> get meals => widget.meals;
  Future<void> Function(int)? get onToggle => widget.onToggle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 300 ? 2 : 3;
      final width = (constraints.maxWidth - 10 * (columns - 1)) / columns;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final category in homeMealCategories)
            SizedBox(width: width, child: _card(context, category)),
        ],
      );
    },
  );
  Widget _card(BuildContext context, String category) {
    final matches = meals
        .where((meal) => _category(meal.time) == _category(category))
        .toList();
    final eaten = matches.isNotEmpty && matches.every((meal) => meal.eaten);
    final kcal = matches.fold<int>(0, (sum, meal) => sum + meal.kcal);
    final protein = matches.fold<int>(0, (sum, meal) => sum + meal.protein);
    return Material(
      color: eaten ? AppColors.redTint : AppColors.primaryPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: eaten ? AppColors.redBorder : AppColors.subtleBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: matches.isEmpty
            ? null
            : () => openMealDetails(context, matches.first),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: eaten,
                      onChanged: saving || matches.isEmpty || onToggle == null
                          ? null
                          : (_) async {
                              if (saving) return;
                              setState(() => saving = true);
                              try {
                                for (final meal in matches) {
                                  if (meal.eaten == eaten) {
                                    await onToggle!(meals.indexOf(meal));
                                  }
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.primaryRed,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        duration: const Duration(seconds: 2),
                                        content: Text(
                                          eaten ? 'Unmarked' : 'Meal logged',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.darkTextOverRed,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    );
                                }
                              } catch (error) {
                                if (context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Unable to update meal: $error',
                                      ),
                                    ),
                                  );
                              } finally {
                                if (mounted) setState(() => saving = false);
                              }
                            },
                      activeColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final meal in matches)
                InkWell(
                  onTap: () => openMealDetails(context, meal),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      meal.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: meal.eaten
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              if (matches.isEmpty)
                const Text(
                  'Not scheduled',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                ),
              if (matches.isNotEmpty)
                Text(
                  '$kcal kcal \u00b7 ${protein}g protein',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
