# Acre Radio Manager Architecture

This document describes the architectural patterns and design decisions of the Acre Radio Manager mod.

## Overview

Acre Radio Manager is a client-side Arma 3 mod that allows players to manage their ACRE radio settings through an intuitive interface. The mod provides a centralized location to view all radios in inventory and adjust settings like ear assignment, channel selection, and volume control.

## Core Architectural Principles

### 1. Client-Side Only
- **No server-side code required** - Uses only vanilla Arma 3 and ACRE API functionality
- **Personal settings** - Each player manages their own radio settings independently
- **ACRE integration** - Interfaces with ACRE's radio system through their public API

### 2. Single Player Focus
- **No synchronization needed** - Radio settings are personal to each player
- **Local state only** - All state is stored in local namespaces
- **ACE integration** - Menu accessible through ACE Self-Interact menu

### 3. Namespace Usage

#### `uiNamespace` (Dialog State)
Used for state that is ephemeral and tied to the dialog session (persists until game restart):
- **Radio Settings Cache**: Temporary cache of radio settings being edited
- **Current Radios**: List of radios in player's inventory (queried fresh from ACRE each dialog open)

#### `profileNamespace` (Persistent State)
Used for state that persists across game sessions and survives crashes:
- **Presets**: Saved radio configurations
- **Last Preset**: Name of most recently used preset
- **Last Radio Settings**: Cached settings from last session for crash recovery

## Function Architecture

### Function Categories

#### 1. Core Functions (`functions/core/`)
- **Entry Points**: Dialog opening, initialization
- **Registration**: ACE interaction menu registration
- **Currently**: 1 function (fn_openRadioSettings)

#### 2. Action Functions (`functions/actions/*/`)
- **UI Event Handlers**: Respond to button clicks and user interactions
- **Radio Control**: Apply settings to ACRE radios
- **Preset Management**: Load/save preset configurations
- **Pattern**: Get user input → validate → call ACRE API → update UI
- **To be organized** into subfolders by UI section

#### 3. UI Functions (`functions/ui/`)
- **UI Updates**: Read state from ACRE and update controls
- **List Population**: Populate listboxes with radios and settings
- **UI Refresh**: Update UI elements based on current state
- **Font Size**: Adjust UI font sizes dynamically

#### 4. Data Functions (`functions/data/`)
- **Presets**: Load and save radio preset configurations
- **Settings Cache**: Cache and retrieve radio settings
- **ACRE Interface**: Query ACRE API for radio information

#### 5. Utility Functions (`functions/utilities/`)
- **Helper Functions**: Formatting and validation
- **ACRE Helpers**: Convenience wrappers for ACRE API calls

## Data Flow Patterns

### Pattern 1: User Changes Radio Setting

```
1. User changes setting in UI (e.g., switches ear)
   ↓
2. Action function (e.g., fn_changeRadioEar.sqf)
   - Validates input
   - Calls ACRE API to apply change
   ↓
3. ACRE API applies setting
   ↓
4. UI update function
   - Refreshes display to show current state
```

### Pattern 2: Load Radio Preset

```
1. User clicks "Load Preset"
   ↓
2. Action function (fn_loadPreset.sqf)
   - Retrieves preset from profileNamespace
   - Validates preset data
   ↓
3. For each radio in preset:
   - Match radio in inventory by type
   - Call ACRE API to apply settings
   ↓
4. UI update
   - Refresh entire display to show new settings
```

### Pattern 3: Dialog Initialization

```
1. User opens dialog via ACE menu
   ↓
2. Core function (fn_openRadioSettings.sqf)
   - Creates dialog
   - Initializes UI state
   ↓
3. UI population function
   - Query ACRE for radios in inventory
   - Populate radios inventory listbox
   - Load last radio settings from profileNamespace (if available)
   ↓
4. Display ready for user interaction
```

## Radio Settings Management

### Radio Detection
The mod uses ACRE's API to detect radios in the player's inventory:
```sqf
private _radios = [] call acre_api_fnc_getCurrentRadioList;
```

### Settings Per Radio
For each radio, the mod manages:
- **Ear Assignment**: Left or right ear (for headsets/earpieces)
- **Channel**: Current channel number (1-N depending on radio type)
- **Volume**: Volume level (0.0 to 1.0)

