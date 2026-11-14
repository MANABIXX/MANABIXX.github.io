# MANABIXX Android Release

This file records the Android APK release workflow trigger. The release artifact is produced by GitHub Actions after the Flutter analyze, tests, and release build all pass.

- Workflow: `.github/workflows/android-apk.yml`
- Artifact: `MANABIXX-Android-APK`
- GitHub Release: version derived from `pubspec.yaml`

A successful workflow run is required before describing an APK as released.
