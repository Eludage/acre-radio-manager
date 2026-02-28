# Acre Radio Manager

Acre Radio Manager is a client-side Arma 3 mod that provides an one page interface for managing ACRE radio settings. It allows players to view all their radios in one place and quickly adjust settings like ear assignment, channel selection, and volume control.

## Features

### Radios in Inventory
- **Inventory Overview**: View all ACRE radios currently in your inventory
- **Radio Details**: See radio type, current channel, ear assignment, and volume at a glance
- **Quick Selection**: Click any radio to view and edit its detailed settings

### Radio Settings Management
- **PTT Assignment**: Assign radios to Push-To-Talk keys (1, 2, or 3) with smart swapping logic
- **Ear Assignment**: Switch radios between left, center, and right ear (for headsets/earpieces)
- **Channel Control**: Change radio channels quickly with visual feedback (for supported radios)
- **Volume Adjustment**: Set individual volume levels for each radio in 10% increments
- **Real-time Application**: All changes are applied immediately
- **Copy Settings**: Copy all settings from a previewed radio and apply them to a matching radio in your inventory

### Preset System
- **Save Presets**: Save your current radio configuration with a custom name
- **Load Presets**: Quickly restore saved radio configurations
- **Last Used Preset**: One-click reload of your most recently used preset (useful after game crash or reloading your kit in the ace arsenal)
- **Profile Persistence**: Presets are saved across game sessions

## Supported Radio Types

The mod provides different levels of functionality depending on the radio type:

| Radio Type | PTT Assignment | Channel Change | Ear Assignment | Volume Control | Power On/Off |
|-----------|---------------|----------------|----------------|----------------|-------------|
| AN/PRC-117F | ✓ | ✓ (direct input and +/-) | ✓ | ✓ | ✗ |
| AN/PRC-152 | ✓ | ✓ (direct input and +/-) | ✓ | ✓ | ✗ |
| AN/PRC-148 | ✓ | ✓ (+/- only) | ✓ | ✓ | ✗ |
| AN/PRC-343 | ✓ | ✓ (+/- only) | ✓ | ✓ | ✗ |
| Baofeng BF-888S | ✓ | ✓ (+/- only) | ✓ | ✓ | ✗ |
| AN/PRC-77 | ✓ | ✗ | ✓ | ✓ | ✗ |
| SEM 52 SL | ✓ | ✗ | ✓ | ✓ | ✗ |
| SEM 70 | ✓ | ✗ | ✓ | ✓ | ✗ |

**Channel display formats:**
- AN/PRC-117F and AN/PRC-152: `N: Name` — supports typing a channel number directly
- AN/PRC-148: `Gr X, Ch Y, Name` — 16 channels per group
- AN/PRC-343: `Bl X, Ch Y, Name` — 16 channels per block
- Baofeng BF-888S: `N: Name` — 16 flat channels

**Note**: Radios without channel change support will display "Radio not supported" in the channel section. All other functions remain fully operational. Please let me know if you're using radios from other mods and which mods those are so I can add them to this table.

## Display Compatibility

The UI has been optimized and tested on the following configurations:

| Aspect Ratio | Interface Size |
|---|---|
| 16:9 | Small |
| 16:9 | Normal |
| 21:9 | Small |
| 21:9 | Normal |

Other aspect ratios (e.g. 4:3, 16:10) or interface sizes (Large, Very Large) are untested and may result in overlapping or cut-off UI elements.

## Installation

1. Subscribe to the mod on Steam Workshop
2. Enable the mod in the Arma 3 Launcher
3. Ensure ACRE2 and ACE3 are also enabled
4. Launch Arma 3 and join a mission with ACRE radios

## Usage

### Opening the Radio Manager
1. Press the ACE Self-Interact key (default: Left Ctrl + Left Windows)
2. Navigate to: **ACRE** → **Manage Radio Settings**
3. The Radio Manager dialog will open

