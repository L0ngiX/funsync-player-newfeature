# FunSync Player 0.9.2 — Down Only build

This archive contains the modified source for the Buttplug Oscillate behavior and a Windows build script.

## What changed

For devices exposing Buttplug `Oscillate`:

- **Script speed**: original FunSync speed behavior.
- **Up override**: a configured fixed speed is used only while the transformed script position is moving upward (`100 -> 0`). Upward motion (`0 -> 100`) keeps the script-derived speed.
- **Both directions**: the configured fixed speed is used for both moving directions.
- The setting is stored per Buttplug device.
- A value of 0 / Script speed disables the override.
- Linear BLE/Posy handling is not changed.

## Important about `strokes/s`

Buttplug v4 `Oscillate` itself accepts a device-relative speed value, not a universal physical strokes-per-second unit. FunSync therefore maps its fixed `strokes/s` setting onto the same 0–100 speed scale already used by its derived-speed calculation. The actual physical stroke rate can vary by device/firmware.

## Build on Windows

1. Extract the archive.
2. Make sure `ffmpeg\ffmpeg.exe` and `ffmpeg\ffprobe.exe` exist (or are available in PATH).
3. Run `build-windows-down-only-v3.bat`.
4. The script installs/rebuilds Electron, runs the focused Down Only tests, builds the Python backend, fetches Twemoji, and invokes electron-builder.
5. The installer/portable executable will be in `dist\`.

The script intentionally does not run the entire historical Vitest suite, because that suite currently contains unrelated Electron/localStorage environment failures. It does run the new Down Only tests before packaging.
