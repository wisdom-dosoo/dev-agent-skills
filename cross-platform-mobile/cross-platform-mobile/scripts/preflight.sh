#!/usr/bin/env bash
# Deterministic preflight for Expo / bare React Native / Flutter projects.
# Usage: scripts/preflight.sh [project-root]
# Exit code: 0 = no FAIL lines, 1 = at least one FAIL.
# Thresholds below mirror references/current-state.md (snapshot 2026-09-29).
# Update them when that file is refreshed.

MIN_ANDROID_TARGET=36       # Google Play, new apps/updates since 2026-08-31
MIN_XCODE_NOW=26            # accepted by App Store today
XCODE_REQUIRED_APRIL_2027=27
EXPO_MIN_SDK=57             # SDK 57 (RN 0.86) is the oldest supported; earlier SDKs default to targetSdk < 36
RN_MIN_MINOR=86             # react-native 0.86 ships with SDK 57
FLUTTER_MIN="3.44.0"        # one release behind current stable; older lacks Impeller-default + standalone Material/Cupertino

PASS=0; WARN=0; FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
warn() { echo "  [warn] $1"; WARN=$((WARN+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "Preflight in $(pwd)"

# ---- detect stack ---------------------------------------------------------
STACK=""
if [ -f package.json ] && grep -q '"expo"' package.json; then STACK="expo"
elif [ -f pubspec.yaml ]; then STACK="flutter"
elif [ -f package.json ] && grep -q '"react-native"' package.json; then STACK="react-native-bare"
fi
if [ -z "$STACK" ]; then bad "No Expo, Flutter, or React Native project detected"; echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"; exit 1; fi
echo "Stack: $STACK"; echo

# ---- common ---------------------------------------------------------------
echo "Common"
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -z "$(git status --porcelain)" ]; then ok "git working tree clean"; else warn "uncommitted changes; commit or stash before upgrading"; fi
else warn "not a git repository"; fi

case "$STACK" in
  expo|react-native-bare)
    if [ -f package-lock.json ] || [ -f yarn.lock ] || [ -f pnpm-lock.yaml ] || [ -f bun.lockb ] || [ -f bun.lock ]; then ok "lockfile present"; else bad "no lockfile; installs are not reproducible"; fi
    ;;
  flutter)
    if [ -f pubspec.lock ]; then ok "pubspec.lock present"; else warn "pubspec.lock missing (fine for packages, not for apps)"; fi
    ;;
esac

