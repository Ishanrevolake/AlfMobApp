import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/alf_widgets.dart';
import '../data/program_packages.dart';
import '../data/trainer_repository.dart';

final trainerPackagesProvider =
    FutureProvider.autoDispose<List<ManagedPackage>>(
      (ref) => ref.watch(trainerRepositoryProvider).getPackages(),
    );

class TrainerProgramsPage extends ConsumerStatefulWidget {
  const TrainerProgramsPage({super.key});
  @override
  ConsumerState<TrainerProgramsPage> createState() =>
      _TrainerProgramsPageState();
}

class _TrainerProgramsPageState extends ConsumerState<TrainerProgramsPage> {
  String search = '';
  bool busy = false;

  void notify(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> edit([ManagedPackage? item]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PackageEditor(package: item),
    );
    if (!mounted || saved != true) return;
    ref.invalidate(trainerPackagesProvider);
    notify(item == null ? 'Package added.' : 'Package updated.');
  }

  Future<void> remove(ManagedPackage item) async {
    if (item.clientCount > 0) {
      notify(assignedPackageMessage);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove package?'),
        content: Text('Remove "${item.name}"? This cannot be undone.'),
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
    if (!mounted || confirmed != true) return;
    setState(() => busy = true);
    try {
      await ref.read(trainerRepositoryProvider).deletePackage(item.id);
      if (!mounted) return;
      ref.invalidate(trainerPackagesProvider);
      notify('Package removed.');
    } catch (error) {
      if (mounted) {
        notify(
          error is PackageOperationException
              ? error.message
              : 'Unable to remove package. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = ref.watch(trainerPackagesProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trainerPackagesProvider);
        try {
          await ref.read(trainerPackagesProvider.future);
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          const AlfPageTitle(
            eyebrow: 'Programmes',
            title: 'Packages',
            subtitle: 'Manage packages and view client assignments.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: busy ? null : () => edit(),
            icon: const Icon(Icons.add),
            label: const Text('Add package'),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search packages...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                setState(() => search = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 20),
          if (busy) const LinearProgressIndicator(),
          packages.when(
            data: (items) {
              final filtered = items
                  .where((item) => item.name.toLowerCase().contains(search))
                  .toList();
              if (filtered.isEmpty) {
                return AlfEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: items.isEmpty
                      ? 'No packages yet'
                      : 'No packages found',
                  message: items.isEmpty
                      ? 'Add your first package to get started.'
                      : 'Try a different package name.',
                );
              }
              return Column(
                children: [
                  for (final item in filtered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AlfPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${item.clientCount} ${item.clientCount == 1 ? 'client' : 'clients'}',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Duration: ${item.duration}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'LKR ${NumberFormat.decimalPattern().format(item.price)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (!item.active) const Text('Inactive'),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                item.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: busy ? null : () => edit(item),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  onPressed: busy ? null : () => remove(item),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remove'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Column(
              children: [
                AlfAsyncError(error: error),
                TextButton(
                  onPressed: () => ref.invalidate(trainerPackagesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageEditor extends ConsumerStatefulWidget {
  final ManagedPackage? package;
  const _PackageEditor({this.package});
  @override
  ConsumerState<_PackageEditor> createState() => _PackageEditorState();
}

class _PackageEditorState extends ConsumerState<_PackageEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.package?.name ?? '');
  late final duration = TextEditingController(
    text: widget.package?.duration ?? '',
  );
  late final price = TextEditingController(
    text: widget.package?.price.toString() ?? '',
  );
  late final description = TextEditingController(
    text: widget.package?.description ?? '',
  );
  late String category = widget.package?.category ?? 'Bundles';
  bool saving = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    duration.dispose();
    price.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await ref
          .read(trainerRepositoryProvider)
          .savePackage(
            id: widget.package?.id,
            name: name.text,
            duration: duration.text,
            price: int.parse(price.text.trim()),
            description: description.text,
            category: category,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (exception) {
      if (mounted) {
        setState(() {
          saving = false;
          error = exception is PackageOperationException
              ? exception.message
              : 'Unable to save package. Check your connection and trainer access, then try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: Text(widget.package == null ? 'Add package' : 'Edit package'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (error != null) ...[
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: name,
                  enabled: !saving,
                  decoration: const InputDecoration(labelText: 'Package name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a package name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: duration,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'e.g. 30 Days, 3 Months or One Time',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a duration'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: price,
                  enabled: !saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (LKR)'),
                  validator: (value) {
                    final amount = int.tryParse(value?.trim() ?? '');
                    return amount == null || amount < 0 || amount > 2147483647
                        ? 'Enter a valid whole-rupee price'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: {'Annual', 'Bundles', 'Monthly', 'One-Off', category}
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: saving
                      ? null
                      : (value) => setState(() => category = value!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: description,
                  enabled: !saving,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : save,
          child: Text(saving ? 'Saving...' : 'Save'),
        ),
      ],
    ),
  );
}
