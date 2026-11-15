import 'package:flutter_test/flutter_test.dart';
import 'package:alfalee_app/features/workouts/presentation/screens/client_exercise_screen.dart';

void main() {
  test('completion requires enough checked sets at target reps', () {
    final rows = [
      {'reps': 8, 'done': true},
      {'reps': 8, 'done': false},
    ];
    expect(setsMeetTarget(rows, '2', '8-12'), false);
    rows[1]['done'] = true;
    expect(setsMeetTarget(rows, '2', '8-12'), true);
    rows[1]['reps'] = 7;
    expect(setsMeetTarget(rows, '2', '8-12'), false);
    expect(setsMeetTarget(rows, 'unknown', '8'), false);
    expect(
      setsMeetTarget(
        [
          {'reps': 40, 'done': true},
        ],
        '1',
        '40 sec',
      ),
      true,
    );
    expect(
      setsMeetTarget(
        [
          {'reps': 40, 'done': true},
        ],
        '1',
        '',
      ),
      false,
    );
  });
}
