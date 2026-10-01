# Choosing a cross-platform stack

Ask at most two questions, then decide. Give a recommendation, not a menu.

| Signal | Points to |
|---|---|
| Team knows TypeScript/React, wants web + mobile code sharing | Expo (Expo Router + react-native-web for shared screens) |
| Standard app: forms, lists, auth, push, maps, payments | Expo |
| Needs a custom native SDK Expo has no plugin for | Expo dev build + config plugin or local module; bare RN only if that fails |
| Pixel-identical custom UI/animation on every platform, game-like rendering | Flutter (own renderer, Impeller) |
| Team knows Dart/Kotlin/Java, no React experience | Flutter |
| Needs desktop (macOS/Windows/Linux) from same codebase as mobile | Flutter (desktop is first-class) |
| Needs OTA hotfixes without store review | Expo: EAS Update. Flutter: Shorebird (third-party) |
| Heavy platform-specific UX (deep iOS widgets, Live Activities, watch apps) | Consider native for that surface; embed or bridge instead of forcing it |

## Defaults inside Expo
- Language: TypeScript, `strict: true`.
- Navigation: Expo Router (file-based). Do not add React Navigation directly unless already present.
- Server state: TanStack Query. Client state: Zustand or React context; avoid Redux for new small apps.
- Storage: expo-secure-store for secrets, expo-sqlite or MMKV for app data.
- Build/release: EAS Build, EAS Submit, EAS Update.
These are opinionated defaults. If the repo already uses something else, follow the repo.

## Anti-recommendations
- Do not pick bare React Native "for flexibility." Expo dev builds plus config plugins cover most native needs.
- Do not pick Flutter only because of benchmarks. Team skill and hiring dominate outcomes.
- Do not recommend rewriting a working app to switch stacks without a concrete blocker.