# ---- stack-specific -------------------------------------------------------
echo; echo "$STACK"
case "$STACK" in
  expo)
    if command -v node >/dev/null 2>&1; then
      EXPO_V=$(node -e 'try{const p=require("./package.json");const d={...p.dependencies,...p.devDependencies};console.log(d.expo||"")}catch(e){}')
      RN_V=$(node -e 'try{const p=require("./package.json");const d={...p.dependencies,...p.devDependencies};console.log(d["react-native"]||"")}catch(e){}')
      [ -n "$EXPO_V" ] && ok "expo $EXPO_V, react-native ${RN_V:-?}" || warn "could not read expo version"
      # Expo SDK floor: SDK < 57 cannot satisfy the Play API-36 default and misses
      # current Hermes / new-architecture fixes. Parse the leading major number.
      EXPO_SDK=$(printf '%s' "$EXPO_V" | grep -oE '[0-9]+' | head -1)
      if [ -n "$EXPO_SDK" ]; then
        if [ "$EXPO_SDK" -lt "$EXPO_MIN_SDK" ]; then
          bad "expo $EXPO_V is below SDK $EXPO_MIN_SDK; upgrade one SDK at a time with npx expo install --fix"
        fi
      fi
      # React Native paired with the SDK: warn when older than the SDK floor's RN.
      RN_MINOR=$(printf '%s' "$RN_V" | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f2)
      if [ -n "$RN_MINOR" ] && [ "$RN_MINOR" -lt "$RN_MIN_MINOR" ] 2>/dev/null; then
        warn "react-native $RN_V is older than 0.$RN_MIN_MINOR (SDK $EXPO_MIN_SDK); it upgrades with the SDK, do not bump it alone"
      fi
    else warn "node not found"; fi

    # newArchEnabled was removed with the Legacy Architecture (SDK 55+)
    if grep -Rqs 'newArchEnabled' app.json app.config.js app.config.ts 2>/dev/null; then
      bad "newArchEnabled found in app config; remove it (Legacy Architecture no longer supported)"
    else ok "no newArchEnabled option"; fi

    # secrets leaking through EXPO_PUBLIC_
    if grep -RIlsE 'EXPO_PUBLIC_[A-Z0-9_]*(SECRET|PRIVATE|PASSWORD|TOKEN|SERVICE_ROLE)' --include='.env*' --include='*.ts' --include='*.tsx' --include='*.js' --include='eas.json' . 2>/dev/null | grep -v node_modules | grep -q .; then
      bad "EXPO_PUBLIC_ variable name suggests a secret; these ship inside the app bundle"
    else ok "no secret-looking EXPO_PUBLIC_ variables"; fi

    # explicit Android target API, if pinned via expo-build-properties
    T=$(grep -RhoE '"?targetSdkVersion"?[[:space:]]*:[[:space:]]*[0-9]+' app.json app.config.js app.config.ts 2>/dev/null | grep -oE '[0-9]+$' | head -1)
    if [ -n "$T" ]; then
      [ "$T" -ge "$MIN_ANDROID_TARGET" ] && ok "targetSdkVersion pinned to $T" || bad "targetSdkVersion $T < $MIN_ANDROID_TARGET (Google Play minimum)"
    elif [ -n "${EXPO_SDK:-}" ] && [ "$EXPO_SDK" -lt "$EXPO_MIN_SDK" ] 2>/dev/null; then
      bad "targetSdkVersion not pinned and expo SDK $EXPO_SDK defaults below $MIN_ANDROID_TARGET; upgrade to SDK $EXPO_MIN_SDK+ (which targets $MIN_ANDROID_TARGET) or pin via expo-build-properties"
    else warn "targetSdkVersion not pinned; it comes from the Expo SDK default. Confirm against Play requirement for this SDK"; fi

    [ -f eas.json ] && ok "eas.json present" || warn "no eas.json; run 'eas build:configure' before shipping"

    if [ "${RUN_DOCTOR:-0}" = "1" ]; then
      echo "  running npx expo-doctor (needs network)..."
      npx --yes expo-doctor && ok "expo-doctor clean" || bad "expo-doctor reported problems"
    else warn "skipped expo-doctor (run with RUN_DOCTOR=1 to include it)"; fi
    ;;

  react-native-bare)
    if command -v node >/dev/null 2>&1; then
      BARE_RN=$(node -e 'try{const p=require("./package.json");const d={...p.dependencies,...p.devDependencies};console.log(d["react-native"]||"")}catch(e){}')
      BARE_MINOR=$(printf '%s' "$BARE_RN" | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f2)
      if [ -n "$BARE_MINOR" ]; then
        if [ "$BARE_MINOR" -lt 76 ] 2>/dev/null; then
          bad "react-native $BARE_RN is far below current (0.$RN_MIN_MINOR+ with Expo SDK $EXPO_MIN_SDK); upgrade before targeting Play API $MIN_ANDROID_TARGET"
        elif [ "$BARE_MINOR" -lt "$RN_MIN_MINOR" ] 2>/dev/null; then
          warn "react-native $BARE_RN is older than 0.$RN_MIN_MINOR; plan an upgrade alongside the targetSdk move"
        else ok "react-native $BARE_RN"; fi
      fi
    fi
    G=$(ls android/app/build.gradle android/app/build.gradle.kts 2>/dev/null | head -1)
    if [ -n "$G" ]; then
      T=$(grep -hoE 'targetSdk(Version)?[[:space:]=]+[0-9]+' "$G" | grep -oE '[0-9]+$' | head -1)
      if [ -n "$T" ]; then [ "$T" -ge "$MIN_ANDROID_TARGET" ] && ok "targetSdk $T" || bad "targetSdk $T < $MIN_ANDROID_TARGET"
      else warn "targetSdk set indirectly (rootProject.ext?); check android/build.gradle"; fi
    else warn "android/app/build.gradle not found"; fi
    ;;

  flutter)
    if command -v flutter >/dev/null 2>&1; then
      FL_LINE="$(flutter --version 2>/dev/null | head -1)"
      ok "$FL_LINE"
      FL_V=$(printf '%s' "$FL_LINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
      if [ -n "$FL_V" ] && command -v node >/dev/null 2>&1; then
        if ! node -e '
          const p=s=>String(s).split(".").map(x=>parseInt(x,10)||0);
          const a=p(process.argv[1]),b=p(process.argv[2]);
          for(let i=0;i<3;i++){if(a[i]>b[i])process.exit(0);if(a[i]<b[i])process.exit(1)}process.exit(0)' "$FL_V" "$FLUTTER_MIN"; then
          bad "flutter $FL_V is below $FLUTTER_MIN; upgrade (quarterly cadence, 3.50 targeted Nov 2026) and expect Material/Cupertino import changes"
        fi
      elif [ -n "$FL_V" ]; then
        case "$FL_V" in 3.4[4-9]*|3.[5-9]*|[4-9].*) ok "flutter $FL_V meets the $FLUTTER_MIN floor";; *) warn "flutter $FL_V looks below $FLUTTER_MIN (node unavailable for precise compare)";; esac
      fi
    else warn "flutter not on PATH"; fi
    G=$(ls android/app/build.gradle android/app/build.gradle.kts 2>/dev/null | head -1)
    if [ -n "$G" ]; then
      T=$(grep -hoE 'targetSdk(Version)?[[:space:]=]+[0-9]+' "$G" | grep -oE '[0-9]+$' | head -1)
      if [ -n "$T" ]; then [ "$T" -ge "$MIN_ANDROID_TARGET" ] && ok "targetSdk $T" || bad "targetSdk $T < $MIN_ANDROID_TARGET"
      else warn "targetSdk comes from Flutter's default (flutter.targetSdkVersion); confirm it meets API $MIN_ANDROID_TARGET for your pinned Flutter"; fi
    else warn "android/app/build.gradle not found"; fi
    ;;
esac

# ---- iOS toolchain (macOS only) -------------------------------------------
echo; echo "iOS toolchain"
if [ "$(uname -s)" = "Darwin" ]; then
  if command -v xcodebuild >/dev/null 2>&1; then
    XV=$(xcodebuild -version 2>/dev/null | head -1 | grep -oE '[0-9]+' | head -1)
    if [ -n "$XV" ]; then
      if [ "$XV" -lt "$MIN_XCODE_NOW" ]; then bad "Xcode $XV is below the App Store minimum ($MIN_XCODE_NOW)"
      elif [ "$XV" -lt "$XCODE_REQUIRED_APRIL_2027" ]; then warn "Xcode $XV accepted today; iOS 27 SDK (Xcode $XCODE_REQUIRED_APRIL_2027) required from April 2027"
      else ok "Xcode $XV"; fi
    fi
    [ "$(uname -m)" = "arm64" ] && ok "Apple silicon" || warn "Intel Mac cannot run Xcode 27"
  else warn "xcodebuild not found"; fi
else
  warn "not macOS; iOS can only be built via EAS/CI runners, not locally"
fi

echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
