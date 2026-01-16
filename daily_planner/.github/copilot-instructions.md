### Purpose
This file gives AI coding agents focused, actionable guidance to be productive in this Flutter app.

**Quick Project Summary**
- **Type:** Flutter multi-platform app (mobile + web + desktop). See `pubspec.yaml` for SDK and deps.
- **UI root:** [lib/main.dart](lib/main.dart) — app uses `MaterialApp` with an `IndexedStack` for pages.
- **Core logic:** [lib/todo_manager.dart](lib/todo_manager.dart) — in-memory `TodoManager` (no DB/persistence).
- **Timeline view:** [lib/daily_timeline.dart](lib/daily_timeline.dart) — receives a `TodoManager` instance via constructor.

**Key Patterns & Decisions (do not assume otherwise)**
- State is passed directly between widgets (no Provider/Bloc used): `DailyTimeline(manager: _todoManager)` in `lib/main.dart`.
- `TodoManager` stores todos in-memory and generates ids using `DateTime.now().microsecondsSinceEpoch`. Changes to persistence must update only this file or add a new storage layer.
- Sample/localized strings: `main.dart` seeds sample todos (French labels in `initState`) — be mindful of hard-coded strings when adding i18n.
- Lints: `flutter_lints` is enabled; prefer adhering to `analysis_options.yaml` rules.

**Developer workflows & commands**
- Get deps: `flutter pub get`
- Run app (hot reload enabled): `flutter run` (press `r` for hot reload, `R` for hot restart in terminal)
- Run on a specific device: `flutter run -d windows` or `flutter run -d chrome` or `flutter run -d <device-id>`
- Build release APK: `flutter build apk`
- Run tests: `flutter test` (single file: `flutter test test/widget_test.dart`)

**Files & locations to touch for common tasks**
- Add UI pages: `lib/` — keep widgets small and lift state to `TodoManager` where appropriate.
- Business logic / persistence: `lib/todo_manager.dart` — prefer adding a storage adapter here rather than scattering persistence calls through UI.
- Platform-specific tweaks: `android/`, `ios/`, `windows/`, `macos/`, `linux/` directories — avoid editing runner files unless necessary.

**Examples (copyable patterns from repo)**
- Create a todo: `final t = TodoManager().addTodo(title: 'Buy milk', deadline: DateTime.now().add(Duration(hours:4)));`
- Mark completed and archive: `manager.markCompleted(t.id);` — archived todos are available via `getArchivedTodos()`
- Get active todos sorted by nearest deadline: `manager.getActiveTodos()`

**Testing & Safety**
- There is a widget test scaffold at `test/widget_test.dart` — use it as the template for future widget tests.
- Unit-test business logic in `lib/todo_manager.dart` first; UI tests can assume `TodoManager` behaviour is covered.

**When changing patterns, prefer minimal, incremental changes**
- If introducing persistence, add a clear storage adapter and keep existing `TodoManager` API stable; update call sites in `lib/main.dart` and `lib/daily_timeline.dart`.

If anything here is unclear or you want more examples (e.g., sample tests or a storage adapter sketch), say so and I will iterate.
