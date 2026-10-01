# Current state snapshot

**Snapshot date: 2026-09-29.** Refresh monthly. Anything marked VERIFY must be re-checked live before it drives a decision.

## Expo / React Native
- Expo SDK 57 released 2026-06-30 with React Native 0.86; React stays at 19.2 (same as SDK 56).
- Use expo >= 57.0.17 (RN 0.86.3). Earlier 57.0.x had a Hermes V1 memory regression that hit apps importing react-native-worklets or react-native-reanimated, plus a slower dev startup regression.
- Legacy Architecture removed since SDK 55. `newArchEnabled` no longer exists in app.json.
- Expo said the next SDK is expected around Sept/Oct 2026 and is exploring a new release cadence. **VERIFY at https://expo.dev/changelog before starting any new project: SDK 58 may have landed.**
- Third-party libraries lag: peer-dependency caps on expo-* packages can hard-fail `npm install` on a new SDK (seen with a popular auth SDK in Sept 2026). If install fails with ERESOLVE, check the library's issues for a cap before using `--legacy-peer-deps`.

## Flutter
- Latest stable 3.47.1 (2026-08-19), Dart 3.13.1. Impeller is default on macOS/Windows/Linux; Material and Cupertino are standalone packages now (expect import changes on upgrade).
- Cadence: quarterly. 3.50 targeted November 2026. Many enterprises stay one release behind (3.44.x).
- Tooling: Flutter MCP Server and Flutter Agent Skills exist since 3.44. Prefer them over restating their guidance.

## iOS build requirements
- Xcode 27 GA 2026-09-14: Swift 6.4, iOS 27 SDK, Apple silicon only, macOS Tahoe 26.6+ needed to install. Intel CI runners cannot run it.
- App Store: uploads must use iOS 27 SDK or later **starting April 2027** (exact day not published). Until then Xcode 26 builds are accepted. VERIFY exact date at developer.apple.com/news.
- iPhone Duo ships Oct 23 running iOS 27.1; Xcode 27.1 (beta) adds its simulator. Check layouts on new poses if the app targets tablets/foldables.

## Android build requirements
- Since 2026-08-31: new apps and updates must target API 36 (Android 16). Existing untouched apps must target API 35+ to stay installable for new users on newer OS versions.
- Wear OS / Automotive: 35. Android TV / XR: 34.
- Rule resets roughly every August. VERIFY at support.google.com/googleplay/android-developer/answer/11926878.

## Changelog

- 2026-09-29: snapshot created (Expo SDK 57 / RN 0.86, Flutter 3.47.1, Xcode 27, Play API 36).
- 2026-10-01: preflight hardened (Expo <57 FAIL, RN/Flutter floors, unpinned-targetSdk FAIL on old SDKs); thresholds unchanged.
- Next review due: 2026-10-29. Check expo.dev/changelog for SDK 58 first; CI fails past 60 days stale.
