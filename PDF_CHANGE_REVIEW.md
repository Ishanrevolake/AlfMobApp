# PDF change review - 26 October 2026

Reviewed all four pages of the three supplied PDFs, including the annotated screenshots. The Flutter changes are in this project. The web trainer dashboard changes are in the subsequently supplied `F:\DELLO_SITES\FitnessDashboard` project.

## Client home screen

| Requested change | Result |
| --- | --- |
| Remove home branding and use "Hey [first name]" | Already implemented. |
| Display weekday, short month/date, and training week | Already implemented. Training weeks use the saved plan start date. |
| Move this week's programme above today's session | Adjusted. |
| Calendar icon opens a screen for upcoming workouts and meals | Adjusted: opens the existing calendar screen instead of a date-picker dialog. |
| Remove Ask Alpha purchases/credits from client home navigation | Already implemented: client navigation opens Messages, without purchase cards on home. |
| Keep the message icon without a visible label | Adjusted. Accessible tooltip remains. |
| Red dot for unread trainer messages | Added. Checks Supabase for incoming messages every 30 seconds while the client shell is active. Opening a conversation marks received trainer messages as read on this device. Read state is scoped by client and thread and is not synced between devices. |
| Lighter navigation icons | Existing outline icons retained; size reduced from 24 to 22. |
| Home meal cards: Breakfast, Lunch, Dinner, Snacks, Pre-Workout, Post-Workout; kcal and protein | Already implemented. |
| Full meal plan and ingredients/instructions on opening a meal | Already implemented. Calendar meal entries now also open meal details. |
| Meal check-offs with logged/unmarked feedback | Home feedback already implemented; added feedback to check-offs in the full meal plan as well. |

## Session notes

| Requested change | Result |
| --- | --- |
| Separate trainer guidance for each workout day | Implemented in the earlier changes; verified trainer edits and saves one day without changing another. |
| Client can read guidance for that day | Session screen already implemented; added note visibility to home, programme list, calendar, and trainer workout overview. Rest-day guidance is accessible too. |
| Keep notes when plans save or exercises are checked off | Verified by repository round-trip tests. Stored in each day's `notes` within `client_workout_plans.days`. No new table or column required. |
| Small-screen access to notes and exercises | Session header, notes, exercises and completion button now scroll together. Checked with larger text in portrait and landscape. |
| Separate web dashboard day notes | Updated the trainer's selected-day editor, week overview, profile workout summary, and client's assigned exercise view to use per-day `notes`, matching the mobile JSON format. General legacy plan notes remain preserved. |

## Training calendar

| Requested change | Result |
| --- | --- |
| Correct calendar dates and weekdays | Mobile uses Flutter's native date pickers. Regression test confirms 2 October 2026 displays as Friday. Workout/meal weekday lookup now uses the date's numeric weekday, independent of locale abbreviations. |
| Plans begin on Monday | Earlier agreed change retained: new workout plans default to the next Monday, including today if Monday. Workout start-date picker permits Mondays only. Existing saved dates are preserved until changed explicitly. |
| Correct web dashboard monthly calendar | Replaced the fixed 28-day grid and list-position cycling with real calendar dates, Monday-based column offsets, actual month lengths, month navigation, and weekday-based workout lookup. No workouts appear before the saved start date. |
| Preserve the dashboard start date | Fixed both the editor and API, which previously replaced the date with today on save. New dates must be Mondays; unchanged legacy dates remain supported. New dashboard workout plans default to the next Monday. |

## Validation and delivery

- Full Flutter suite passed: 91 tests.
- Additional focused checks cover day-specific note persistence, rest-day notes, home-to-calendar navigation, unread message/read state, and Monday start dates.
- Rendered and visually inspected the PDFs and mobile training/rest-day notes screens.
- No live client data or Supabase schema changes were made.
- No APK was built or installed as part of this review.
- Dashboard regression tests cover the actual month rendering, weekday alignment, month lengths/leap years, no workouts before start, Monday defaults, API date preservation/validation, and independent day-note editing/saving. Tests use mock data and do not write live client plans.
- Dashboard production build and TypeScript checks passed. The nine focused workout/calendar tests and four existing client/payment tests passed.
- Targeted dashboard lint still reports two pre-existing React purity errors in the meal editor's `createFoodPortion` default parameter, plus existing unused-import/image warnings. The same `Date.now()`/`Math.random()` code is present in HEAD; this review did not change it.
- Live authenticated messaging delivery and a deployed end-to-end check still need environment-specific verification.

## Source documents

- `C:\Users\Ishan\Downloads\Home Screen Client Login.pdf`
- `C:\Users\Ishan\Downloads\The Session Notes (trainer notes) - Client_Trainer Login & Dashboard.pdf`
- `C:\Users\Ishan\Downloads\Training Plan Calendar.pdf`
