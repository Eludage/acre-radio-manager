/*
 * Author: Eludage
 * Loads a savestate into the Radio Preview area.
 * Does NOT apply settings to actual radios - only updates the preview display.
 *
 * Arguments:
 * 0: _savestateName <STRING> - Name of the savestate to load
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * ["Last Presets"] call AcreRadioManager_fnc_loadSavestate;
 */

params ["_savestateName"];

if (isNil "_savestateName" || _savestateName == "") exitWith {
	diag_log "ERROR: Invalid savestate name";
	false
};

// Get savestates from profileNamespace
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];

// Check if savestate exists
if (!(_savestateName in _savestates)) exitWith {
	[format ["Savestate '%1' not found", _savestateName]] call AcreRadioManager_fnc_showHint;
	false
};

// Get savestate data
private _savestateData = _savestates get _savestateName;
if (isNil "_savestateData" || typeName _savestateData != "ARRAY") exitWith {
	diag_log format ["ERROR: Invalid savestate data for '%1'", _savestateName];
	false
};

// Get current inventory radios as the data source for icon, name, ID etc.
private _currentRadios = uiNamespace getVariable ["AcreRadioManager_currentRadios", []];
if (_currentRadios isEqualTo "" || count _currentRadios == 0) exitWith {
	["No radios in inventory"] call AcreRadioManager_fnc_showHint;
	false
};

// Build preview radio data by overlaying savestate settings onto current inventory
private _previewRadios = [];
{
	private _radioData = +_x; // deep copy to avoid modifying currentRadios
	private _radioIndex = _forEachIndex;

	if (_radioIndex < count _savestateData) then {
		private _radioSettings = _savestateData select _radioIndex;

		// Format: [ptt, channel, ear, volume]
		if (count _radioSettings >= 4) then {
			private _ptt = _radioSettings select 0;
			private _channel = _radioSettings select 1;
			private _ear = _radioSettings select 2;
			private _volume = _radioSettings select 3;

			_radioData set [3, _ptt];
			_radioData set [4, _channel];

			// Resolve channel name via helper
			private _radioId = _radioData select 0;
			private _channelName = [_radioId, _channel] call AcreRadioManager_fnc_getChannelName;

			_radioData set [5, _channelName];
			_radioData set [7, _ear];
			_radioData set [8, _volume];
		};
	};

	_previewRadios pushBack _radioData;
} forEach _currentRadios;

// Store preview state and refresh only the preview UI - inventory is unchanged
uiNamespace setVariable ["AcreRadioManager_previewRadios", _previewRadios];

private _display = findDisplay 16000;
if (!isNull _display) then {
	[] call AcreRadioManager_fnc_updateRadioPreview;
};

[format ["Loaded savestate into preview: %1", _savestateName]] call AcreRadioManager_fnc_showHint;

true