### Managing Radio Settings
1. **View Your Radios**: All radios in your inventory appear in the top section
2. **Select a Radio**: Click on any radio in the inventory list
3. **Adjust Settings**: Use the controls in the Radio Preview section:
   - **PTT Assignment**: Click buttons 1, 2, or 3 to assign the radio to a Push-To-Talk key
   - **Ear Assignment**: Change between Left/Center/Right ear
   - **Channel**: Adjust channel (for supported radios)
   - **Volume**: Use +/- buttons for 10% steps, or type a value and press Enter or click away
4. **Changes Apply Immediately**: No need to click "Save" or "Apply"

**PTT Assignment Rules**:
- You cannot remove PTT from a radio (X button is disabled)
- PTT buttons are limited by the number of radios you have (e.g., PTT 3 is disabled if you only have 2 radios)
- When assigning a radio with PTT to a new PTT, the two radios swap their PTT assignments
- When assigning a radio without PTT to a new PTT, the other radio loses its PTT

**Volume Control**:
- Volume is adjusted in 10% increments (0, 10, 20, ..., 100)
- Manual entries are automatically rounded to the nearest 10%

### Copying Settings from a Preview
This is useful when you've loaded a savestate and want to selectively apply one radio's settings to your inventory without applying the whole preset:
1. Load a preset — the Preview section shows the saved settings
2. Click the **Copy** button on the radio in the Preview whose settings you want
3. Inventory radios of the same type will become clickable as copy targets
4. Click the target inventory radio to apply the settings
5. The copy is applied immediately and copy mode is cleared automatically

**Note**: Only radios of the exact same type can be used as a copy target.

### Working with Presets
1. **Save Current Configuration**:
   - Click "+" button to create new preset
   - Enter a name for your preset
   - Click "Save preset" to store the configuration
2. **Load Saved Configuration**:
   - Click "Load preset" button
   - Select your desired preset from the list
   - Radio settings will be applied automatically

## How It Works

### Radio Detection
The mod automatically detects all ACRE radios in your inventory:
- Handheld radios (AN/PRC-343, AN/PRC-152, etc.)
- Backpack radios (AN/PRC-117F, AN/PRC-77, etc.)

### Settings Scope
All settings are **personal to you** and don't affect other players:
- Your ear assignment is your choice
- Your volume levels are independent
- Your presets are saved to your profile

### Preset Matching
When loading a preset:
- The mod matches radios by **type** (not by specific instance)
- The preset can only be applied if your current inventory has **exactly the same radio types and counts** as when the preset was saved — partial or mismatched loads are rejected with an error message

## Dependencies

### Required
- **ACRE2** - Advanced Combat Radio Environment 2
- **ACE3** - Advanced Combat Environment 3 (for Self-Interact menu)
- **CBA_A3** - Community Base Addons A3

All dependencies are available on Steam Workshop.

## Documentation

The repository includes several developer-facing documents in the `doc/` folder:

- `DEVELOPMENT_HELP.md` — developer reference (control ID reference, namespaces, and variables)
- `ARCHITECTURE.md` — architecture overview (function organization, data flow patterns, design decisions)

## Known Limitations

- **Maximum 12 radios**: The UI displays a maximum of 12 radios at once. If you carry more than 12 radios, only the first 12 will be shown in the manager
- **Power state is read-only**: The ON/OFF indicator in the inventory is display-only and cannot be toggled. The ACRE2 API does not currently expose a way to change radio power state programmatically. Power state is also not stored in presets — all radios are assumed to be on when a preset is applied
- **No undo**: Setting changes cannot be undone (but presets can be reloaded)
- **Preset compatibility**: Presets work best when you have the same radios as when the preset was saved

## Compatibility

### ACRE2
Fully compatible with ACRE2. Uses the public ACRE API for all radio interactions.

### ACE3
Integrates with ACE3 Self-Interact menu for easy access.

### Other Radio Mods
This mod is specifically designed for ACRE2 and does not support other radio systems (TFAR, etc.).

## Special Thanks

- The Arma 3 modding community
- ACRE2 team for the excellent radio system
- ACE3 team for the Self-Interact framework
- [Sigma Security Group](https://disboard.org/de/server/288446755219963914) (we're always looking for new members)

## Credits

- **Author**: Eludage

## Feedback and Issues

Found a bug or have a suggestion? Please report it on the GitHub repository (link coming soon) or in the Steam Workshop comments.