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
    - 16010 → RadiosInventoryList — listbox displaying all ACRE radios in player's inventory
  - Radio Preview controls
    - 16020 → RadioPreviewList — listbox displaying detailed settings for selected radio
  - Options controls
    - 15401 → FontSizeLabel — label "Font Size"
    - 15402 → FontSizeDecrease — font size decrease button (-)
    - 15403 → FontSizeIncrease — font size increase button (+)
  - Misc controls
    - 16011 → CloseButton — Close dialog button

Notes
- Access controls in scripts like this:
  - `_disp = findDisplay 16000; _ctrl = _disp displayCtrl 16010;` (gets the Radios Inventory listbox)
  - Then operate on the control: `_ctrl lbAdd "AN/PRC-343";` or `_ctrl ctrlSetText "...";`
- Only controls with idc >= 0 can be accessed via `displayCtrl`.
- Controls with idc = -1 are decorative elements (titles, backgrounds) and cannot be accessed directly.

## Namespaces and Variables Used

This section documents the runtime namespaces and variables used by Acre Radio Manager.

### Namespace `missionNamespace`

Since this is a client-side only mod for managing personal radio settings, most state will be local. However, some variables may be stored in missionNamespace for persistence across dialog opens/closes.

#### Radio State (Planned)
- `AcreRadioManager_lastRadioSettings`: HashMap — Cached radio settings from last dialog session. Used to restore settings when reopening dialog.
- `AcreRadioManager_currentRadios`: Array — Array of radio class names currently in player's inventory.

### Namespace `uiNamespace`

#### UI State
- `AcreRadioManager_fontSizeLevel`: Number — Current font size level for UI elements. Range: 0-4, where 2 is default size.
- `AcreRadioManager_selectedRadioIdx`: Number — Index of currently selected radio in the inventory listbox. -1 when no selection.
- `AcreRadioManager_selectedRadio`: String — Class name of currently selected radio. Empty string when no selection.

#### Radio Settings Cache
- `AcreRadioManager_radioSettings`: HashMap — Cached settings for all radios. Map of radio class name → settings hashmap.
  - Each settings hashmap contains:
    - "ear": String — "left" or "right" - which ear the radio is on
    - "channel": Number — Current channel number
    - "volume": Number — Current volume level (0.0 to 1.0)

### Namespace `profileNamespace`

#### Presets
- `AcreRadioManager_presets`: HashMap — Saved radio presets. Map of preset name → preset data.
  - Each preset contains an array of radio configurations
- `AcreRadioManager_lastPreset`: String — Name of the last used preset. Used for quick reload.

## Notes
- **uiNamespace** is used for state that persists during the dialog session (UI preferences, cached radio data).
- **missionNamespace** is used for state that should persist across dialog sessions (last known radio settings).
- **profileNamespace** is used for persistent state across game sessions (saved presets).
- All mod runtime variables use the `AcreRadioManager_` prefix.