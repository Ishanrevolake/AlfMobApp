import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alfalee_app/features/ask_alpha/data/models/ask_alpha_models.dart';
import 'package:alfalee_app/features/ask_alpha/presentation/controllers/message_unread_controller.dart';
import 'package:alfalee_app/features/navigation/presentation/app_shells.dart';

AskAlphaMessage message(String id, String role, DateTime time) =>
    AskAlphaMessage(
      id: id,
      threadId: 'thread',
      senderId: role,
      senderRole: role,
      content: 'Hello',
      createdAt: time,
    );

void main() {
  test('Only unseen incoming messages trigger the unread dot', () {
    final time = DateTime(2026, 10, 26, 10);
    final trainer = message('1', 'trainer', time);
    expect(
      hasUnreadTrainerMessage([message('2', 'client', time)], null),
      isFalse,
    );
    expect(hasUnreadTrainerMessage([trainer], null), isTrue);
    expect(hasUnreadTrainerMessage([trainer], time), isFalse);
    expect(
      hasUnreadTrainerMessage([
        trainer,
        message('3', 'trainer', time.add(const Duration(minutes: 1))),
      ], time),
      isTrue,
    );
  });

  test(
    'Read status persists per user and thread and never moves backwards',
    () async {
      SharedPreferences.setMockInitialValues({});
      final time = DateTime(2026, 10, 26, 10);
      await markTrainerMessagesRead('client', 'thread', [
        message('1', 'trainer', time),
      ]);
      await markTrainerMessagesRead('client', 'thread', [
        message('0', 'trainer', time.subtract(const Duration(minutes: 1))),
      ]);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(messageReadKey('client', 'thread')),
        time.toIso8601String(),
      );
      expect(
        prefs.getString(messageReadKey('another-client', 'thread')),
        isNull,
      );
      expect(
        prefs.getString(messageReadKey('client', 'another-thread')),
        isNull,
      );
    },
  );

  testWidgets(
    'Message navigation keeps an accessible icon without a visible label',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AlfNavigationBar(
              index: 0,
              onSelect: (_) {},
              iconOnlyIndex: 1,
              messageUnread: true,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'HOME',
                ),
                NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  label: 'MESSAGES',
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('MESSAGES'), findsNothing);
      expect(find.byTooltip('MESSAGES'), findsOneWidget);
      expect(
        tester
            .widgetList<Badge>(find.byType(Badge))
            .where((badge) => badge.isLabelVisible)
            .length,
        1,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
