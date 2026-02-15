# Acre Radio Manager

Acre Radio Manager is a client-side Arma 3 mod that provides an intuitive interface for managing ACRE radio settings. It allows players to view all their radios in one place and quickly adjust settings like ear assignment, channel selection, and volume control.

## Features

### Radios in Inventory
- **Inventory Overview**: View all ACRE radios currently in your inventory
- **Radio Details**: See radio type, current channel, ear assignment, and volume at a glance
- **Quick Selection**: Click any radio to view and edit its detailed settings

### Radio Settings Management
- **Ear Assignment**: Switch radios between left and right ear (for headsets/earpieces)
- **Channel Control**: Change radio channels quickly with visual feedback
- **Volume Adjustment**: Set individual volume levels for each radio
- **Real-time Application**: All changes are applied immediately

### Preset System
- **Save Presets**: Save your current radio configuration with a custom name
- **Load Presets**: Quickly restore saved radio configurations
- **Last Used Preset**: One-click reload of your most recently used preset
- **Profile Persistence**: Presets are saved across game sessions

### User Interface
- **Clean Layout**: Organized sections for inventory, settings, and options
- **Adjustable Font Size**: Increase or decrease UI text size for better readability (5 levels)
- **Intuitive Controls**: Direct access to all radio settings without complex menus

## Installation

1. Subscribe to the mod on Steam Workshop (coming soon)
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
   - Change ear assignment (Left/Right buttons)
   - Adjust channel (channel selector)
   - Modify volume (volume slider)
4. **Changes Apply Immediately**: No need to click "Save" or "Apply"

### Working with Presets
1. **Save Current Configuration**:
   - Click "+" button to create new preset
   - Enter a name for your preset
   - Click "Save preset" to store the configuration
2. **Load Saved Configuration**:
   - Click "Load preset" button
   - Select your desired preset from the list
   - Radio settings will be applied automatically

### Adjusting UI
- Use **-** and **+** buttons in the Options section to decrease/increase font size
- Font size setting is saved across sessions

## How It Works

### Radio Detection
The mod automatically detects all ACRE radios in your inventory:
- Handheld radios (AN/PRC-343, AN/PRC-152, etc.)
- Backpack radios (AN/PRC-117F, AN/PRC-77, etc.)
- Vehicle radios (when you're the radio operator)

### Settings Scope
All settings are **personal to you** and don't affect other players:
- Your ear assignment is your choice
- Your volume levels are independent
- Your presets are saved to your profile

### Preset Matching
When loading a preset:
- The mod matches radios by **type** (not by specific instance)
- If you have multiple radios of the same type, settings apply to the first one
- If a preset includes a radio type you don't have, that entry is skipped

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

## Building the Mod

Build the mod using Arma 3 Tools (Addon Builder) or compatible PBO packing tools.

## Known Limitations

- **Client-side only**: Settings are not saved server-side and reset on mission restart
- **ACRE dependency**: Requires ACRE2 to be loaded and functional
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