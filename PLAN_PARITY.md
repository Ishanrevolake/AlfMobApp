# Meal and workout changes

## Workout assignment saves and client refresh

The Add exercise dialog now publishes the current plan when Save is pressed;
the trainer no longer needs a second Save to publish that exercise. Failed
writes keep the dialog open and preserve its inputs without duplicating items
on retry. Returning to client details reloads the plan even when the trainer
used Back after an inline save. Saving a library assignment without adding the
chosen item shows a prompt rather than writing an empty assignment.

Workout and meal upserts explicitly conflict on client_id and require the
database to return that client's ID before reporting success. The active client
app listens for its own workout/meal changes, refreshes on resume, and polls
every 30 seconds while foregrounded as a fallback. Realtime requires the tables
to be enabled in the Supabase publication (as in the dashboard schema scripts).
Tests cover immediate exercise publishing, failed-save retries, confirmed
write/read serialization, and an already-open client's remote/resume refresh.
Authenticated writes between physical trainer/client devices remain untested.

## Responsive layouts and library spacing

Exercise and meal library cards fill the available phone width and use equal
columns on wider displays. Category controls, content and actions have explicit
spacing; actions wrap and longer meals expand through View meal details.
Card and dashboard row heights follow content rather than fixed aspect ratios.
Column counts account for available width and system text size.

All routed screens share display-cutout protection and a 1200px maximum viewport.
Navigation labels wrap and the bar grows with text size. Catalog pickers and the
credit purchase sheet scroll within the remaining screen/keyboard space.

Widget coverage includes library cards and trainer overview at 320, 390, 768,
844 (landscape), and 1440px widths with 100% and 150% text; client home, profile,
Ask Alpha, trainer clients/more, meal and workout screens on compact and landscape
screens; and catalog selection with a simulated landscape keyboard. These are
automated layout checks, not certification of every device or every live-data state.

## Trainer Programmes / Packages

The mobile trainer Programmes tab now manages the existing Supabase `packages`
catalog directly, using the signed-in user's permissions. Add and Edit save
name, duration text, whole-rupee LKR price, category and description. Other
catalog fields are preserved on edits, and client selection/payment snapshots
are unchanged. Catalog changes affect any consumer of this shared table.

Remove checks `package_selections` before deleting and shows a notification for
assigned packages. The existing restrictive foreign key also protects against
concurrent assignments. Historical selections block deletion too, because the
schema has no assignment completion status. Counts show distinct linked clients
by package ID, including historical selections. Search, refresh and retry remain.

The web dashboard UI is unchanged and still uses its static package options and
selection titles; it does not yet manage or fully reflect this database catalog.
The mobile catalog therefore uses actual stored titles and duration text instead
of the dashboard's hardcoded durations. The schema reference is the sibling
AlphaWebApp `supabase-packages-migration.sql`, including staff RLS policies.
Tests use fake HTTP responses; no live package records were modified.

The reference is `F:\DELLO_SITES\FitnessDashboard`. These changes cover the meal
and exercise libraries, client plan editing, and the client meal/exercise views.

- The Library now supports creating and editing exercises through the existing
  dashboard API, using the signed-in user's access token.
- Meals use the dashboard's 40 templates and 86 foods. Exercises use the shared
  database, with the 176 bundled exercises available when the table is empty.
- Custom meal templates can be created, edited, removed, and assigned. Templates
  are stored per account on this device. The reference web app stores its custom
  templates in browser local storage, so those custom libraries do not sync.
  Assigned client plans are saved to the shared Supabase tables.
- Client plan editors support adding, editing and removing meals/exercises;
  choosing a weekday or every day for meals; workout day management; start dates
  and trainer notes; exercise sets, reps, rest and tempo; and food portions with
  the same nutrition calculation and rounding as the dashboard.
- Saves use full weekday names and preserve web IDs, food portions, notes and
  decimal nutrition values. New meals include the arrays expected by the web UI.
- Failed saves retain the draft, and leaving with changes asks before discarding.
- Clients can view other meal days, food instructions and exercise details.

## Validation

`flutter test` covers serialization compatibility, catalog imports, portion
calculations, form validation, every-day assignment and save failure/retry.

Manual verification with a trainer account:

1. Add an exercise in Library and verify it appears on the dashboard.
2. Open a client, edit their workout plan, add a day and assign an exercise.
   Change its rest, tempo and notes, save, and verify those fields on the web.
3. Assign a meal template to every day. Add a food portion, change its amount,
   save, and compare the weekday, items and nutrition totals on the dashboard.
4. Edit/remove an assigned item, save and reopen the plan.
5. As the client, navigate meal weekdays and open workout exercise information.

The public exercise API was checked read-only. Authenticated production writes
were not exercised; no live client plans were modified during development.

## Catalog refresh

Run `node tool/import_catalogs.cjs` to refresh bundled catalogs from the sibling
dashboard. Pass a dashboard path as the first argument if it is elsewhere.

The API host defaults to `https://alfdashboard.dellodigital.com` and can be changed
using `--dart-define=DASHBOARD_URL=...`. Supabase configuration is described in
`.env.example`.

## Client check-offs and readability

Client meal/workout completion is stored in SharedPreferences, separately from
trainer-owned plans. Clients no longer attempt upserts against the protected
`client_meal_plans` or `client_workout_plans` tables. Check-offs are scoped by
account, local calendar week, plan start date, day and assigned item. They survive
app restarts on this device and reset for a new week. They do not sync to another
device or the dashboard, and clearing app storage removes them. The screens
state that check-offs are saved on this device. Trainer plan edits still sync.

Storage failures roll back only the check-off, leaving the plan visible for
retry. Duplicate in-flight taps are ignored. Tests cover both check-off types,
reopening, account isolation, weekly reset and failed writes.

All app text uses bundled Roboto (AppSans), with larger small labels, reduced
letter spacing and brighter secondary text. Fonts work offline; the license is
included at `assets/fonts/roboto_license.txt`. Client meal/workout widget tests
exercise 390px screens at 120% text size.