### ACRE API Integration
The mod interacts with ACRE through their public API:
- `acre_api_fnc_getCurrentRadioList` - Get radios in inventory
- `acre_api_fnc_getRadioChannel` - Get current channel
- `acre_api_fnc_setRadioChannel` - Set channel
- Additional ACRE API functions for ear and volume control

## UI Organization

### Three Main Sections

#### 1. Radios in Inventory (Top)
- Displays all ACRE radios currently in player's inventory
- Shows radio icon, type name, and current settings summary
- User selects a radio to view/edit details

#### 2. Radio Preview (Middle)
- Shows detailed settings for selected radio
- Provides controls for changing:
  - Ear assignment (Left/Right buttons)
  - Channel (dropdown or +/- buttons)
  - Volume (slider or dropdown)
- Settings are applied immediately when changed

#### 3. Options (Bottom)
- Preset management buttons (Load, Save, New)
- Font size adjustment (+/-)
- Close button

## Key Design Decisions

### 1. Immediate Application
Settings are applied immediately when changed, not on "Save":
- **No confirmation needed** - Changes take effect instantly
- **Real-time feedback** - Player hears volume changes immediately
- **No lost changes** - No risk of forgetting to save

### 2. Preset System
Presets save radio configurations for quick recall:
- **Named presets** - User assigns meaningful names
- **Profile persistence** - Saved across game sessions
- **Last preset quick reload** - One-click restore of last used preset

### 3. Row-Based Radio Display
Each radio in inventory gets a full row with:
- Radio icon/image
- Radio type name (e.g., "AN/PRC-343")
- Current channel display
- Current ear indicator
- Direct controls (PTT, channel buttons, etc.)

### 4. Font Size Flexibility
Adjustable font size for accessibility:
```sqf
private _fontSizeLevel = uiNamespace getVariable ["AcreRadioManager_fontSizeLevel", 2]; // 0-4, default 2
```

## Error Handling

### Validation Strategy
- **Early exits**: Functions use `exitWith` to return false on invalid input
- **Null checks**: Always check if display/controls exist before accessing
- **ACRE availability**: Verify ACRE is loaded before API calls

### Common Validations
```sqf
// Dialog exists
private _display = findDisplay 16000;
if (isNull _display) exitWith { false };

// ACRE is loaded
if (isNil "acre_api_fnc_getCurrentRadioList") exitWith { false };

// Radio is valid
private _radio = uiNamespace getVariable ["AcreRadioManager_selectedRadio", ""];
if (_radio == "") exitWith { false };
```

## Performance Considerations

### Update Frequency
- **On-demand updates**: UI only updates when settings change
- **No polling**: Don't continuously check ACRE state
- **Efficient refreshes**: Only update affected controls

### Memory Management
- **Cached data**: Radio info cached in uiNamespace HashMaps
- **Clear on close**: Dialog state cleared when closing
- **Preset limits**: Reasonable limits on stored presets

## Dependencies

### Required Mods
- **ACRE2** - Main radio system
- **ACE3** - Self-interact menu integration
- **CBA_A3** - Common framework

### ACRE Version Compatibility
The mod should gracefully handle different ACRE versions:
- Check for API function existence before calling
- Fall back to basic functionality if advanced features unavailable

## Future Considerations

### Planned Features
1. **Multi-radio quick settings** - Apply settings to multiple radios at once
2. **Favorite channels** - Mark frequently used channels
3. **Radio group presets** - Different presets for different radio types
4. **Visual indicators** - Show which radio is actively transmitting

### Known Limitations
1. **Client-side only** - Cannot save settings server-side
2. **ACRE dependency** - Requires ACRE to be functional
3. **No history** - Cannot undo setting changes
4. **Preset compatibility** - Presets may not work if radio inventory changes

## Summary

Acre Radio Manager follows a simple **action → API → UI update** pattern:
- User actions trigger ACRE API calls
- ACRE handles the radio system changes
- UI updates to reflect new state

This architecture ensures:
- **Simplicity**: Minimal state management required
- **Reliability**: ACRE handles the complex radio logic
- **Maintainability**: Clear separation between UI and radio control
- **Extensibility**: Easy to add new features following established patterns