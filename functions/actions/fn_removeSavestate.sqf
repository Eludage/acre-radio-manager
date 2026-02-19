/*
 * Author: Eludage
 * Removes the currently selected savestate entry.
 * Cannot remove "Last Presets".
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_removeSavestate;
 */

// Get currently selected savestate index
private _selectedIndex = uiNamespace getVariable ["AcreRadioManager_selectedSavestateIndex", -1];
if (_selectedIndex < 0) exitWith {
	hint "No savestate selected";
	false
};

// Get savestate names
private _savestateNames = uiNamespace getVariable ["AcreRadioManager_currentSavestateNames", []];
if (_selectedIndex >= count _savestateNames) exitWith {
	diag_log "ERROR: Invalid savestate index";
	false
};

private _savestateName = _savestateNames select _selectedIndex;

// Cannot remove "Last Presets"
if (_savestateName == "Last Presets") exitWith {
	hint "Cannot remove 'Last Presets'";
	false
};

// Get savestates from profileNamespace
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];

// Remove the savestate
_savestates deleteAt _savestateName;

// Save to profileNamespace
profileNamespace setVariable ["AcreRadioManager_savestates", _savestates];

// Clear selection
uiNamespace setVariable ["AcreRadioManager_selectedSavestateIndex", -1];

// Refresh the savestate list
[] call AcreRadioManager_fnc_updateSavestateList;

true
