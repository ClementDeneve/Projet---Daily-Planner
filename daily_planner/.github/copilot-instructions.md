### Purpose
This file gives AI coding agents focused, actionable guidance to be productive in this Flutter app.

## Quick Project Summary
- Type: Flutter multi-platform app (mobile, web, desktop). See `pubspec.yaml` for SDK and deps.
- UI root: `lib/main.dart` — uses `MaterialApp` and an `IndexedStack` to switch pages.
- Core logic: `lib/todolist/todo_manager.dart` — in-memory `TodoManager` (no DB/persistence).
- Pages: `lib/todolist/todo_list_page.dart`, `lib/todolist/edit_todo_page.dart`, `lib/timeline/daily_timeline.dart`.

## Key Patterns & Decisions (explicit, project-specific)
- State is passed by object reference: a single `TodoManager` instance is created in `MyHomePage` and passed into pages (`TodoListPage(manager: _todoManager)`, `DailyTimeline(manager: _todoManager)`).
- `TodoManager` lives under `lib/todolist/` and is the single place for business logic: add/update/remove/complete/restore. Prefer adding adapters here for persistence rather than scattering storage calls in UI files.
- ID generation: `addTodo()` uses `DateTime.now().microsecondsSinceEpoch.toString()` as the default id — any migration to UUIDs or DB ids should preserve `TodoManager` API.
- Sorting & semantics: `getActiveTodos()` returns todos sorted by nearest deadline ascending; `getArchivedTodos()` returns most-recently-completed first.
- Sample data: `MyHomePage.initState()` seeds example todos (French titles). Be aware of hard-coded strings when touching i18n/localization.

## Developer workflows & useful commands
- Fetch deps: `flutter pub get`
- Run app: `flutter run` (press `r` for hot reload, `R` for full restart in the terminal)
- Run on specific device: `flutter run -d windows` or `flutter run -d chrome` or `flutter run -d <device-id>`
- Build release APK: `flutter build apk`
- Run tests: `flutter test` (to run a single test file: `flutter test test/widget_test.dart`)

## Project-specific conventions
- Keep widget code in `lib/` and feature folders under `lib/` (e.g., `lib/todolist/`, `lib/timeline/`, `lib/widgets/`).
- Business logic belongs in `lib/todolist/todo_manager.dart` — UI files read from/write to this manager and call `setState()` in `MyHomePage` or page-local state when UI updates are needed.
- Avoid adding global state libraries without clear need; current design intentionally keeps dependencies minimal and state local.

## Integration points & extension notes
- Persistence: no persistence is implemented. To add persistence, implement a storage adapter (e.g., `TodoStorage`) and inject it into `TodoManager` or create `PersistentTodoManager` that implements the same public API.
- Platforms: platform-specific runner code lives under `android/`, `ios/`, `windows/`, `macos/`, `linux/`. Avoid changing runner files unless necessary for platform integration.

## Concrete examples from the codebase
- Adding a todo (from UI flow in `lib/main.dart`):

```dart
final result = await Navigator.of(context).push<Map<String, dynamic>?>(
  MaterialPageRoute(builder: (_) => const EditTodoPage()),
);
if (result != null) {
  _todoManager.addTodo(title: result['title'] as String, description: result['description'] as String?, deadline: result['deadline'] as DateTime);
}
```

- Marking completed (see `lib/todolist/todo_manager.dart`):

```dart
manager.markCompleted(todoId);
final archives = manager.getArchivedTodos();
```

## Files to inspect when changing behavior
- `lib/main.dart` — app bootstrap, `MyHomePage`, sample data seeding, navigation & FAB actions.
- `lib/todolist/todo_manager.dart` — authoritative business logic.
- `lib/todolist/` — UI pages for editing and listing todos.
- `lib/timeline/daily_timeline.dart` — timeline view consuming `TodoManager`.
- `analysis_options.yaml` — active lints; follow these rules.

## Testing guidance
- Unit-test `TodoManager` logic first (add/update/complete/restore/remove). UI/widget tests can mock or use a real `TodoManager` instance seeded with deterministic data.

If you want, I can also:
- add a simple `TodoStorage` interface and a sample file-backed adapter sketch
- generate unit tests for `TodoManager`

Please tell me which of the above you want next or what to clarify.
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
