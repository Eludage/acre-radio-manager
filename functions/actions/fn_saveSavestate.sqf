/*
 * Author: Eludage
 * Saves the current radio settings to a savestate.
 * Cannot save to "Last Presets".
 *
 * Arguments:
 * 0: _savestateName <STRING> - Name of the savestate to save to
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * ["My Preset"] call AcreRadioManager_fnc_saveSavestate;
 */

params ["_savestateName"];

if (isNil "_savestateName" || _savestateName == "") exitWith {
	diag_log "ERROR: Invalid savestate name";
	false
};

// Cannot save to "Last Presets"
if (_savestateName == "Last Presets") exitWith {
	["Cannot save to 'Last Presets'"] call AcreRadioManager_fnc_showHint;
	false
};

// Get current radio list from uiNamespace
private _radios = uiNamespace getVariable ["AcreRadioManager_currentRadios", []];
if (_radios isEqualTo "") exitWith {
	["No radios in inventory"] call AcreRadioManager_fnc_showHint;
	false
};

// Build savestate data array
private _savestateData = [];

{
	private _radioData = _x;
	
	// Extract settings: [ptt, channel, ear, volume, baseClass]
	private _radioId = _radioData select 0;
	private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;
	private _ptt = _radioData select 3;
	private _channel = _radioData select 4;
	private _ear = _radioData select 6;
	private _volume = _radioData select 7;
	
	private _radioSettings = [_ptt, _channel, _ear, _volume, _baseClass];
	_savestateData pushBack _radioSettings;
	
} forEach _radios;

// Get savestates from profileNamespace
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];

// Save the data
_savestates set [_savestateName, _savestateData];

// Save to profileNamespace
profileNamespace setVariable ["AcreRadioManager_savestates", _savestates];

[format ["Saved to savestate: %1", _savestateName]] call AcreRadioManager_fnc_showHint;

true
