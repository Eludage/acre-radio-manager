/*
 * Author: Eludage
 * Loads a savestate and applies the settings to the player's radios.
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
	hint format ["Savestate '%1' not found", _savestateName];
	false
};

// Get savestate data
private _savestateData = _savestates get _savestateName;
if (isNil "_savestateData" || typeName _savestateData != "ARRAY") exitWith {
	diag_log format ["ERROR: Invalid savestate data for '%1'", _savestateName];
	false
};

// Get current radios
private _radios = [] call acre_api_fnc_getCurrentRadioList;
if (count _radios == 0) exitWith {
	hint "No radios in inventory";
	false
};

// Apply savestate to radios (match by index)
{
	private _radioSettings = _x;
	private _radioIndex = _forEachIndex;
	
	// Check if we have a corresponding radio in inventory
	if (_radioIndex < count _radios) then {
		private _radioId = _radios select _radioIndex;
		
		// Extract settings from savestate
		// Format: [ptt, channel, ear, volume]
		if (count _radioSettings >= 4) then {
			private _ptt = _radioSettings select 0;
			private _channel = _radioSettings select 1;
			private _ear = _radioSettings select 2;
			private _volume = _radioSettings select 3;
			
			// Apply PTT (handled separately via multi-PTT API)
			// Apply channel (only for supported radios)
			private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;
			private _isRadioSupported = (_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0);
			if (_isRadioSupported && _channel > 0) then {
				[_radioId, _channel] call acre_api_fnc_setRadioChannel;
			};
			
			// Apply ear
			if (_ear != "") then {
				[_radioId, toUpper _ear] call acre_api_fnc_setRadioSpatial;
			};
			
			// Apply volume
			if (_volume >= 0 && _volume <= 1) then {
				[_radioId, _volume] call acre_api_fnc_setRadioVolume;
			};
		};
	};
} forEach _savestateData;

// Apply PTT assignments from savestate
// Build PTT array from savestate data
private _pttAssignments = ["", "", ""];
{
	private _radioSettings = _x;
	private _radioIndex = _forEachIndex;
	
	if (_radioIndex < count _radios && count _radioSettings >= 1) then {
		private _ptt = _radioSettings select 0;
		private _radioId = _radios select _radioIndex;
		
		if (_ptt >= 1 && _ptt <= 3) then {
			private _pttIndex = _ptt - 1;
			_pttAssignments set [_pttIndex, _radioId];
		};
	};
} forEach _savestateData;

// Apply PTT assignments
[_pttAssignments] call acre_api_fnc_setMultiPushToTalkAssignment;

// Refresh radio list and UI
[] call AcreRadioManager_fnc_getRadioList;

private _display = findDisplay 16000;
if (!isNull _display) then {
	[] call AcreRadioManager_fnc_updateRadioInventory;
	[] call AcreRadioManager_fnc_updateRadioPreview;
};

hint format ["Loaded savestate: %1", _savestateName];

true
