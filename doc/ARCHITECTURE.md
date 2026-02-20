# Acre Radio Manager Architecture

This document describes the architectural patterns and design decisions of the Acre Radio Manager mod.

## Overview

Acre Radio Manager is a client-side Arma 3 mod that allows players to manage their ACRE radio settings through a single interface. The mod provides a centralized location to view all radios in inventory and adjust settings like ear assignment, channel selection, and volume control.

## Core Architectural Principles

### 1. Client-Side Only
- **No server-side code required** - Uses only vanilla Arma 3 and ACRE API functionality
- **Personal settings** - Each player manages their own radio settings independently
- **ACRE integration** - Interfaces with ACRE's radio system through their public API

### 2. Namespace Usage

#### `uiNamespace` (Dialog State)
Used for state that is ephemeral and tied to the dialog session (persists until game restart):
- **Current Radios**: Live inventory radio data, queried fresh from ACRE on each dialog open (`AcreRadioManager_currentRadios`)
- **Preview Radios**: Radio data shown in the Preview section — mirrors inventory normally, diverges when a savestate is loaded (`AcreRadioManager_previewRadios`)
- **Dialog Session State**: Copy mode source, preview-live flag, IDC→radioId map, hint counter, etc.
- **Channel Count Cache**: Per-radio-type max channel count to avoid repeated config lookups (`AcreRadioManager_channelCountCache`)

#### `profileNamespace` (Persistent State)
Used for state that persists across game sessions and survives crashes:
- **Savestates**: All saved radio configurations, stored as a HashMap keyed by name (`AcreRadioManager_savestates`). Includes the auto-saved "Last Presets" entry.

## Function Architecture

### Function Categories

#### 1. Core Functions (`functions/core/`)
- **Entry Points**: Dialog opening, initialization
- **Currently**: 1 function (`fn_openRadioSettings`)
- **Note**: ACE Self-Interact menu registration is handled declaratively in `config.cpp` (CfgVehicles), not through a function

#### 2. Action Functions (`functions/actions/`)
- **UI Event Handlers**: Respond to button clicks and user interactions
- **Radio Control**: Apply settings to ACRE radios
- **Preset Management**: Load/save/apply/rename/remove savestate configurations
- **Copy Settings**: Copy preview radio settings onto a matching inventory radio
- **Pattern**: Get user input → validate → call ACRE API → update UI

#### 3. UI Functions (`functions/ui/`)
- **UI Updates**: Read state from `uiNamespace` and rebuild controls
- **List Population**: Populate inventory panel, preview panel and savestate list
- **UI Refresh**: Update UI elements based on current state

#### 4. Data Functions (`functions/data/`)
- **ACRE Interface**: Query ACRE API for all radios and their current settings, cache result in `uiNamespace`
- Currently one function: `fn_getRadioList`

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

### Pattern 2: Load Radio Savestate

```
1. User clicks "Load" on a savestate
   ↓
2. Action function (fn_loadSavestate.sqf)
   - Retrieves savestate from profileNamespace
   - Validates savestate data
   ↓
3. Preview area is overlaid with savestate settings
   - Actual ACRE radios and inventory are NOT modified
   ↓
4. UI update
   - Refresh preview panel to show loaded settings
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
   - Query ACRE for radios in inventory (`fn_getRadioList`)
   - Initialise `previewRadios` to match current inventory
   - Populate inventory panel, preview panel, and savestate list
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
- **PTT Assignment**: Which PTT key (1–3) or none (0) triggers this radio
- **Ear Assignment**: Left, right, or center (bilateral) audio output
- **Channel**: Current channel number (1–N depending on radio type); supports direct text input for PRC-117F and PRC-152
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
  - Ear assignment (Left/Center/Right buttons)
  - Channel (edit field with direct number input for supported radios, +/- buttons)
  - Volume (edit field + +/- buttons)
- Settings are applied immediately when changed

#### 3. Options (Bottom)
- Preset management buttons (Load, Apply, Save, New, Rename, Delete)
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

### Known Limitations
1. **No history** - Cannot undo setting changes