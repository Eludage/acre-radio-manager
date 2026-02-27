/*
 * Author: Eludage
 * Saves the current radio inventory to "Last Presets" and flushes all pending
 * savestate changes to disk via saveProfileNamespace.
 * Called automatically when the dialog closes.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_savePresets;
 */

// Get current radio list from uiNamespace
private _radios = uiNamespace getVariable ["AcreRadioManager_currentRadios", []];
if (count _radios == 0) exitWith {
	true // No radios, but not an error
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

// Save to "Last Presets"
_savestates set ["Last Presets", _savestateData];

// Save to profileNamespace
profileNamespace setVariable ["AcreRadioManager_savestates", _savestates];
saveProfileNamespace;

true
