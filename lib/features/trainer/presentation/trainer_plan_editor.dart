import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/plan_days.dart';
import '../../meal_plans/data/models/meal_models.dart';
import '../../meal_plans/data/repositories/meal_repository.dart';
import '../../workouts/data/models/workout_models.dart';
import '../../workouts/data/repositories/workout_repository.dart';
import '../../workouts/presentation/controllers/workout_controller.dart';
import '../../meal_plans/presentation/controllers/meal_controller.dart';
import '../data/catalog_repository.dart';
import 'plan_forms.dart';

class TrainerPlanEditor extends ConsumerStatefulWidget {
  final String clientId;
  final bool meals;
  final int initialDay;
  final PlanRecord? template;
  const TrainerPlanEditor({
    super.key,
    required this.clientId,
    required this.meals,
    this.initialDay = 0,
    this.template,
  });
  @override
  ConsumerState<TrainerPlanEditor> createState() => _TrainerPlanEditorState();
}

class _TrainerPlanEditorState extends ConsumerState<TrainerPlanEditor> {
  PlanRecord? plan;
  String? error;
  bool saving = false, dirty = false;
  bool templateAssigned = false;
  late int selected = widget.initialDay;
  List<PlanRecord> get days => List<PlanRecord>.from(plan!['days'] as List);
  String get collection => widget.meals ? 'meals' : 'exercises';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      PlanRecord? data;
      if (widget.meals) {
        final existing = await ref
            .read(mealRepositoryProvider)
            .getMealPlan(widget.clientId);
        if (existing != null) data = MealRepository.toDatabase(existing);
      } else {
        final existing = await ref
            .read(workoutRepositoryProvider)
            .getWorkoutPlan(widget.clientId);
        if (existing != null) data = WorkoutRepository.toDatabase(existing);
      }
      final value = copyRecord(
        data ??
            {
              'client_id': widget.clientId,
              'focus': widget.meals
                  ? 'Custom nutrition plan'
                  : 'Custom workout plan',
              'start_date':
                  (widget.meals
                          ? DateTime.now()
                          : nextPlanMonday(DateTime.now()))
                      .toIso8601String()
                      .split('T')
                      .first,
              'trainer_notes': '',
              'assigned_program_id': 'custom-workout-plan',
              'days': <PlanRecord>[],
            },
      );
      final existingDays = List<PlanRecord>.from(value['days'] as List);
      if (widget.meals) {
        // Repair abbreviated and legacy days while merging duplicate weekdays.
        value['days'] = [
          for (final day in weekDays)
            {
              ...?existingDays
                  .where((d) => fullPlanDay('${d['day']}') == day)
                  .firstOrNull,
              'id':
                  existingDays
                      .where((d) => fullPlanDay('${d['day']}') == day)
                      .firstOrNull?['id'] ??
                  'meal-${day.toLowerCase()}',
              'day': day,
              'meals': [
                for (final d in existingDays.where(
                  (d) => fullPlanDay('${d['day']}') == day,
                ))
                  ...d['meals'] as List,
              ],
            },
          ...existingDays.where(
            (d) => !weekDays.contains(fullPlanDay('${d['day']}')),
          ),
        ];
      } else if (existingDays.isEmpty) {
        final schedule = List<String>.from(
          value['weekly_schedule'] as List? ?? [],
        );
        value['days'] = [
          for (final row in schedule)
            {
              'id': newPlanId('day'),
              'day': row.split(' - ').first,
              'title': row.split(' - ').skip(1).join(' - '),
              'exercises': <PlanRecord>[],
            },
        ];
      }
      if (!mounted) return;
      setState(() {
        plan = value;
        error = null;
        selected = selected.clamp(0, days.isEmpty ? 0 : days.length - 1);
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  void change(VoidCallback update) => setState(() {
    update();
    dirty = true;
  });
  void showError(Object e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !dirty && !saving,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || saving) return;
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard unsaved changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard == true && mounted) {
        setState(() => dirty = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.meals ? 'Meal plan' : 'Workout plan'),
        actions: [
          TextButton(
            onPressed: plan == null || saving ? null : _save,
            child: Text(saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
      body: plan == null
          ? Center(
              child: error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
          : AbsorbPointer(
              absorbing: saving,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${plan!['focus']}'),
                    subtitle: Text(
                      'Starts ${plan!['start_date']}\n${plan!['trainer_notes']}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: _editDetails,
                  ),
                  if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (widget.template != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Choose a day, then add ${widget.template!['name']}.',
                      ),
                    ),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (var i = 0; i < days.length; i++)
                        ChoiceChip(
                          label: Text('${days[i]['day']}'),
                          selected: i == selected,
                          onSelected: (_) => setState(() => selected = i),
                        ),
                    ],
                  ),
                  if (!widget.meals)
                    TextButton.icon(
                      onPressed: _addDay,
                      icon: const Icon(Icons.add),
                      label: const Text('Add workout day'),
                    ),
                  if (days.isNotEmpty) ...[
                    if (!widget.meals)
                      ListTile(
                        title: Text('${days[selected]['title']}'),
                        subtitle: Text(
                          days[selected]['rest'] == true
                              ? 'Rest day'
                              : 'Training day',
                        ),
                        onTap: _editDay,
                        trailing: IconButton(
                          tooltip: 'Remove day',
                          onPressed: () => _removeDay(),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    if (!widget.meals)
                      Card(
                        child: ListTile(
                          title: const Text('Notes for this day'),
                          subtitle: Text(
                            '${days[selected]['notes'] ?? days[selected]['trainer_notes'] ?? ''}'
                                    .trim()
                                    .isEmpty
                                ? 'Add guidance visible to the client for this workout day.'
                                : '${days[selected]['notes'] ?? days[selected]['trainer_notes']}',
                          ),
                          trailing: const Icon(Icons.edit_note),
                          onTap: _editDayNotes,
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _addItem(),
                          icon: const Icon(Icons.add),
                          label: Text(
                            widget.meals ? 'Add meal' : 'Add exercise',
                          ),
                        ),
                        if (widget.meals)
                          TextButton(
                            onPressed: () => _addItem(fromTemplate: true),
                            child: const Text('Use meal template'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final item in List<PlanRecord>.from(
                      days[selected][collection] as List? ?? [],
                    ))
                      _item(item),
                    if ((days[selected][collection] as List).isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nothing assigned to this day yet.'),
                      ),
                  ],
                ],
              ),
            ),
    ),
  );

  Widget _item(PlanRecord item) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${item['name']}'),
            subtitle: Text(
              widget.meals
                  ? '${item['mealTime']} · ${item['calories'] ?? 0} kcal · P ${item['protein'] ?? 0}g · C ${item['carbs'] ?? 0}g · F ${item['fat'] ?? 0}g'
                  : '${item['sets']} × ${item['reps']} · Rest ${item['rest'] ?? ''} · Tempo ${item['tempo'] ?? ''}',
            ),
            onTap: () => _editItem(item),
            trailing: IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => change(
                () => (days[selected][collection] as List).remove(item),
              ),
            ),
          ),
          if ('${item['notes'] ?? ''}'.isNotEmpty) Text('${item['notes']}'),
          if (widget.meals) ...[
            for (final line in item['items'] as List? ?? []) Text('$line'),
            for (final food in List<PlanRecord>.from(
              item['foods'] as List? ?? [],
            ))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${food['name']} (${food['basis']})'),
                subtitle: Text('${food['grams']}g · ${food['calories']} kcal'),
                onTap: () => _food(item, food),
                trailing: IconButton(
                  tooltip: 'Remove food',
                  icon: const Icon(Icons.close),
                  onPressed: () => change(() {
                    (item['foods'] as List).remove(food);
                    calculateMealNutrition(item);
                  }),
                ),
              ),
            TextButton.icon(
              onPressed: () => _food(item, null),
              icon: const Icon(Icons.add),
              label: const Text('Add food portion'),
            ),
          ],
        ],
      ),
    ),
  );

  Future<void> _editDetails() async {
    final values = await editPlanFields(context, 'Plan details', plan!, const [
      PlanField('focus', 'Focus', required: true),
      PlanField('trainer_notes', 'Trainer notes', lines: 3),
    ]);
    if (values != null && mounted) {
      change(() {
        plan!['focus'] = values['focus'];
        plan!['trainer_notes'] = values['trainer_notes'];
      });
    }
    if (values == null || !mounted) return;
    final currentStart =
        DateTime.tryParse('${plan!['start_date']}') ?? DateTime.now();
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);
    final boundedStart = currentStart.isBefore(firstDate)
        ? firstDate
        : currentStart.isAfter(lastDate)
        ? lastDate
        : currentStart;
    var initialDate = widget.meals
        ? boundedStart
        : nextPlanMonday(boundedStart);
    if (initialDate.isAfter(lastDate)) {
      initialDate = initialDate.subtract(const Duration(days: 7));
    }
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: widget.meals ? null : 'Choose a Monday to start the plan',
      selectableDayPredicate: widget.meals
          ? null
          : (date) => date.weekday == DateTime.monday,
    );
    if (date != null && mounted) {
      change(
        () => plan!['start_date'] = date.toIso8601String().split('T').first,
      );
    }
  }

  Future<void> _addDay() async {
    final value = await editPlanFields(
      context,
      'Workout day',
      {'day': weekDays[days.length % 7], 'title': 'Training session'},
      const [
        PlanField('day', 'Day', required: true),
        PlanField('title', 'Session title', required: true),
      ],
    );
    if (value != null && mounted) {
      change(() {
        (plan!['days'] as List).add({
          ...value,
          'id': newPlanId('day'),
          'exercises': <PlanRecord>[],
        });
        selected = days.length - 1;
      });
    }
  }

  Future<void> _editDay() async {
    final day = days[selected];
    final value = await editPlanFields(
      context,
      'Workout day',
      {...day, 'type': day['rest'] == true ? 'Rest' : 'Training'},
      const [
        PlanField('day', 'Day', required: true),
        PlanField('title', 'Session title', required: true),
        PlanField('type', 'Type', choices: ['Training', 'Rest']),
      ],
    );
    if (value != null && mounted) {
      change(() {
        day['day'] = fullPlanDay('${value['day']}');
        day['title'] = value['title'];
        day['rest'] = value['type'] == 'Rest';
      });
    }
  }

  Future<void> _editDayNotes() async {
    final day = days[selected];
    final values = await editPlanFields(
      context,
      '${day['day']} - Notes',
      {'notes': day['notes'] ?? day['trainer_notes'] ?? ''},
      const [PlanField('notes', 'Trainer notes for this day', lines: 5)],
    );
    if (values != null && mounted) {
      change(() => day['notes'] = '${values['notes'] ?? ''}'.trim());
    }
  }

  void _removeDay() => change(() {
    (plan!['days'] as List).removeAt(selected);
    selected = selected.clamp(0, days.isEmpty ? 0 : days.length - 1);
  });

  List<PlanField> get itemFields => widget.meals
      ? const [
          PlanField('name', 'Meal name', required: true),
          PlanField('mealTime', 'Meal time', required: true),
          PlanField('notes', 'Notes', lines: 3),
        ]
      : const [
          PlanField('name', 'Exercise name', required: true),
          PlanField('sets', 'Sets', required: true),
          PlanField('reps', 'Reps', required: true),
          PlanField('rest', 'Rest (e.g. 60 sec)'),
          PlanField('tempo', 'Tempo'),
          PlanField('notes', 'Coaching notes', lines: 3),
        ];

  Future<void> _addItem({bool fromTemplate = false}) async {
    try {
      PlanRecord? template = widget.template;
      if (template == null && (!widget.meals || fromTemplate)) {
        final rows = widget.meals
            ? await ref.read(mealCatalogProvider.future)
            : await ref.read(exerciseCatalogProvider.future);
        if (!mounted) return;
        template = await pickCatalog(
          context,
          widget.meals ? 'Choose meal' : 'Choose exercise',
          rows,
        );
        if (template == null) return;
      }
      if (!mounted) return;
      final initial = widget.meals
          ? <String, dynamic>{
              'id': newPlanId('meal'),
              'mealId': template?['id'] ?? 'custom-meal',
              'name': template?['name'] ?? '',
              'mealTime': 'Breakfast',
              'items': template?['items'] ?? <String>[],
              'foods': <PlanRecord>[],
              'notes': template?['notes'] ?? '',
              'calories': 0,
              'protein': 0,
              'carbs': 0,
              'fat': 0,
            }
          : <String, dynamic>{
              'id': newPlanId('exercise'),
              'exerciseId': template!['id'],
              'name': template['name'],
              'sets': '3',
              'reps': '10',
              'rest': '60 sec',
              'tempo': '',
              'notes': '',
            };
      final result = await editPlanFields(
        context,
        widget.meals ? 'Add meal' : 'Add exercise',
        {...initial, 'target': '${days[selected]['day']}'},
        [
          ...itemFields,
          if (widget.meals)
            PlanField(
              'target',
              'Assign to',
              choices: [...days.map((d) => '${d['day']}'), 'Every day'],
            ),
        ],
        save: widget.meals
            ? null
            : (result) async {
                final candidate = copyRecord(plan!);
                final day = (candidate['days'] as List)[selected] as Map;
                final item = copyRecord(result)..remove('target');
                (day['exercises'] as List).add(item);
                day['rest'] = false;
                await _persistPlan(candidate);
                if (!mounted) return;
                setState(() {
                  plan = candidate;
                  dirty = false;
                  templateAssigned = true;
                });
              },
      );
      if (result != null && mounted && !widget.meals) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise saved to the client\'s plan.'),
          ),
        );
      }
      if (result != null && mounted && widget.meals) {
        change(() {
          templateAssigned = true;
          for (final day in days) {
            if (widget.meals
                ? result['target'] == 'Every day' ||
                      result['target'] == day['day']
                : identical(day, days[selected])) {
              final item = copyRecord(result)..remove('target');
              item['id'] = newPlanId(widget.meals ? 'meal' : 'exercise');
              (day[collection] as List).add(item);
              if (!widget.meals) day['rest'] = false;
            }
          }
        });
      }
    } catch (e) {
      showError(e);
    }
  }

  Future<void> _editItem(PlanRecord item) async {
    final hasFoods = (item['foods'] as List? ?? []).isNotEmpty;
    final values = await editPlanFields(
      context,
      'Edit ${widget.meals ? 'meal' : 'exercise'}',
      {...item, 'itemsText': (item['items'] as List? ?? []).join('\n')},
      [
        ...itemFields,
        if (widget.meals && !hasFoods) ...[
          const PlanField('itemsText', 'Meal items (one per line)', lines: 4),
          for (final key in ['calories', 'protein', 'carbs', 'fat'])
            PlanField(key, key, number: true),
        ],
      ],
    );
    if (values != null && mounted) {
      change(() {
        item.addAll(values);
        if (widget.meals && !hasFoods) {
          item['items'] = '${values['itemsText']}'
              .split('\n')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        item.remove('itemsText');
      });
    }
  }

  Future<void> _food(PlanRecord meal, PlanRecord? existing) async {
    try {
      final foods = await ref.read(foodCatalogProvider.future);
      if (!mounted) return;
      final food = existing == null
          ? await pickCatalog(context, 'Choose food', foods)
          : foods.where((f) => f['id'] == existing['foodId']).firstOrNull;
      if (food == null) {
        if (existing != null) {
          showError(
            'This food is no longer in the catalog. Remove it and choose a replacement.',
          );
        }
        return;
      }
      if (!mounted) return;
      final values = await editPlanFields(
        context,
        '${food['name']} (${food['basis']})',
        {'grams': existing?['grams'] ?? 100},
        const [PlanField('grams', 'Portion (g / ml)', number: true)],
      );
      if (values != null && mounted) {
        change(() {
          final portion = foodPortion(
            food,
            values['grams'] as num,
            id: existing?['id'] as String?,
          );
          final rows = meal['foods'] as List? ?? <PlanRecord>[];
          meal['foods'] = rows;
          if (existing == null) {
            rows.add(portion);
          } else {
            rows[rows.indexOf(existing)] = portion;
          }
          calculateMealNutrition(meal);
        });
      }
    } catch (e) {
      showError(e);
    }
  }

  Future<void> _save() async {
    if (widget.template != null && !templateAssigned) {
      showError(
        'Choose a day and add the selected ${widget.meals ? 'meal' : 'exercise'} before saving.',
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await _persistPlan(plan!);
      if (!mounted) return;
      setState(() {
        dirty = false;
        saving = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          saving = false;
          error = '$e';
        });
      }
    }
  }

  Future<void> _persistPlan(PlanRecord value) async {
    if (widget.meals) {
      await ref
          .read(mealRepositoryProvider)
          .updateMealPlan(
            ClientMealPlan.fromJson(MealRepository.normalizePlan(value)),
          );
      if (mounted) ref.invalidate(mealControllerProvider);
    } else {
      final workoutDays = List<PlanRecord>.from(value['days'] as List);
      value['weekly_schedule'] = [
        for (final day in workoutDays)
          '${fullPlanDay('${day['day']}')} - ${day['title']}',
      ];
      for (final day in workoutDays) {
        day['meta'] = '${(day['exercises'] as List).length} exercises';
      }
      await ref
          .read(workoutRepositoryProvider)
          .updateWorkoutPlan(
            WorkoutPlan.fromJson(WorkoutRepository.normalizePlan(value)),
          );
      if (mounted) ref.invalidate(workoutControllerProvider);
    }
  }
}
