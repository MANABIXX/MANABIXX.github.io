# MANABIXX Android Release

The Android APK is published by GitHub Actions only after all validation steps pass.

## Release pipeline

1. Generate the Android project from the Flutter source.
2. Resolve Flutter dependencies.
3. Run `flutter analyze`.
4. Run `flutter test`.
5. Build the universal release APK.
6. Verify the APK is non-empty and calculate its SHA-256 checksum.
7. Upload a 30-day workflow artifact.
8. Create or update the versioned GitHub Release and attach `MANABIXX-Android.apk`.
9. Verify that the release contains the non-empty APK asset.

- Workflow: `.github/workflows/android-apk.yml`
- Artifact: `MANABIXX-Android-APK`
- Release version: derived from `flutter/pubspec.yaml`
- Current version: `0.1.0+1` (release tag `v0.1.0`)

A release is not considered complete until the GitHub Actions run succeeds and the APK is visible on the Releases page.
