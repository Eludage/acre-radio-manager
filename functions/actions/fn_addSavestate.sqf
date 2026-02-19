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

// Store current inventory as initial savestate data
private _currentRadios = uiNamespace getVariable ["AcreRadioManager_currentRadios", []];
private _savestateData = [];
if (!(_currentRadios isEqualTo "")) then {
	{
		private _radioData = _x;
		_savestateData pushBack [
			_radioData select 3, // ptt
			_radioData select 4, // channel
			_radioData select 7, // ear
			_radioData select 8  // volume
		];
	} forEach _currentRadios;
};

// Create savestate with current inventory data
_savestates set [_newName, _savestateData];

// Save to profileNamespace
profileNamespace setVariable ["AcreRadioManager_savestates", _savestates];

// Refresh the savestate list
[] call AcreRadioManager_fnc_updateSavestateList;

true
