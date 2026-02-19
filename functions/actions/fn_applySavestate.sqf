/*
 * Author: Eludage
 * Applies a saved savestate to the actual ACRE radios in the player's inventory.
 * Matches radios by base class type (order-independent). Only succeeds if
 * the count and types of radios in the savestate match the current inventory exactly.
 *
 * Arguments:
 * 0: _savestateName <STRING> - Name of the savestate to apply
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * ["My Preset"] call AcreRadioManager_fnc_applySavestate;
 */

params ["_savestateName"];

if (isNil "_savestateName" || _savestateName == "") exitWith {
	diag_log "ERROR: Invalid savestate name";
	false
};

// Get savestate data
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];
if !(_savestateName in _savestates) exitWith {
	[format ["Savestate '%1' not found.", _savestateName]] call AcreRadioManager_fnc_showHint;
	false
};

private _savestateData = _savestates get _savestateName;
if (_savestateData isEqualTo [] || isNil "_savestateData") exitWith {
	[format ["Savestate '%1' is empty.", _savestateName]] call AcreRadioManager_fnc_showHint;
	false
};

// Get current inventory radio IDs from ACRE
if (isNil "acre_api_fnc_getCurrentRadioList") exitWith {
	["ACRE not loaded."] call AcreRadioManager_fnc_showHint;
	false
};

private _inventoryRadioIds = [] call acre_api_fnc_getCurrentRadioList;
if (count _inventoryRadioIds == 0) exitWith {
	["No radios in inventory."] call AcreRadioManager_fnc_showHint;
	false
};

// Verify entry counts match
if (count _savestateData != count _inventoryRadioIds) exitWith {
	[format ["Cannot apply: savestate has %1 radio(s), inventory has %2.", count _savestateData, count _inventoryRadioIds]] call AcreRadioManager_fnc_showHint;
	false
};

// Build type-keyed map for savestate entries: baseClass -> [entries...]
private _savestateByType = createHashMap;
{
	private _entry = _x;
	// baseClass is stored at index 4; fall back to empty string for old savestates
	private _bc = if (count _entry > 4) then { _entry select 4 } else { "" };
	if !(_bc in _savestateByType) then {
		_savestateByType set [_bc, []];
	};
	(_savestateByType get _bc) pushBack _entry;
} forEach _savestateData;

// Build type-keyed map for inventory radio IDs: baseClass -> [radioIds...]
private _inventoryByType = createHashMap;
{
	private _radioId = _x;
	private _bc = [_radioId] call acre_api_fnc_getBaseRadio;
	if !(_bc in _inventoryByType) then {
		_inventoryByType set [_bc, []];
	};
	(_inventoryByType get _bc) pushBack _radioId;
} forEach _inventoryRadioIds;

// Verify that for each type the counts match between savestate and inventory
private _typeMismatch = false;

{
	private _bc = _x;
	private _sCount = count (_savestateByType getOrDefault [_bc, []]);
	private _iCount = count (_inventoryByType getOrDefault [_bc, []]);
	if (_sCount != _iCount) then {
		[format ["Cannot apply: type mismatch for '%1' (%2 in savestate, %3 in inventory).", _bc, _sCount, _iCount]] call AcreRadioManager_fnc_showHint;
		_typeMismatch = true;
	};
} forEach (keys _savestateByType);

if (_typeMismatch) exitWith { false };

// Also check inventory has no extra types not in savestate
private _extraType = false;

{
	private _bc = _x;
	if !(_bc in _savestateByType) then {
		[format ["Cannot apply: inventory has radio type '%1' not present in savestate.", _bc]] call AcreRadioManager_fnc_showHint;
		_extraType = true;
	};
} forEach (keys _inventoryByType);

if (_extraType) exitWith { false };

// Build paired list: [[radioId, settings], ...]
private _pairs = [];
{
	private _bc = _x;
	private _entries = _savestateByType get _bc;
	private _radioIds = _inventoryByType getOrDefault [_bc, []];
	{
		_pairs pushBack [_radioIds select _forEachIndex, _x];
	} forEach _entries;
} forEach (keys _savestateByType);

// Apply settings to each paired radio
private _newPTT = ["", "", ""];

{
	(_x) params ["_radioId", "_settings"];
	
	private _ptt     = _settings select 0;
	private _channel = _settings select 1;
	private _ear     = _settings select 2;
	private _volume  = _settings select 3;
	
	// Apply channel
	[_radioId, _channel] call acre_api_fnc_setRadioChannel;
	
	// Apply ear (spatial positioning) — ACRE expects uppercase
	[_radioId, toUpper _ear] call acre_api_fnc_setRadioSpatial;
	
	// Apply volume
	[_radioId, _volume] call acre_api_fnc_setRadioVolume;
	
	// Accumulate PTT assignments
	if (_ptt >= 1 && _ptt <= 3) then {
		_newPTT set [(_ptt - 1), _radioId];
	};
	
} forEach _pairs;

// Apply accumulated PTT assignments
_newPTT call acre_api_fnc_setMultiPushToTalkAssignment;

// Refresh radio data and UI
[] call AcreRadioManager_fnc_getRadioList;
[] call AcreRadioManager_fnc_updateRadioInventory;

[format ["Applied savestate: %1", _savestateName]] call AcreRadioManager_fnc_showHint;

true
