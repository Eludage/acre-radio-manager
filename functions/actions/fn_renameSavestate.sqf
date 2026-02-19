/*
 * Author: Eludage
 * Renames a savestate.
 * Cannot rename "Last Presets".
 *
 * Arguments:
 * 0: _oldName <STRING> - Current name of the savestate
 * 1: _newName <STRING> - New name for the savestate
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * ["Old Name", "New Name"] call AcreRadioManager_fnc_renameSavestate;
 */

params ["_oldName", "_newName"];

if (isNil "_oldName" || _oldName == "" || isNil "_newName" || _newName == "") exitWith {
	diag_log "ERROR: Invalid savestate names";
	false
};

// Cannot rename "Last Presets"
if (_oldName == "Last Presets") exitWith {
	["Cannot rename 'Last Presets'"] call AcreRadioManager_fnc_showHint;
	[] call AcreRadioManager_fnc_updateSavestateList; // Revert UI
	false
};

// Get savestates from profileNamespace
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];

// Check if old name exists
if (!(_oldName in _savestates)) exitWith {
	diag_log format ["ERROR: Savestate '%1' not found", _oldName];
	false
};

// Check if new name already exists
if (_newName in _savestates && _newName != _oldName) exitWith {
	[format ["Savestate '%1' already exists", _newName]] call AcreRadioManager_fnc_showHint;
	[] call AcreRadioManager_fnc_updateSavestateList; // Revert UI
	false
};

// Get the data and rename
private _data = _savestates get _oldName;
_savestates deleteAt _oldName;
_savestates set [_newName, _data];

// Save to profileNamespace
profileNamespace setVariable ["AcreRadioManager_savestates", _savestates];

// Refresh the savestate list
[] call AcreRadioManager_fnc_updateSavestateList;

true
