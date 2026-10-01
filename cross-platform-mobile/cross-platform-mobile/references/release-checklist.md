# Release checklist

Run `scripts/preflight.sh` first. Then every box below, in order.

## Both platforms
- [ ] Version and build number bumped (EAS can auto-increment; Flutter: pubspec `version: x.y.z+build`).
- [ ] Release build tested on a real device, not only simulator/emulator.
- [ ] No dev-only flags, debug logs with PII, or test API endpoints.
- [ ] Every permission in the manifest is actually used and justified in the store listing.
- [ ] Privacy disclosures match real data collection, including SDKs (analytics, crash reporting, ads).
- [ ] Account deletion path exists in-app if the app supports account creation.

## iOS
- [ ] Built with an SDK the App Store currently accepts (see `current-state.md`; the iOS 27 SDK requirement starts April 2027).
- [ ] Usage description strings present for every permission requested.
- [ ] Privacy manifest covers required-reason APIs used by the app and its dependencies.
- [ ] TestFlight internal test passed before external/production submission.

## Android
- [ ] targetSdk meets the current Play requirement (API 36 for phones/tablets since 2026-08-31).
- [ ] Signed with the Play App Signing upload key; keystore backed up outside the repo.
- [ ] Data safety form updated.
- [ ] Tested on at least one device with the newest OS behavior changes (edge-to-edge, predictive back).
- [ ] Internal testing track before production rollout; use staged rollout.

## After release
- [ ] Crash-free rate watched for 24h; rollback plan (previous build or OTA revert) known before submitting.
