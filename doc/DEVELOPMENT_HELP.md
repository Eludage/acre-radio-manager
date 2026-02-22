# Development Help

This document contains helpful development-oriented references for working on Acre Radio Manager. It contains the control ID reference, namespace documentation, and variable usage.

## Business Logic

This section describes the intended behavior across the key user interactions.

- **Dialog opened**: The preview area mirrors the current inventory state. `previewRadios` is initialized to `currentRadios`.
- **Inventory changed** (PTT, channel, ear, volume): Changes are applied to ACRE immediately. `currentRadios` and `previewRadios` are both refreshed via `fn_getRadioList`, keeping inventory and preview in sync.
- **Dialog closed**: The current **inventory** state (not preview) is saved as "Last Presets" and all pending savestate changes are flushed to disk via `fn_savePresets`.
- **Savestate added**: A new entry is created and **pre-filled with the current inventory** state so it can immediately be renamed and used.
- **Savestate loaded**: Settings are overlaid onto the **preview area only**. The actual ACRE radio settings and the inventory are untouched.
- **Savestate saved**: Stores the current **inventory** state into the savestate, not the preview state.
- **Savestate applied**: Settings from the savestate are applied to the actual ACRE radios in the player's inventory. Radios are matched by base class type (order-independent). The inventory and preview are both refreshed afterwards.

## Dialog and Control ID Reference

This section lists the main dialog ID (IDD) and the control IDCs used in the Radio Settings dialog (`radioSettingsDialog.hpp`). Use these IDs in scripts to access controls via `findDisplay` and `displayCtrl`.

- Dialog IDs:
  - Acre Radio Manager main dialog idd: 16000

- Controls (idc → control name — brief purpose):
  - Section titles (no idc, -1)
    - RadiosInventoryTitle — section title "Radios in Inventory"
    - RadioPreviewTitle — section title "Radio Preview"
    - RadioPreviewOptionsTitle — section title "Radio Preview Options"
  - Background panels (no idc, -1)
    - Background — main dialog background
    - RadiosInventoryBackground — radios inventory section background
    - RadioPreviewBackground — radio preview section background
    - RadioPreviewOptionsBackground — radio preview options section background
    - RadioPreviewOptionsButtonsBackground — radio preview options buttons background
  - Radios in Inventory controls
    - 16010 → RadiosInventoryGroup — control group for dynamically created radio inventory controls
    - 16100-16399 → Dynamic radio controls (max 12 radios, 25 IDCs per radio)
      - baseIDC + 1 (Name): normally disabled `RscButton` with transparent background; turns green and clickable when copy mode is active and the radio type matches the copy source
      - baseIDC + 9 (Channel Display/Edit): `ARM_RscEdit` (left-aligned edit field) for supported radios (PRC-117F, PRC-152), allowing direct channel number input; `RscText` read-only label for unsupported radios
  - Radio Preview controls
    - 16020 → RadioPreviewGroup — control group for dynamically created radio preview controls
    - 16400-16699 → Dynamic radio preview controls (max 12 radios, 25 IDCs per radio)
  - Radio Preview Options controls
    - 16030 → RadioPreviewOptionsGroup — control group for preset/savestate list
    - 16031 → AddSavestateButton — save current radio settings as preset
    - 16032 → RemoveSavestateButton — delete selected preset
  - Misc controls
    - 16011 → CloseButton — Close dialog button

## Widget Base Classes (radioSettingsDialog.hpp)

These classes are defined in `radioSettingsDialog.hpp` and used as the `ctrlCreate` class argument for dynamically built controls. They ensure `colorFocused` always matches `colorBackground`, preventing the "pressed" highlight when a button retains focus after a click.

| Class | Background | Active Background | Use case |
|---|---|---|---|
| `ARM_RscButton` | `COLOR_BLACK_50` | `COLOR_GREY_20` | Base class (not used directly for dynamic controls) |
| `ARM_RscButtonGrey40` | `COLOR_GREY_40` | `COLOR_GREY_50` | Channel ±, Volume ±, Copy, Load, Save, Apply buttons |
| `ARM_RscButtonGreen` | `COLOR_GREEN` | `COLOR_GREEN_ACTIVE` | Active PTT/ear selection, ear preview display, copy-target name |
| `ARM_RscButtonRed` | `COLOR_RED` | `COLOR_RED_ACTIVE` | PTT X (no PTT), power OFF indicator |
| `ARM_RscButtonTransparent` | `COLOR_BLACK_0` | `COLOR_BLACK_0` | Radio name label (non-copy mode) — invisible, not clickable |
| `ARM_RscEdit` | `COLOR_GREY_15` | n/a | Left-aligned edit field — channel direct-input (inventory), volume edit |
| `ARM_RscEditCentered` | `COLOR_GREY_15` | n/a | Centered edit field variant (`style = 66`) — savestate rename input |

Notes
- Access controls in scripts like this:
  - `_disp = findDisplay 16000; _ctrl = _disp displayCtrl 16010;` (gets the Radios Inventory control group)
  - `_disp = findDisplay 16000; _ctrl = _disp displayCtrl 16020;` (gets the Radio Preview control group)
  - `_disp = findDisplay 16000; _ctrl = _disp displayCtrl 16030;` (gets the Radio Preview Options control group)
  - Then operate on the control: create child controls dynamically using `ctrlCreate`
- Only controls with idc >= 0 can be accessed via `displayCtrl`.
- Controls with idc = -1 are decorative elements (titles, backgrounds) and cannot be accessed directly.

## Namespaces and Variables Used

This section documents the runtime namespaces and variables used by Acre Radio Manager.

