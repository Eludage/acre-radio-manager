# Development Help

This document contains helpful development-oriented references for working on Acre Radio Manager. It contains the control ID reference, namespace documentation, and variable usage.

## Dialog and Control ID Reference

This section lists the main dialog ID (IDD) and the control IDCs used in the Radio Settings dialog (`radioSettingsDialog.hpp`). Use these IDs in scripts to access controls via `findDisplay` and `displayCtrl`.

- Dialog IDs:
  - Acre Radio Manager main dialog idd: 16000

- Controls (idc → control name — brief purpose):
  - Section titles (no idc, -1)
    - RadiosInventoryTitle — section title "Radios in Inventory"
    - RadioPreviewTitle — section title "Radio Preview"
    - OptionsTitle — section title "Options"
  - Background panels (no idc, -1)
    - Background — main dialog background
    - RadiosInventoryBackground — radios inventory section background
    - RadioPreviewBackground — radio preview section background
    - OptionsBackground — options section background
  - Radios in Inventory controls
    - 16010 → RadiosInventoryGroup — control group for dynamically created radio inventory controls
    - 16100-16399 → Dynamic radio controls (max 12 radios, 25 IDCs per radio)
  - Radio Preview controls
    - 16020 → RadioPreviewGroup — control group for dynamically created radio preview controls
    - 16400-16699 → Dynamic radio preview controls (max 12 radios, 25 IDCs per radio)
  - Options controls
    - 15401 → FontSizeLabel — label "Font Size"
    - 15402 → FontSizeDecrease — font size decrease button (-)
    - 15403 → FontSizeIncrease — font size increase button (+)
  - Misc controls
    - 16011 → CloseButton — Close dialog button

Notes
- Access controls in scripts like this:
  - `_disp = findDisplay 16000; _ctrl = _disp displayCtrl 16010;` (gets the Radios Inventory control group)
  - `_disp = findDisplay 16000; _ctrl = _disp displayCtrl 16020;` (gets the Radio Preview control group)
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
    - 6: Number — Frequency in MHz
    - 7: String — Ear assignment ("left", "right", "center")
    - 8: Number — Volume (0.0 to 1.0)
    - 9: Boolean — Power state (true = on, false = off)

#### Radio Settings Cache
- `AcreRadioManager_radioSettings`: HashMap — Cached settings for all radios during dialog session. Map of radio class name → settings hashmap.
  - Each settings hashmap contains:
    - "ear": String — "left" or "right" - which ear the radio is on
    - "channel": Number — Current channel number
    - "volume": Number — Current volume level (0.0 to 1.0)
    - "ptt": Number — PTT key assignment (0 = none, 1-3 = PTT 1-3)

### Namespace `profileNamespace`

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