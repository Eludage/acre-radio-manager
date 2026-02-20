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
if (_radios isEqualTo "") exitWith {
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

// Apply the new PTT assignments via ACRE API
[_pttAssignments] call acre_api_fnc_setMultiPushToTalkAssignment;

// Refresh the radio list to update UI with new PTT states
[] call AcreRadioManager_fnc_getRadioList;

// Update all radio controls in the UI
private _display = findDisplay 16000;
if (!isNull _display) then {
	[] call AcreRadioManager_fnc_updateRadioInventory;
	if (uiNamespace getVariable ["AcreRadioManager_previewIsLive", true]) then {
		[] call AcreRadioManager_fnc_updateRadioPreview;
	};
};

true