### Namespace `uiNamespace`

#### UI State
- `AcreRadioManager_fontSizeLevel`: Number — Current font size level for UI elements. Range: 0-4, where 2 is default size.
- `AcreRadioManager_selectedRadioIdx`: Number — Index of currently selected radio in the inventory listbox. -1 when no selection.
- `AcreRadioManager_selectedRadio`: String — Class name of currently selected radio. Empty string when no selection.
- `AcreRadioManager_currentRadios`: Array or String — Array of radio info arrays, or "" if no radios. Queried fresh from ACRE on each dialog open via `fn_getRadioList`.
  - Each radio info array contains (in order):
    - 0: String — Radio instance ID (e.g., "ACRE_PRC343_ID_1")
    - 1: String — Icon path
    - 2: String — Display name/type (e.g., "AN/PRC-343")
    - 3: Number — PTT assignment (0 = none, 1-3 = PTT keys)
    - 4: Number — Channel number
    - 5: String — Channel name/label
    - 6: String — Ear assignment ("left", "right", "center")
    - 7: Number — Volume (0.0 to 1.0)
    - 8: Boolean — Power state (true = on, false = off)
- `AcreRadioManager_currentSavestateNames`: Array — List of all savestate names in current session. Always has "Last Presets" at index 0.
- `AcreRadioManager_selectedSavestateIndex`: Number — Index of currently selected savestate for removal. -1 when no selection.
- `AcreRadioManager_hintCounter`: Number — Monotonically incrementing counter used by `fn_showHint` to prevent stale spawned clears from wiping a newer hint. Incremented on every `fn_showHint` call.
- `AcreRadioManager_copySource`: Array or nil — Active copy mode source data set when the player clicks a Copy button in the preview area. nil when copy mode is inactive. Format: `[baseClass, ptt, channel, ear, volume]`. Cleared automatically after a successful paste (inventory name click) or when a new Copy is pressed.
- `AcreRadioManager_previewRadios`: Array or String — Radio info arrays used exclusively by the Radio Preview section. Same format as `AcreRadioManager_currentRadios`. Stays in sync with inventory on any inventory change. Diverges when a savestate is loaded via `fn_loadSavestate`, which overlays savestate settings without modifying `currentRadios`.

#### Preview / Session State
- `AcreRadioManager_previewIsLive`: Boolean — `true` when the Radio Preview section is mirroring the live inventory state; `false` when a savestate has been loaded into the preview. Set to `true` on every dialog open.
- `AcreRadioManager_limitHintShown`: Boolean — One-shot flag that prevents the "Radio limit reached" hint from firing on every UI rebuild within the same dialog session. Reset to `false` on dialog open.
- `AcreRadioManager_idcToRadioMap`: HashMap — Maps each radio's base IDC (e.g. 16100) to its ACRE radio instance ID string. Rebuilt every time `fn_updateRadioInventory` runs. Used by event handlers that need the radio ID from an IDC.

#### Radio Settings Cache (`missionNamespace`)
- `AcreRadioManager_channelCountCache`: HashMap — Caches the maximum channel count per radio base class (e.g. `"ACRE_PRC343"` → `16`) to avoid repeated config lookups. Populated lazily on first channel change for each radio type. Stored in `missionNamespace` so it is cleared on mission restart (channel counts are mission-specific).
- `AcreRadioManager_radioSettings`: HashMap — Cached settings for all radios during dialog session. Map of radio class name → settings hashmap.
  - Each settings hashmap contains:
    - "ear": String — "left" or "right" - which ear the radio is on
    - "channel": Number — Current channel number
    - "volume": Number — Current volume level (0.0 to 1.0)
    - "ptt": Number — PTT key assignment (0 = none, 1-3 = PTT 1-3)

### Namespace `profileNamespace`

#### Savestates
- `AcreRadioManager_savestates`: HashMap — Saved radio savestates. Map of savestate name → savestate data array.
  - Each savestate data array contains an array of radio settings in order: [radio1Settings, radio2Settings, ...]
  - Each radio settings array contains: [ptt, channel, ear, volume, baseClass]
    - ptt: Number — PTT assignment (0 = none, 1-3 = PTT keys)
    - channel: Number — Channel number
    - ear: String — "left", "right", or "center"
    - volume: Number — Volume level (0.0 to 1.0)
    - baseClass: String — Radio base class (e.g. "ACRE_PRC343"), used for type-matching on Apply
  - **Power state is intentionally not saved.** The ACRE API does not expose a reliable way to
    change radio power state programmatically. The power button in the inventory UI is read-only.
    When a savestate is applied, power state is left unchanged on all radios.
  - Special savestate "Last Presets" is always present and auto-saves on dialog close
  - "Last Presets" cannot be renamed, deleted, or manually saved to

#### Presets
- `AcreRadioManager_presets`: HashMap — Saved radio presets. Map of preset name → preset data.
  - Each preset contains an array of radio configurations
- `AcreRadioManager_lastPreset`: String — Name of the last used preset. Used for quick reload.

#### Crash Recovery
- `AcreRadioManager_lastRadioSettings`: HashMap — Cached radio settings from last session. Used to restore settings after game crashes or restarts. Saved whenever settings change.

## Notes
- **uiNamespace** is used for temporary state during the game session (UI preferences, dialog state, current radio list). Persists until game restart.
- **profileNamespace** is used for persistent state across game sessions (saved presets, last settings for crash recovery). Survives game crashes and restarts.
- **missionNamespace** is not used in this mod since all state is either temporary (uiNamespace) or permanent (profileNamespace).
- All mod runtime variables use the `AcreRadioManager_` prefix.