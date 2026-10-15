import 'package:flutter/material.dart';
import '../../data/models/meal_models.dart';

void openMealDetails(BuildContext context, AssignedMeal meal) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => MealDetailsScreen(meal: meal)),
  );
}

class MealDetailsScreen extends StatelessWidget {
  final AssignedMeal meal;
  const MealDetailsScreen({super.key, required this.meal});
  List<String> _lines(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.expand(_lines).toList();
    if (value is Map) {
      final name = value['name'] ?? value['food'] ?? value['ingredient'] ?? '';
      final amount = value['quantity'] ?? value['amount'] ?? '';
      return ['$amount $name'.trim()].where((line) => line.isNotEmpty).toList();
    }
    return '$value'
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = _lines(
      meal.source['ingredients'] ??
          meal.source['items'] ??
          meal.source['foods'],
    );
    final instructions = _lines(
      meal.source['instructions'] ??
          meal.source['preparation'] ??
          meal.source['recipe'] ??
          meal.source['notes'],
    );
    return Scaffold(
      appBar: AppBar(title: Text(meal.time.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(meal.name, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text('${meal.kcal} kcal \u00b7 ${meal.protein}g protein'),
          const SizedBox(height: 24),
          Text('Ingredients', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 12),
          if (ingredients.isEmpty) const Text('No ingredients provided yet.'),
          for (final line in ingredients)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(line),
            ),
          const SizedBox(height: 24),
          Text('Instructions', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 12),
          if (instructions.isEmpty) const Text('No instructions provided yet.'),
          for (final line in instructions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(line),
            ),
        ],
      ),
    );
  }
}
