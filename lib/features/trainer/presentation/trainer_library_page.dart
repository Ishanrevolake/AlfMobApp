import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/catalog_repository.dart';
import '../data/trainer_repository.dart';
import 'plan_forms.dart';
import 'trainer_plan_editor.dart';

class TrainerLibraryPage extends ConsumerStatefulWidget {
  const TrainerLibraryPage({super.key});
  @override
  ConsumerState<TrainerLibraryPage> createState() => _TrainerLibraryPageState();
}

class _TrainerLibraryPageState extends ConsumerState<TrainerLibraryPage> {
  bool meals = false;
  String search = '', category = '';
  @override
  Widget build(BuildContext context) {
    final catalog = meals
        ? ref.watch(mealCatalogProvider)
        : ref.watch(exerciseCatalogProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text('Library', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Exercises')),
            ButtonSegment(value: true, label: Text('Meals')),
          ],
          selected: {meals},
          onSelectionChanged: (v) => setState(() {
            meals = v.first;
            category = '';
          }),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Search library',
          ),
          onChanged: (v) => setState(() => search = v.toLowerCase()),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _edit(null),
          icon: const Icon(Icons.add),
          label: Text(meals ? 'Create meal template' : 'Add exercise'),
        ),
        const SizedBox(height: 20),
        if (meals)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Custom templates are stored on this device. Assigned meals are shared with the web app.',
            ),
          ),
        catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Column(
            children: [
              Text('$e'),
              TextButton(
                onPressed: () {
                  if (meals) {
                    ref.invalidate(mealCatalogProvider);
                  } else {
                    ref.invalidate(exerciseCatalogProvider);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (rows) {
            final categories =
                rows.map((r) => '${r['category']}').toSet().toList()..sort();
            final visible = rows
                .where(
                  (r) =>
                      (category.isEmpty || r['category'] == category) &&
                      '${r['name']} ${r['category']} ${r['equipment'] ?? ''} ${r['items'] ?? ''}'
                          .toLowerCase()
                          .contains(search),
                )
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  key: ValueKey('$meals:$category'),
                  initialValue: categories.contains(category) ? category : '',
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All categories'),
                    ),
                    ...categories.map(
                      (v) => DropdownMenuItem(value: v, child: Text(v)),
                    ),
                  ],
                  onChanged: (v) => setState(() => category = v ?? ''),
                ),
                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No matching items'),
                  ),
                const SizedBox(height: 20),
                AlfResponsiveGrid(
                  minItemWidth: 320,
                  children: [
                    for (final row in visible)
                      _LibraryCard(
                        key: ValueKey(
                          '${meals ? 'meal' : 'exercise'}:${row['id']}',
                        ),
                        row: row,
                        meals: meals,
                        onAssign: () => _assign(row),
                        onEdit: !meals || row['custom'] == true
                            ? () => _edit(row)
                            : null,
                        onRemove: meals && row['custom'] == true
                            ? () => _remove(row)
                            : null,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _assign(PlanRecord row) async {
    final isMeal = meals;
    try {
      final clients = await ref.read(trainerRepositoryProvider).getClients();
      if (!mounted) return;
      final client = await pickCatalog(context, 'Choose client', [
        for (final c in clients)
          {'id': c.id, 'name': c.fullName, 'category': c.email},
      ]);
      if (client == null || !mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrainerPlanEditor(
            clientId: '${client['id']}',
            meals: isMeal,
            template: row,
          ),
        ),
      );
    } catch (e) {
      _error(e);
    }
  }

  Future<void> _edit(PlanRecord? row) async {
    final isMeal = meals;
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;
    final initial = isMeal
        ? <String, dynamic>{
            'id': row?['id'] ?? newPlanId('custom'),
            'name': row?['name'] ?? '',
            'category': row?['category'] ?? 'Custom',
            'itemsText': (row?['items'] as List? ?? []).join('\n'),
            'notes': row?['notes'] ?? '',
            'custom': true,
          }
        : <String, dynamic>{
            ...?row,
            'name': row?['name'] ?? '',
            'category': row?['category'] ?? 'Chest',
            'equipment': row?['equipment'] ?? '',
            'primary': row?['primary_muscles'] ?? row?['primary'] ?? '',
            'secondary': row?['secondary_muscles'] ?? row?['secondary'] ?? '',
            'level': row?['level'] ?? 'Intermediate',
          };
    await editPlanFields(
      context,
      isMeal ? 'Meal template' : 'Exercise',
      initial,
      isMeal
          ? const [
              PlanField('name', 'Name', required: true),
              PlanField('category', 'Category', required: true),
              PlanField(
                'itemsText',
                'Meal items (one per line)',
                required: true,
                lines: 5,
              ),
              PlanField('notes', 'Notes', lines: 3),
            ]
          : const [
              PlanField('name', 'Name', required: true),
              PlanField(
                'category',
                'Category',
                choices: [
                  'Chest',
                  'Back',
                  'Shoulders',
                  'Arms',
                  'Legs',
                  'Glutes',
                  'Core',
                  'Cardio',
                  'Mobility',
                ],
              ),
              PlanField('equipment', 'Equipment', required: true),
              PlanField('primary', 'Primary muscles'),
              PlanField('secondary', 'Secondary muscles'),
              PlanField(
                'level',
                'Level',
                choices: ['Beginner', 'Intermediate', 'Advanced'],
              ),
            ],
      save: (value) async {
        if (isMeal) {
          final rows = await ref.read(mealCatalogProvider.future);
          final template = {
            ...value,
            'items': '${value['itemsText']}'
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          }..remove('itemsText');
          await saveCustomMeals(userId, [
            template,
            ...rows.where((r) => r['id'] != template['id']),
          ]);
          ref.invalidate(mealCatalogProvider);
        } else {
          await ref.read(trainerRepositoryProvider).saveExercise({
            for (final key in [
              'id',
              'name',
              'category',
              'equipment',
              'primary',
              'secondary',
              'level',
            ])
              if (value[key] != null) key: value[key],
          }, editing: row != null);
          ref.invalidate(exerciseCatalogProvider);
        }
      },
    );
  }

  Future<void> _remove(PlanRecord row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${row['name']}?'),
        content: const Text(
          'Existing assigned meals will remain in client plans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final userId = ref.read(currentUserProvider)!.id;
      final rows = await ref.read(mealCatalogProvider.future);
      await saveCustomMeals(
        userId,
        rows.where((r) => r['id'] != row['id']).toList(),
      );
      ref.invalidate(mealCatalogProvider);
    } catch (e) {
      _error(e);
    }
  }

  void _error(Object e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

class _LibraryCard extends StatefulWidget {
  final PlanRecord row;
  final bool meals;
  final VoidCallback onAssign;
  final VoidCallback? onEdit, onRemove;
  const _LibraryCard({
    super.key,
    required this.row,
    required this.meals,
    required this.onAssign,
    this.onEdit,
    this.onRemove,
  });
  @override
  State<_LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<_LibraryCard> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final items = (row['items'] as List? ?? []).map((item) => '$item').toList();
    final theme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${row['name']}', style: theme.titleMedium),
            const SizedBox(height: 10),
            Text(
              [row['category'], if (!widget.meals) row['equipment']]
                  .where((value) => value != null && '$value'.trim().isNotEmpty)
                  .join(' · '),
              style: theme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (widget.meals) ...[
              Text(
                items.join('\n'),
                maxLines: expanded ? null : 3,
                overflow: expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: theme.bodyMedium?.copyWith(height: 1.5),
              ),
              if (items.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => expanded = !expanded),
                    child: Text(expanded ? 'Show less' : 'View meal details'),
                  ),
                ),
            ] else
              Text(
                '${row['primary_muscles'] ?? row['primary'] ?? ''} · ${row['level'] ?? 'Intermediate'}',
                style: theme.bodyMedium?.copyWith(height: 1.5),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: widget.onAssign,
                  child: const Text('Assign to client'),
                ),
                if (widget.onEdit != null)
                  TextButton(
                    onPressed: widget.onEdit,
                    child: const Text('Edit'),
                  ),
                if (widget.onRemove != null)
                  TextButton(
                    onPressed: widget.onRemove,
                    child: const Text('Remove'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
