/*
 * Author: Eludage
 * Adds a new savestate entry.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_addSavestate;
 */

// Get current savestates from profileNamespace
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];

// Check if savestate limit reached (20 max)
if (count _savestates >= 20) exitWith {
	hint "Savestate limit reached! Maximum 20 savestates allowed.";
	false
};

// Find a unique name for the new savestate
private _newName = "New Savestate";
private _counter = 1;
while {_newName in _savestates} do {
	_counter = _counter + 1;
	_newName = format ["New Savestate %1", _counter];
};

// Create empty savestate
_savestates set [_newName, []];

// Save to profileNamespace
profileNamespace setVariable ["AcreRadioManager_savestates", _savestates];

// Refresh the savestate list
[] call AcreRadioManager_fnc_updateSavestateList;

true
