Noto Emoji Updater
---

**Flashable ZIP** to update Android [emoji set](https://www.google.com/get/noto/help/emoji/) to the latest available, usually to the newest Android version. This also includes an OTA survival `addon.d` script.

Noto Emoji is the emoji set used by the Android system and it currently supports all emoji defined in the latest Unicode version (v10.0). Font is availabe under the [SIL Open Font License, version 1.1](https://github.com/googlei18n/noto-emoji/blob/master/fonts/LICENSE).
The flashable ZIP saves a copy of the previous installed emoji on your device at `/system/fonts/NotoColorEmoji.ttf.old`.


Build
===

Run:
```
make build
```

This will generate a `noto-emoji.zip` in the `build/` folder.

To make a public release, run:
```
make release
```

This will generate a `noto-emoji-{version}_YYYY-MM-DD.zip` file in the `releases/` folder.


Install
===

You'll need a custom recovery installed on your device, such as [TWRP](https://twrp.me/).

Restart your device into recovery and start `ADB sideload`. Then run:
```
adb sideload <flashable-zip-name>
```

Alternatively, copy the resulting ZIP to your device storage, restart your device into recovery and use the GUI `Install` or `Install ZIP` option.
