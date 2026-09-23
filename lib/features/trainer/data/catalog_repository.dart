import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

typedef PlanRecord = Map<String, dynamic>;

Future<List<PlanRecord>> loadCatalog(String name) async =>
    List<PlanRecord>.from(
      jsonDecode(await rootBundle.loadString('assets/catalogs/$name.json'))
          as List,
    );

final exerciseCatalogProvider = FutureProvider<List<PlanRecord>>((ref) async {
  final rows = await ref
      .watch(supabaseProvider)
      .from('exercises')
      .select()
      .order('name');
  return rows.isEmpty ? loadCatalog('exercises') : List<PlanRecord>.from(rows);
});
final foodCatalogProvider = FutureProvider<List<PlanRecord>>(
  (ref) => loadCatalog('foods'),
);
final mealCatalogProvider = FutureProvider<List<PlanRecord>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('mealTemplates:${user?.id ?? "guest"}');
  return [
    if (stored != null) ...List<PlanRecord>.from(jsonDecode(stored) as List),
    ...await loadCatalog('meals'),
  ];
});

Future<void> saveCustomMeals(String userId, List<PlanRecord> meals) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = await prefs.setString(
    'mealTemplates:$userId',
    jsonEncode(meals.where((m) => m['custom'] == true).toList()),
  );
  if (!saved) throw StateError('Unable to save meal templates on this device.');
}

int _idSequence = 0;
String newPlanId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}';
PlanRecord copyRecord(PlanRecord value) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
num nutritionNumber(dynamic value) =>
    value is num ? value : num.tryParse('$value') ?? 0;
double roundNutrition(num value) => (value * 10).round() / 10;

PlanRecord foodPortion(PlanRecord food, num grams, {String? id}) => {
  'id': id ?? newPlanId('food'),
  'foodId': food['id'],
  'name': food['name'],
  'basis': food['basis'],
  'grams': grams,
  for (final key in [
    'calories',
    'protein',
    'carbs',
    'fat',
    'fiber',
    'sugar',
    'sodium',
  ])
    key: roundNutrition(nutritionNumber(food[key]) * grams / 100),
};

void calculateMealNutrition(PlanRecord meal) {
  final foods = List<PlanRecord>.from(meal['foods'] as List? ?? []);
  meal['items'] = [
    for (final food in foods)
      '${food['grams']}g ${food['name']} (${food['basis']})',
  ];
  for (final key in ['calories', 'protein', 'carbs', 'fat']) {
    meal[key] = roundNutrition(
      foods.fold<num>(0, (total, food) => total + nutritionNumber(food[key])),
    );
  }
}
