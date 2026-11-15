import 'trainer_plan_editor.dart';
import 'trainer_daily_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/alf_widgets.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../client_profile/data/models/profile_models.dart';
import '../../meal_plans/data/models/meal_models.dart';
import '../../meal_plans/data/repositories/meal_repository.dart';
import '../../workouts/data/models/workout_models.dart';
import '../../workouts/data/repositories/workout_repository.dart';
import '../data/trainer_repository.dart';

class TrainerClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;
  final ClientProfile? client;
  const TrainerClientDetailScreen({
    super.key,
    required this.clientId,
    this.client,
  });

  @override
  ConsumerState<TrainerClientDetailScreen> createState() =>
      _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState
    extends ConsumerState<TrainerClientDetailScreen> {
  late Future<_ClientBundle> bundle;

  @override
  void initState() {
    super.initState();
    bundle = _load();
  }

  Future<_ClientBundle> _load() async {
    var client = widget.client;
    if (client == null) {
      final clients = await ref.read(trainerRepositoryProvider).getClients();
      client = clients.where((item) => item.id == widget.clientId).firstOrNull;
    }
    final values = await Future.wait([
      ref.read(workoutRepositoryProvider).getWorkoutPlan(widget.clientId),
      ref.read(mealRepositoryProvider).getMealPlan(widget.clientId),
      ref.read(trainerRepositoryProvider).getClientNotes(widget.clientId),
    ]);
    return _ClientBundle(
      client:
          client ??
          ClientProfile(
            id: widget.clientId,
            fullName: 'Client',
            email: '',
            role: 'client',
          ),
      workout: values[0] as WorkoutPlan?,
      meals: values[1] as ClientMealPlan?,
      notes: values[2] as List<Map<String, dynamic>>,
    );
  }

  void _refresh() {
    if (!mounted) return;
    final nextBundle = _load();
    setState(() {
      bundle = nextBundle;
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_ClientBundle>(
    future: bundle,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done &&
          !snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(),
          body: AlfAsyncError(error: snapshot.error!),
        );
      }
      final data = snapshot.requireData;
      return DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: Text(data.client.fullName.toUpperCase()),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'OVERVIEW'),
                Tab(text: 'WORKOUT'),
                Tab(text: 'MEALS'),
                Tab(text: 'NOTES'),
                Tab(text: 'ACTIVITY'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _overview(context, data),
              _workout(context, data),
              _meals(context, data),
              _notes(context, data),
              TrainerDailyLogs(clientId: widget.clientId, plan: data.meals),
            ],
          ),
        ),
      );
    },
  );

  Widget _overview(BuildContext context, _ClientBundle data) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      AlfPanel(
        child: Row(
          children: [
            AlfAvatar(initials: data.client.initials, size: 58),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.client.fullName,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.client.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (data.client.phone.isNotEmpty)
                    Text(
                      data.client.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            AlfStatusChip(
              data.client.status,
              positive: data.client.status == 'active',
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AlfResponsiveGrid(
        minItemWidth: 140,
        children: [
          AlfStatTile(
            value:
                '${data.workout?.days.fold<int>(0, (sum, day) => sum + day.exercises.length) ?? 0}',
            label: 'Exercises',
          ),
          AlfStatTile(
            value:
                '${data.meals?.days.fold<int>(0, (sum, day) => sum + day.meals.length) ?? 0}',
            label: 'Meals',
          ),
          AlfStatTile(value: '${data.notes.length}', label: 'Notes'),
        ],
      ),
      const SizedBox(height: 24),
      const AlfSectionHeader(title: 'Coaching summary'),
      AlfPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Detail(
              label: 'Goal',
              value: data.client.goal.isEmpty
                  ? 'Not provided'
                  : data.client.goal,
            ),
            _Detail(
              label: 'Workout focus',
              value: data.workout?.focus ?? 'Not assigned',
            ),
            _Detail(
              label: 'Nutrition focus',
              value: data.meals?.focus ?? 'Not assigned',
            ),
            _Detail(
              label: 'Package remaining',
              value: data.client.daysLeft > 0
                  ? '${data.client.daysLeft} days'
                  : 'Not available',
              last: true,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _workout(BuildContext context, _ClientBundle data) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          Expanded(
            child: AlfPageTitle(
              eyebrow: 'Assigned plan',
              title: data.workout?.focus ?? 'No workout plan',
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => _editWorkout(data.workout),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      const SizedBox(height: 20),
      if (data.workout == null || data.workout!.days.isEmpty)
        const AlfEmptyState(
          icon: Icons.fitness_center,
          title: 'No workout days',
          message: 'Create a plan and assign exercises from the library.',
        )
      else
        ...data.workout!.days.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AlfPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final day = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${day.dayOfWeek} · ${day.title}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              AlfStatusChip(
                                day.rest
                                    ? 'REST'
                                    : '${day.exercises.length} EXERCISES',
                                muted: day.rest,
                              ),
                              if (!day.rest)
                                IconButton(
                                  onPressed: () =>
                                      _addExercise(data.workout!, entry.key),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Session notes',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            day.trainerNotes.trim().isEmpty
                                ? 'No notes for this day yet.'
                                : day.trainerNotes,
                          ),
                          if (day.exercises.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...day.exercises.map(
                              (exercise) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: AppColors.primaryRed,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(child: Text(exercise.name)),
                                    Text(
                                      '${exercise.sets} × ${exercise.reps}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      if ((data.workout?.trainerNotes ?? '').isNotEmpty) ...[
        const SizedBox(height: 10),
        AlfPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRAINER NOTES',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Text(data.workout!.trainerNotes),
            ],
          ),
        ),
      ],
      const SizedBox(height: 14),
      OutlinedButton.icon(
        onPressed: () => _addWorkoutDay(data.workout),
        icon: const Icon(Icons.add),
        label: const Text('ADD WORKOUT DAY'),
      ),
    ],
  );

  Widget _meals(BuildContext context, _ClientBundle data) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          Expanded(
            child: AlfPageTitle(
              eyebrow: 'Assigned nutrition',
              title: data.meals?.focus ?? 'No meal plan',
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => _editMeals(data.meals),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      const SizedBox(height: 20),
      if (data.meals == null || data.meals!.days.isEmpty)
        const AlfEmptyState(
          icon: Icons.restaurant_menu,
          title: 'No meal days',
          message: 'Create a weekly plan with meals and food portions.',
        )
      else
        ...data.meals!.days.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AlfPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final day = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  day.dayOfWeek,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              AlfStatusChip(
                                '${day.meals.length} MEALS',
                                muted: day.meals.isEmpty,
                              ),
                              IconButton(
                                onPressed: () =>
                                    _addMeal(data.meals!, entry.key),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ],
                          ),
                          if (day.meals.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...day.meals.map(
                              (meal) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant,
                                      size: 15,
                                      color: AppColors.primaryRed,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(meal.name),
                                          Text(
                                            meal.time,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${meal.kcal} kcal',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      const SizedBox(height: 14),
      OutlinedButton.icon(
        onPressed: () => _addMealDay(data.meals),
        icon: const Icon(Icons.add),
        label: const Text('ADD MEAL DAY'),
      ),
    ],
  );

  Widget _notes(BuildContext context, _ClientBundle data) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          const Expanded(
            child: AlfPageTitle(
              eyebrow: 'Visible to client',
              title: 'Trainer notes',
            ),
          ),
          ElevatedButton.icon(
            onPressed: _addNote,
            icon: const Icon(Icons.add, size: 17),
            label: const Text('ADD'),
          ),
        ],
      ),
      const SizedBox(height: 20),
      if (data.notes.isEmpty)
        const AlfEmptyState(
          icon: Icons.notes,
          title: 'No notes yet',
          message: 'Add progress feedback or coaching guidance.',
        ),
      ...data.notes.map(
        (note) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AlfPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((note['body'] ?? '').toString()),
                const SizedBox(height: 9),
                Text(
                  _date(note['created_at']),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Future<void> _addNote() async {
    final controller = TextEditingController();
    final body = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          22,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ADD TRAINER NOTE',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              maxLines: 5,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Progress update, check-in notes or coaching advice…',
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('SAVE NOTE'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || body == null || body.isEmpty) return;
    try {
      await ref
          .read(trainerRepositoryProvider)
          .addClientNote(widget.clientId, body);
      _refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _openEditor(bool meals, [int day = 0]) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerPlanEditor(
          clientId: widget.clientId,
          meals: meals,
          initialDay: day,
        ),
      ),
    );
    if (mounted) _refresh();
  }

  Future<void> _editWorkout(WorkoutPlan? current) => _openEditor(false);
  Future<void> _editMeals(ClientMealPlan? current) => _openEditor(true);
  Future<void> _addWorkoutDay(WorkoutPlan? current) => _openEditor(false);
  Future<void> _addExercise(WorkoutPlan plan, int dayIndex) =>
      _openEditor(false, dayIndex);
  Future<void> _addMealDay(ClientMealPlan? current) => _openEditor(true);
  Future<void> _addMeal(ClientMealPlan plan, int dayIndex) =>
      _openEditor(true, dayIndex);

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null
        ? ''
        : DateFormat('MMM d, yyyy · h:mm a').format(date.toLocal());
  }
}

class _ClientBundle {
  final ClientProfile client;
  final WorkoutPlan? workout;
  final ClientMealPlan? meals;
  final List<Map<String, dynamic>> notes;
  const _ClientBundle({
    required this.client,
    required this.workout,
    required this.meals,
    required this.notes,
  });
}

class _Detail extends StatelessWidget {
  final String label, value;
  final bool last;
  const _Detail({required this.label, required this.value, this.last = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: AppColors.subtleBorder)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
