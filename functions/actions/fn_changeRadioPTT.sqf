/*
 * Author: Eludage
 * Changes the radio PTT assignment with smart swapping logic.
 *
 * Arguments:
 * 0: _radioId <STRING> - Radio instance ID
 * 1: _newPTT <NUMBER> - New PTT assignment (0 = none/X, 1-3 = PTT keys)
 * 2: _baseIDC <NUMBER> - Base IDC for the radio's controls
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [_radioId, 2, 16100] call AcreRadioManager_fnc_changeRadioPTT;
 */

params ["_radioId", "_newPTT", "_baseIDC"];

// Validate inputs
if (isNil "_radioId" || _radioId == "") exitWith {
	diag_log "ERROR: Invalid radio ID passed to changeRadioPTT";
	false
};

if (isNil "_newPTT" || typeName _newPTT != "SCALAR" || _newPTT < 0 || _newPTT > 3) exitWith {
	diag_log format ["ERROR: Invalid PTT value passed to changeRadioPTT: %1", _newPTT];
	false
};

if (isNil "_baseIDC" || typeName _baseIDC != "SCALAR") exitWith {
	diag_log "ERROR: Invalid baseIDC passed to changeRadioPTT";
	false
};

// Check ACRE is available
if (isNil "acre_api_fnc_getMultiPushToTalkAssignment" || isNil "acre_api_fnc_setMultiPushToTalkAssignment") exitWith {
	diag_log "ERROR: ACRE API functions not available";
	false
};

// Get radio list to count total radios
private _radios = uiNamespace getVariable ["AcreRadioManager_currentRadios", []];
if (count _radios == 0) exitWith {
	diag_log "ERROR: No radio data available";
	false
};

private _radioCount = count _radios;

// Rule: Player can't remove PTT (press X button)
if (_newPTT == 0) exitWith {
	diag_log "INFO: Player cannot remove PTT assignments (X button is disabled)";
	false
};

// Rule: Player can't choose PTT greater than number of radios
if (_newPTT > _radioCount) exitWith {
	diag_log format ["INFO: Cannot assign PTT %1 - only %2 radio(s) available", _newPTT, _radioCount];
	false
};

// Get current PTT assignments - ACRE returns flat array where index = PTT number
// [radio1, radio2, radio3] means radio1=PTT1, radio2=PTT2, radio3=PTT3
private _pttAssignments = [] call acre_api_fnc_getMultiPushToTalkAssignment;

// Initialize empty array if nil or invalid
if (isNil "_pttAssignments" || typeName _pttAssignments != "ARRAY") then {
	_pttAssignments = [];
};

// Ensure we have at least 3 slots for PTT 1, 2, 3
while {count _pttAssignments < 3} do {
	_pttAssignments pushBack "";
};

// Find current PTT of the radio being changed (index in array = PTT - 1)
private _currentPTT = 0;
{
	if (_x == _radioId) then {
		_currentPTT = _forEachIndex + 1; // Convert 0-based index to 1-based PTT number
	};
} forEach _pttAssignments;

// If trying to assign to same PTT, do nothing
if (_currentPTT == _newPTT) exitWith {
	diag_log format ["INFO: Radio %1 already assigned to PTT %2", _radioId, _newPTT];
	true
};

// Find if another radio is using the target PTT slot
private _targetPTTIndex = _newPTT - 1; // Convert to 0-based index
private _conflictingRadio = _pttAssignments select _targetPTTIndex;
if (isNil "_conflictingRadio" || _conflictingRadio == "") then {
	_conflictingRadio = "";
};

// Handle PTT assignment logic
if (_conflictingRadio != "") then {
	// Rule: If radio with existing PTT swaps to new PTT, the two radios swap
	if (_currentPTT > 0) then {
		// Swap: Put our radio in the target slot, put conflicting radio in our old slot
		private _currentPTTIndex = _currentPTT - 1;
		_pttAssignments set [_targetPTTIndex, _radioId];
		_pttAssignments set [_currentPTTIndex, _conflictingRadio];
	} else {
		// Rule: If radio without PTT gets assigned, other radio loses its PTT
		_pttAssignments set [_targetPTTIndex, _radioId];
	};
} else {
	// Target slot is empty, just assign our radio there
	_pttAssignments set [_targetPTTIndex, _radioId];
	
	// If we had a previous PTT, clear that slot
	if (_currentPTT > 0) then {
		private _currentPTTIndex = _currentPTT - 1;
		_pttAssignments set [_currentPTTIndex, ""];
	};
};

// Apply the new PTT assignments via ACRE API.
// ACRE requires that all entries are valid radio IDs present on the player — empty strings
// are not accepted and cause the call to silently fail. Trim trailing empty slots while
// preserving the positional order (PTT1=index 0, PTT2=index 1, PTT3=index 2).
private _pttFiltered = +_pttAssignments;
while {count _pttFiltered > 0 && { (_pttFiltered select (count _pttFiltered - 1)) == "" }} do {
	_pttFiltered deleteAt (count _pttFiltered - 1);
};
[_pttFiltered] call acre_api_fnc_setMultiPushToTalkAssignment;

// Update PTT values directly in the in-memory radio arrays rather than re-reading from ACRE.
// Reading back from ACRE immediately after a set can return stale data (async processing),
// which makes swaps appear to do nothing. Index 3 in each radio entry is the PTT number.
private _currentRadiosData = uiNamespace getVariable ["AcreRadioManager_currentRadios", []];
{
	private _entry = _x;
	private _entryId = _entry select 0;
	private _newPTTVal = 0;
	{ if (_x == _entryId) then { _newPTTVal = _forEachIndex + 1; }; } forEach _pttAssignments;
	_entry set [3, _newPTTVal];
} forEach _currentRadiosData;

if (uiNamespace getVariable ["AcreRadioManager_previewIsLive", true]) then {
	private _previewRadiosData = uiNamespace getVariable ["AcreRadioManager_previewRadios", []];
	{
		private _entry = _x;
		private _entryId = _entry select 0;
		private _newPTTVal = 0;
		{ if (_x == _entryId) then { _newPTTVal = _forEachIndex + 1; }; } forEach _pttAssignments;
		_entry set [3, _newPTTVal];
	} forEach _previewRadiosData;
};

// Update all radio controls in the UI
private _display = findDisplay 16000;
if (!isNull _display) then {
	[] call AcreRadioManager_fnc_updateRadioInventory;
	if (uiNamespace getVariable ["AcreRadioManager_previewIsLive", true]) then {
		[] call AcreRadioManager_fnc_updateRadioPreview;
	};
};

true
