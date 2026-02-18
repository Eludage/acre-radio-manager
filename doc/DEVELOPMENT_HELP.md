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
  - Radio Preview controls
    - 16020 → RadioPreviewGroup — control group for dynamically created radio preview controls
    - 16400-16699 → Dynamic radio preview controls (max 12 radios, 25 IDCs per radio)
  - Radio Preview Options controls
    - 16030 → RadioPreviewOptionsGroup — control group for preset/savestate list
    - 16031 → AddSavestateButton — save current radio settings as preset
    - 16032 → RemoveSavestateButton — delete selected preset
  - Misc controls
    - 16011 → CloseButton — Close dialog button

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
    - 6: Number — Frequency in MHz
    - 7: String — Ear assignment ("left", "right", "center")
    - 8: Number — Volume (0.0 to 1.0)
    - 9: Boolean — Power state (true = on, false = off)
- `AcreRadioManager_currentSavestateNames`: Array — List of all savestate names in current session. Always has "Last Presets" at index 0.
- `AcreRadioManager_selectedSavestateIndex`: Number — Index of currently selected savestate for removal. -1 when no selection.

#### Radio Settings Cache
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
  - Each radio settings array contains: [ptt, channel, ear, volume]
    - ptt: Number — PTT assignment (0 = none, 1-3 = PTT keys)
    - channel: Number — Channel number
    - ear: String — "left", "right", or "center"
    - volume: Number — Volume level (0.0 to 1.0)
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