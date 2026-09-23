import 'package:flutter/material.dart';
import '../data/catalog_repository.dart';

Future<PlanRecord?> pickCatalog(
  BuildContext context,
  String title,
  List<PlanRecord> rows,
) => showDialog<PlanRecord>(
  context: context,
  builder: (_) => _CatalogPicker(title: title, rows: rows),
);

class _CatalogPicker extends StatefulWidget {
  final String title;
  final List<PlanRecord> rows;
  const _CatalogPicker({required this.title, required this.rows});
  @override
  State<_CatalogPicker> createState() => _CatalogPickerState();
}

class _CatalogPickerState extends State<_CatalogPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final rows = widget.rows
        .where(
          (r) =>
              '${r['name']} ${r['category'] ?? ''} ${r['equipment'] ?? ''} ${r['basis'] ?? ''}'
                  .toLowerCase()
                  .contains(query.toLowerCase()),
        )
        .toList();
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => query = v),
                ),
              ),
            ),
            if (rows.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No matching items'),
                ),
              )
            else
              SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text('${rows[i]['name']}'),
                  subtitle: Text(
                    '${rows[i]['basis'] ?? rows[i]['category'] ?? ''} ${rows[i]['equipment'] ?? ''}',
                  ),
                  onTap: () => Navigator.pop(context, rows[i]),
                ),
              ),
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanField {
  final String key, label;
  final bool required, number;
  final int lines;
  final List<String>? choices;
  const PlanField(
    this.key,
    this.label, {
    this.required = false,
    this.number = false,
    this.lines = 1,
    this.choices,
  });
}

Future<PlanRecord?> editPlanFields(
  BuildContext context,
  String title,
  PlanRecord initial,
  List<PlanField> fields, {
  Future<void> Function(PlanRecord)? save,
}) => showDialog<PlanRecord>(
  context: context,
  barrierDismissible: false,
  builder: (_) =>
      _FieldsDialog(title: title, initial: initial, fields: fields, save: save),
);

class _FieldsDialog extends StatefulWidget {
  final String title;
  final PlanRecord initial;
  final List<PlanField> fields;
  final Future<void> Function(PlanRecord)? save;
  const _FieldsDialog({
    required this.title,
    required this.initial,
    required this.fields,
    this.save,
  });
  @override
  State<_FieldsDialog> createState() => _FieldsDialogState();
}

class _FieldsDialogState extends State<_FieldsDialog> {
  final form = GlobalKey<FormState>();
  late final controllers = {
    for (final field in widget.fields)
      field.key: TextEditingController(
        text: '${widget.initial[field.key] ?? ''}',
      ),
  };
  bool saving = false;
  String? error;
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                for (final field in widget.fields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: field.choices != null
                        ? DropdownButtonFormField<String>(
                            initialValue:
                                field.choices!.contains(
                                  controllers[field.key]!.text,
                                )
                                ? controllers[field.key]!.text
                                : field.choices!.first,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: field.label),
                            items: field.choices!
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                            onChanged: saving
                                ? null
                                : (v) => controllers[field.key]!.text = v!,
                            onSaved: (v) => controllers[field.key]!.text = v!,
                          )
                        : TextFormField(
                            controller: controllers[field.key],
                            enabled: !saving,
                            maxLines: field.lines,
                            keyboardType: field.number
                                ? const TextInputType.numberWithOptions(
                                    decimal: true,
                                  )
                                : null,
                            decoration: InputDecoration(labelText: field.label),
                            validator: (v) {
                              if (field.required && (v ?? '').trim().isEmpty) {
                                return 'Required';
                              }
                              if (field.number) {
                                final n = num.tryParse(v ?? '');
                                if (n == null || !n.isFinite || n < 0) {
                                  return 'Enter a non-negative number';
                                }
                              }
                              return null;
                            },
                          ),
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
          onPressed: saving
              ? null
              : () async {
                  if (!form.currentState!.validate()) return;
                  form.currentState!.save();
                  final value = {
                    ...widget.initial,
                    for (final field in widget.fields)
                      field.key: field.number
                          ? num.parse(controllers[field.key]!.text)
                          : controllers[field.key]!.text.trim(),
                  };
                  setState(() {
                    saving = true;
                    error = null;
                  });
                  try {
                    await widget.save?.call(value);
                    if (context.mounted) Navigator.pop(context, value);
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        saving = false;
                        error = '$e';
                      });
                    }
                  }
                },
          child: Text(saving ? 'Saving…' : 'Save'),
        ),
      ],
    ),
  );
}
