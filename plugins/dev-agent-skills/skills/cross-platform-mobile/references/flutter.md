# Flutter playbook

## Basics
```bash
flutter --version && flutter doctor -v
flutter create --org com.example my_app
flutter pub outdated
flutter analyze && flutter test
```
Pin the Flutter version per project (FVM or `.tool-versions`) so CI and laptops match.

## Upgrading
1. `flutter upgrade` on a branch; read the release notes for that version.
2. `dart fix --apply` then `flutter analyze`.
3. Recent change to expect: Material and Cupertino are standalone packages, so widget imports may need updating.
4. Rebuild both platforms; test on a real device, since renderer changes show up visually.

## Defaults
- State: Riverpod (or Bloc if the team already uses it). Routing: go_router.
- Secrets: flutter_secure_storage. Config: `--dart-define-from-file`, never committed keys.
- Tooling: use the Flutter MCP Server / Agent Skills where available instead of hand-rolled guidance.

## Android target API
Flutter sets targetSdk from its own template. Check `android/app/build.gradle(.kts)` for an explicit `targetSdk`. If none is set, confirm what the pinned Flutter version resolves to against the current Play requirement in `current-state.md`.

## OTA
Shorebird (third party) patches Dart code without store review. Native changes still need a store build.
