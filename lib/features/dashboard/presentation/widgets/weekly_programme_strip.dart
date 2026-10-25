import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/plan_days.dart';
import '../../../workouts/data/models/workout_models.dart';

class WeeklyProgrammeStrip extends StatelessWidget {
  final List<WorkoutDay> days;
  final String selectedDay;
  final ValueChanged<WorkoutDay> onOpen;
  const WeeklyProgrammeStrip({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 90,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: weekDays.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final code = shortPlanDay(weekDays[index]);
        final day = days
            .where((day) => shortPlanDay(day.dayOfWeek) == code)
            .firstOrNull;
        final selected = code == selectedDay;
        final scheduled = day != null && !day.rest && day.exercises.isNotEmpty;
        final completed =
            scheduled && day.exercises.every((exercise) => exercise.done);
        final dashed = index >= 5 && !selected && !completed;
        final border = selected
            ? AppColors.primaryRed
            : completed
            ? AppColors.redBorder
            : AppColors.subtleBorder;
        final foreground = selected
            ? AppColors.darkTextOverRed
            : completed
            ? AppColors.primaryRed
            : AppColors.mutedText;
        return Semantics(
          label:
              '$code, ${selected ? 'selected, ' : ''}${completed
                  ? 'completed'
                  : scheduled
                  ? 'training'
                  : 'rest'}',
          selected: selected,
          child: CustomPaint(
            foregroundPainter: dashed ? _DashedDayBorder(border) : null,
            child: Material(
              color: selected
                  ? AppColors.primaryRed
                  : completed
                  ? AppColors.redTint
                  : AppColors.primaryPanel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: dashed ? Colors.transparent : border,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: day != null ? () => onOpen(day) : null,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontFamily: 'AppSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.darkTextOverRed
                              : AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 17),
                      Icon(
                        completed && !selected
                            ? Icons.check
                            : selected && scheduled
                            ? Icons.circle
                            : Icons.remove,
                        size: selected && scheduled ? 9 : 24,
                        color: foreground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _DashedDayBorder extends CustomPainter {
  final Color color;
  const _DashedDayBorder(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 8) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 4).clamp(0, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedDayBorder oldDelegate) =>
      oldDelegate.color != color;
}
