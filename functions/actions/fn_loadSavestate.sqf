/*
 * Author: Eludage
 * Loads a savestate into the Radio Preview area.
 * Builds preview rows directly from the savestate data using config lookups for
 * icon/name and preset data for channel names — independent of the current inventory.
 * Does NOT apply settings to actual radios.
 * The Apply button (fn_applySavestate) enforces that count and types match the
 * current inventory before settings are written to ACRE.
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

if (count _savestateData == 0) exitWith {
	["Savestate is empty."] call AcreRadioManager_fnc_showHint;
	false
};

// Build preview radio data directly from savestate entries.
// Savestate entry format: [ptt, channel, ear, volume, baseClass]
// Preview row format:     [radioId, icon, displayName, ptt, channel, channelName, ear, volume, isOn, baseClass]
// The baseClass at index 9 signals fn_updateRadioPreview that no live radio ID is available.
private _previewRadios = [];
{
	private _radioSettings = _x;
	private _radioIndex = _forEachIndex;

	if (count _radioSettings < 5) exitWith {
		diag_log format ["ERROR: fn_loadSavestate - entry %1 missing baseClass", _radioIndex];
	};

	private _ptt       = _radioSettings select 0;
	private _channel   = _radioSettings select 1;
	private _ear       = _radioSettings select 2;
	private _volume    = _radioSettings select 3;
	private _baseClass = _radioSettings select 4;

	// Synthetic ID — never passed to ACRE; preview reads baseClass from index 9
	private _radioId = format ["AcreRadioManager_savestate_%1", _radioIndex];

	// Look up icon and display name from config
	private _icon = getText (configFile >> "CfgWeapons" >> _baseClass >> "picture");
	private _displayName = getText (configFile >> "CfgWeapons" >> _baseClass >> "displayName");
	if (_displayName == "") then { _displayName = _baseClass; };

	// Resolve channel name via preset data (no live radio ID needed)
	private _channelName = format ["Channel %1", _channel];
	private _isChannelRadio = (_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0);
	if (_isChannelRadio) then {
		private _preset = [_baseClass] call acre_api_fnc_getPreset;
		private _fieldValue = [_baseClass, _preset, _channel, "label"] call acre_api_fnc_getPresetChannelField;
		if (!isNil "_fieldValue" && { typeName _fieldValue == "STRING" } && { _fieldValue != "" }) then {
			_channelName = _fieldValue;
		};
	};

	private _previewRow = [_radioId, _icon, _displayName, _ptt, _channel, _channelName, _ear, _volume, true, _baseClass];
	_previewRadios pushBack _previewRow;

} forEach _savestateData;

// Store preview state - mark as NOT live so inventory changes no longer overwrite it
uiNamespace setVariable ["AcreRadioManager_previewIsLive", false];
uiNamespace setVariable ["AcreRadioManager_previewRadios", _previewRadios];

private _display = findDisplay 16000;
if (!isNull _display) then {
	[] call AcreRadioManager_fnc_updateRadioPreview;
};

[format ["Loaded savestate into preview: %1", _savestateName]] call AcreRadioManager_fnc_showHint;

true
