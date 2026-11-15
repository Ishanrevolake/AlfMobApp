# Client PDF changes - 14 November 2026

Reviewed all four pages of the three supplied PDFs, including the annotated screenshots.

## Implemented in AlfMobApp

- Meals: Monday-Sunday dates, today highlighting, previous/next week, calendar picker, planned/eaten calories and eaten protein, assigned meal cards and existing ingredient/instruction screens.
- Weekly grocery list on its own screen. Repeated ingredient portions show how many meals need that portion; unlike unit quantities are not silently combined.
- Extra meals after assigned meals, with name, calories, optional protein, and removal. Extra meals affect eaten totals without changing trainer plans.
- Dated shared meal logs, including home-screen check-offs, isolated by client/date/plan/item. Existing device check-offs remain a legacy fallback when no shared entry exists.
- Train tab opens today's assigned workout or recovery day. Calendar access to other assigned workout days remains available.
- Exercise screen with trainer instructions, optional HTTPS demo video, sets/reps or seconds and rest, actual per-set weights/reps/seconds, checked sets, extra sets and saving. Completion derives from enough checked sets meeting the prescribed target. For a rep range, the lower bound is used. Minute prescriptions are converted to seconds. This uses client-entered logs, not motion sensing.
- Shared set logs and completion loading, scoped to the scheduled date in the current week. Opening a workout from the existing weekday routes logs against that weekday in the current week; those routes do not carry historical calendar dates.
- Mobile trainer exercise editor accepts a demo video URL. Existing notes, sets, reps and rest fields are retained.
- Trainer client detail has an Activity tab with dated meals, extras, calorie/protein totals and set logs.
- Messages show local date/time. Clients can attach images, videos and existing audio recordings. Attachments are stored privately and displayed using signed URLs. Maximum upload size is 50 MB; file formats are restricted by both application validation and storage policy.
- In-app microphone recording was not added. The PDF marks voice messaging optional; audio-file upload is available.

## Implemented in AlphaWebApp

- Trainer and client messaging screens display the structured attachments sent from the mobile app, rather than showing their JSON envelope.
- Trainer messaging threads include a dated client activity panel with planned/eaten calories, protein, extra meals and exercise sets.
- Shared component: `src/components/ClientActivity.tsx`.
- This project has a trainer Q&A workspace, but no workout-plan editor was found. Separate trainer dashboard PDFs are still needed to establish that editor's intended scope/location. No workout editor was invented in the Q&A workspace.

## Required backend setup

Apply `tool/client_daily_logs_and_media.sql` in the shared Supabase project's SQL editor after its existing schema and trainer-role migration. It creates a client daily-log table with owner-write/staff-read row policies and a private attachment bucket with thread-aware storage policies. The script is rerunnable.

No live migration, deployment or client data writes were performed. The new shared logging and attachment features require this migration; until it is applied they report load/save/upload errors. Trainer demo videos must be supplied as direct, playable HTTPS video URLs (such as MP4), not a YouTube page URL.

## Validation

- Full Flutter suite: 93 tests passed, run sequentially after the host ran out of memory during parallel checks.
- Final date-strip/layout and logging checks: 10 tests passed across readability, extra-meal/date isolation/save failure, and set-completion checks.
- Rendered and inspected the meal screen at 390 x 844; readability checks also cover 320 x 640, landscape and tablet with larger text.
- AlphaWebApp TypeScript check passed using `tsc --noEmit --incremental false`.
- Flutter analysis found no compile errors or warnings; 10 pre-existing informational style notices remain in unchanged files.
- Authenticated upload/download/playback, database policies and cross-device delivery still require a live backend smoke test after setup.
- Android debug test APK built as version 1.0.2 (build 3): `releases/Alfa-Lee-1.0.2-test-2026-11-14.apk`. Signature verified and matches the previous 1.0.1 test APK. The build used temporary reduced-memory settings with Jetifier disabled, then restored the original Gradle configuration. Live installation and client/trainer checks are pending.

## Source documents

- `C:/Users/Ishan/Downloads/Meal Overview - Client Login.pdf`
- `C:/Users/Ishan/Downloads/Training Programme - Client Login (1).pdf`
- `C:/Users/Ishan/Downloads/Message - Client Login.pdf`
