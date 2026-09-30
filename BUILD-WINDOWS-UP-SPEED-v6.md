# FunSync Player 0.9.2 — Up Speed Modifier v6

This build changes the Buttplug derived-speed override used by Vibe, Oscillate, Scalar and Rotate speed paths.

## New behavior

- **Downward movement** keeps 100% of the script-derived speed.
- **Upward movement** uses a configurable **percentage of the current script-derived speed**.
  - `100%` = unchanged script speed.
  - `50%` = half the script speed.
  - `0%` = no output during the overridden upward stroke.
  - Up to `200%` is allowed.
- **Script after down** is a configurable grace period in milliseconds.
  - When downward movement ends, the script keeps full priority for this period.
  - This fixes the immediate `position2 > position1` transition from switching to the upward modifier too early.
  - Example: `300 ms` means the first 300 ms after the downward stroke ends still uses 100% script speed.
- Settings are stored per Buttplug device.
- Existing v5 fixed `strokes/s` settings are migrated to the equivalent percentage using FunSync's previous 3 strokes/s = 100% convention.
- BLE/Posy handling and Linear output are not changed.

## UI

The device row now shows two compact controls:

- `Up speed` — percentage of the script speed during the upward stroke.
- `Script after down` — milliseconds for which script speed remains active after downward motion ends.

## Build

Run `build-windows-down-only-v3.bat` on Windows. It performs the focused unit test, backend build, asset preparation and electron-builder packaging. The historical full Vitest suite is intentionally skipped because of unrelated environment failures documented in the previous build logs.
