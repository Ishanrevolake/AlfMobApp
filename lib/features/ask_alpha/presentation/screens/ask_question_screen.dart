import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/alf_widgets.dart';
import '../controllers/ask_alpha_controller.dart';

class AskQuestionScreen extends ConsumerStatefulWidget {
  const AskQuestionScreen({super.key});
  @override
  ConsumerState<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends ConsumerState<AskQuestionScreen> {
  final question = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(askAlphaControllerProvider).value?.credits ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('ASK NEW QUESTION')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AlfPageTitle(
            eyebrow: '$credits credits available',
            title: 'Ask your coach',
            subtitle:
                'Be specific and include the exercise, symptoms, or context that will help your coach answer.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: question,
            minLines: 6,
            maxLines: 12,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Write your question…'),
          ),
          const SizedBox(height: 14),
          const AlfPanel(
            child: Text(
              'This submission uses one verified Ask Alpha credit. Your coach can reply directly in the app.',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saving || credits <= 0 ? null : _submit,
            child: saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SUBMIT QUESTION · USE 1 CREDIT'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (question.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write your question first.')),
      );
      return;
    }
    setState(() => saving = true);
    try {
      final thread = await ref
          .read(askAlphaControllerProvider.notifier)
          .submitQuestion(question.text.trim());
      if (mounted)
        context.go('/client/ask-alpha/thread/${thread.id}', extra: thread);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
