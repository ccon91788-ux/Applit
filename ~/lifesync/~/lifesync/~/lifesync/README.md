# LifeSync — Calendar, Reminders & Personal Finance Manager

**LifeSync** is a complete offline-first Android application built with Flutter for managing:

- Calendar & reminders (with Vietnamese lunar calendar)
- Personal finance (income / expense)
- Monthly budgets & alerts
- Savings goals
- Recurring bills
- Analytics charts
- Local backup / restore & CSV export

No login, no cloud, no internet required. All data stays on your device (SQLite).

## Features

- **Calendar**: Month / Week / Day views, events with colors & labels, recurring events, reminders with snooze actions, Vietnamese lunar dates
- **Finance**: Income & expense tracking, quick Vietnamese text input (`Chi 50k ăn sáng`), thousand-separator money fields, notes
- **Budget**: Monthly budget with 80% / 90% / 100% alerts (once per threshold)
- **Savings goals**: Progress indicators, add/remove money
- **Recurring bills**: Due dates on calendar, mark-as-paid → expense + next due date
- **Analytics**: Pie (expense by category), bar (income vs expense trend), date range filters
- **Backup**: JSON export/import with validation; CSV transaction export
- **Theme**: Light / Dark / System (persisted)
- **Notifications**: Local, timezone-aware, channels for reminders / budget / bills, boot reschedule support

## Project structure

```
lib/
  main.dart
  core/           # database, notifications, theme, utils
  models/
  repositories/
  services/       # backup, csv, quick_input, lunar
  screens/        # calendar, finance, analytics
  widgets/
  providers/
test/
  unit/
  database/
  widget/
android/
.github/workflows/build-apk.yml
```

## Build on GitHub Actions

1. Push this repository to GitHub.
2. Open the **Actions** tab → workflow **Build APK**.
3. The workflow runs: `pub get` → format check → analyze → test → `flutter build apk --release`.
4. Download the APK from the workflow **Artifacts** (`lifesync-release-apk`).

## Build locally

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
```

APK path: `build/app/outputs/flutter-apk/app-release.apk`

## Backup & restore

- **Export**: Analytics tab → Sao lưu dữ liệu → share JSON file  
- **Import**: Analytics tab → Khôi phục dữ liệu → pick JSON → confirm  
- Invalid or wrong-version backups are rejected with a Vietnamese error message.

## Notification permissions

On Android 13+: the app requests `POST_NOTIFICATIONS`.  
Exact alarms may require the user to allow exact alarm scheduling in system settings.

Channels:

- LifeSync Reminders  
- LifeSync Budget  
- LifeSync Bills  

## Troubleshooting

| Issue | Suggestion |
|-------|------------|
| Notifications not firing | Grant notification + exact alarm permissions; open app once after reboot |
| Backup import fails | Ensure file is a LifeSync JSON backup (valid version) |
| Analyze / test fails in CI | Do not use `\|\| true`; fix the reported errors |
| Large transaction lists slow | Lists use SQL pagination (30 items per page) |

## License

Private / personal use. Built as a production-ready offline Flutter Android app.
