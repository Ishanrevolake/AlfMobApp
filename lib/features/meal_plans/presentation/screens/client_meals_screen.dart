import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/plan_days.dart';
import '../../../progress/data/daily_log_repository.dart';
import '../../data/models/meal_models.dart';
import '../controllers/meal_controller.dart';
import '../widgets/meal_details.dart';

class ClientMealsScreen extends ConsumerStatefulWidget {
  final String? initialDay;
  const ClientMealsScreen({super.key, this.initialDay});
  @override
  ConsumerState<ClientMealsScreen> createState() => _ClientMealsScreenState();
}

class _ClientMealsScreenState extends ConsumerState<ClientMealsScreen> {
  late DateTime date;
  Map<String, Map<String, dynamic>> logs = {};
  bool busy = false;
  String? error;
  int request = 0;
  String? loadedClient;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    date = DateTime(now.year, now.month, now.day);
    if (widget.initialDay != null) {
      final index = weekDays.indexWhere(
        (d) => shortPlanDay(d) == shortPlanDay(widget.initialDay!),
      );
      if (index >= 0) date = date.add(Duration(days: index + 1 - date.weekday));
    }
  }

  Future<void> load(String clientId) async {
    final token = ++request;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await ref
          .read(dailyLogRepositoryProvider)
          .read(clientId, date, 'meal');
      if (mounted && token == request) setState(() => logs = result);
    } catch (_) {
      if (mounted && token == request) {
        setState(() {
          logs = {};
          error = 'Unable to load meal logs. Please retry.';
        });
      }
    } finally {
      if (mounted && token == request) setState(() => busy = false);
    }
  }

  Future<void> save(
    String clientId,
    String id,
    Map<String, dynamic> value,
  ) async {
    setState(() => busy = true);
    try {
      await ref
          .read(dailyLogRepositoryProvider)
          .save(clientId, date, 'meal', id, value);
      if (mounted) {
        setState(() => logs[id] = value);
        ref.invalidate(mealControllerProvider);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save meal. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void select(DateTime value, String id) {
    setState(() {
      date = value;
      logs = {};
    });
    load(id);
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(mealControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEALS'),
        actions: [
          IconButton(
            tooltip: 'Grocery list',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              final value = plan.value;
              if (value != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => GroceryListScreen(plan: value),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (value) {
          if (value == null) {
            return const Center(child: Text('No meal plan assigned.'));
          }
          if (loadedClient != value.clientId) {
            loadedClient = value.clientId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) load(value.clientId);
            });
          }
          final monday = date.subtract(Duration(days: date.weekday - 1));
          final day = value.days
              .where(
                (d) =>
                    shortPlanDay(d.dayOfWeek) ==
                    shortPlanDay(weekDays[date.weekday - 1]),
              )
              .firstOrNull;
          final active = !date.isBefore(
            DateTime(
              value.startDate.year,
              value.startDate.month,
              value.startDate.day,
            ),
          );
          final meals = active
              ? (day?.meals ?? <AssignedMeal>[])
              : <AssignedMeal>[];
          final planned = meals.fold(0, (s, m) => s + m.kcal);
          final extras = logs.entries
              .where(
                (e) => e.value['extra'] == true && e.value['deleted'] != true,
              )
              .toList();
          final eaten = meals
              .where(
                (m) =>
                    logs['${logDate(value.startDate)}:${day?.dayOfWeek}:${m.source['id'] ?? m.id}']?['eaten'] ==
                    true,
              )
              .toList();
          final kcal =
              eaten.fold(0, (s, m) => s + m.kcal) +
              extras.fold(0, (s, e) => s + (e.value['kcal'] as num).toInt());
          final protein =
              eaten.fold(0, (s, m) => s + m.protein) +
              extras.fold(
                0,
                (s, e) => s + (e.value['protein'] as num? ?? 0).toInt(),
              );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: busy
                        ? null
                        : () => select(
                            date.subtract(const Duration(days: 7)),
                            value.clientId,
                          ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: busy
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null && mounted) {
                                select(picked, value.clientId);
                              }
                            },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat('MMM yyyy').format(date)),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next week',
                    onPressed: busy
                        ? null
                        : () => select(
                            date.add(const Duration(days: 7)),
                            value.clientId,
                          ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Row(
                children: List.generate(7, (i) {
                  final d = monday.add(Duration(days: i));
                  final today = logDate(d) == logDate(DateTime.now());
                  final selected = logDate(d) == logDate(date);
                  return Expanded(
                    child: Semantics(
                      selected: selected,
                      button: true,
                      label: DateFormat('EEEE, d MMMM yyyy').format(d),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: busy ? null : () => select(d, value.clientId),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryRed
                                  : AppColors.primaryPanel,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: today
                                    ? AppColors.primaryRed
                                    : AppColors.subtleBorder,
                                width: today ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  weekDays[i].substring(0, 3),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${d.day}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      Text('$planned\nKcal planned'),
                      Text('$kcal\nKcal eaten'),
                      Text('${protein}g\nProtein eaten'),
                    ],
                  ),
                ),
              ),
              if (busy) const LinearProgressIndicator(),
              if (error != null) ...[
                Text(error!),
                TextButton(
                  onPressed: () => load(value.clientId),
                  child: const Text('Retry'),
                ),
              ],
              if (!active) const Text('Your meal plan has not started yet.'),
              if (active && meals.isEmpty)
                const Text('No meals scheduled for this day.'),
              if (value.trainerNotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(value.trainerNotes),
                ),
              ...meals.map((m) {
                final id =
                    '${logDate(value.startDate)}:${day!.dayOfWeek}:${m.source['id'] ?? m.id}';
                return Card(
                  child: ListTile(
                    onTap: () => openMealDetails(context, m),
                    leading: const Icon(
                      Icons.restaurant,
                      color: AppColors.primaryRed,
                    ),
                    title: Text(m.name),
                    subtitle: Text(
                      '${m.time}\n${m.kcal} kcal • ${m.protein}g protein',
                    ),
                    trailing: Checkbox(
                      value: logs[id]?['eaten'] == true,
                      onChanged: busy || error != null
                          ? null
                          : (checked) => save(value.clientId, id, {
                              'eaten': checked,
                              'name': m.name,
                              'kcal': m.kcal,
                              'protein': m.protein,
                              'planned': true,
                            }),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text(
                'Extra meals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text('Add anything else you ate so your coach can see it.'),
              ...extras.map(
                (e) => ListTile(
                  title: Text('${e.value['name']}'),
                  subtitle: Text(
                    '${e.value['kcal']} kcal • ${e.value['protein'] ?? 0}g protein',
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove extra meal',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: busy
                        ? null
                        : () => save(value.clientId, e.key, {
                            ...e.value,
                            'deleted': true,
                          }),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: busy || error != null
                    ? null
                    : () => addExtra(value.clientId),
                icon: const Icon(Icons.add),
                label: const Text('Add extra meal'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> addExtra(String clientId) async {
    final form = GlobalKey<FormState>();
    final name = TextEditingController(),
        kcal = TextEditingController(),
        protein = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extra meal'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'What did you eat?',
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Enter a meal' : null,
                ),
                TextFormField(
                  controller: kcal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal)',
                  ),
                  validator: (v) =>
                      int.tryParse(v ?? '') == null || int.parse(v!) < 0
                      ? 'Enter calories, 0 or more'
                      : null,
                ),
                TextFormField(
                  controller: protein,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g, optional)',
                  ),
                  validator: (v) =>
                      v!.isNotEmpty &&
                          (int.tryParse(v) == null || int.parse(v) < 0)
                      ? 'Enter grams, 0 or more'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await save(clientId, 'extra:${DateTime.now().microsecondsSinceEpoch}', {
        'extra': true,
        'eaten': true,
        'name': name.text.trim(),
        'kcal': int.parse(kcal.text),
        'protein': int.tryParse(protein.text) ?? 0,
      });
    }
    // Dialog route finishes its closing animation before controllers are released.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    kcal.dispose();
    protein.dispose();
  }
}

class GroceryListScreen extends StatelessWidget {
  final ClientMealPlan plan;
  const GroceryListScreen({super.key, required this.plan});
  @override
  Widget build(BuildContext context) {
    final items = <String, int>{};
    void add(String line) {
      final text = line.trim();
      if (text.isNotEmpty) items.update(text, (n) => n + 1, ifAbsent: () => 1);
    }

    void collect(dynamic value) {
      if (value is List) {
        for (final v in value) {
          collect(v);
        }
      } else if (value is Map) {
        final name = value['name'] ?? value['food'] ?? value['ingredient'];
        if (name != null) {
          add('${value['quantity'] ?? value['amount'] ?? ''} $name'.trim());
        }
      } else if (value != null) {
        for (final line in '$value'.split('\n')) {
          add(line);
        }
      }
    }

    for (final day in plan.days) {
      for (final meal in day.meals) {
        collect(
          meal.source['ingredients'] ??
              meal.source['items'] ??
              meal.source['foods'],
        );
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Grocery list')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Ingredients from your weekly meal plan. Quantities are shown as supplied by your coach.',
          ),
          const SizedBox(height: 16),
          if (items.isEmpty) const Text('No ingredients provided yet.'),
          for (final item in items.entries)
            ListTile(
              leading: const Icon(Icons.shopping_basket_outlined),
              title: Text(item.key),
              subtitle: item.value > 1
                  ? Text('Needed for ${item.value} meals')
                  : null,
            ),
        ],
      ),
    );
  }
}
