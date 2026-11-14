# Noto Sans JP assets

The CI preparation step `npm run fetch:flutter-fonts` places the static Regular (400) and Bold (700) TTF files in this directory before `flutter pub get` and the Web build.

The font files are bundled into the Flutter application; no Google Fonts request is made at runtime. The Open Font License is downloaded as `OFL.txt` alongside the font files.
