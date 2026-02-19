/*
 * Author: Eludage
 * Copies settings from the active copy source (set via the Copy button in the preview area)
 * to a target inventory radio. Reads the copy source from uiNamespace.
 * Only applies if the radio types match. Clears copy mode and refreshes all UI afterwards.
 *
 * Arguments:
 * 0: _targetRadioId <STRING> - Radio instance ID of the target inventory radio
 * 1: _targetRadioIndex <NUMBER> - Inventory index of the target radio (used to compute baseIDC for PTT)
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * ["ACRE_PRC343_ID_2", 1] call AcreRadioManager_fnc_copyRadioSettings;
 */

params ["_targetRadioId", "_targetRadioIndex"];

private _copySource = uiNamespace getVariable ["AcreRadioManager_copySource", nil];
if (isNil "_copySource") exitWith {
	diag_log "ERROR: copyRadioSettings called but no copy source active";
	false
};

if (isNil "_targetRadioId" || _targetRadioId == "") exitWith {
	diag_log "ERROR: copyRadioSettings - invalid target radio ID";
	false
};

_copySource params ["_srcBaseClass", "_srcPTT", "_srcChannel", "_srcEar", "_srcVolume"];

// Verify type match
private _targetBaseClass = [_targetRadioId] call acre_api_fnc_getBaseRadio;
if (_targetBaseClass != _srcBaseClass) exitWith {
	diag_log format ["ERROR: copyRadioSettings - type mismatch (%1 vs %2)", _targetBaseClass, _srcBaseClass];
	false
};

// Apply channel
[_targetRadioId, _srcChannel] call acre_api_fnc_setRadioChannel;

// Apply ear
[_targetRadioId, _srcEar] call acre_api_fnc_setRadioSpatial;

// Apply volume
[_targetRadioId, _srcVolume] call acre_api_fnc_setRadioVolume;

// Apply PTT via the existing swap-aware function
private _targetBaseIDC = 16100 + (_targetRadioIndex * 25);
[_targetRadioId, _srcPTT, _targetBaseIDC] call AcreRadioManager_fnc_changeRadioPTT;

// Clear copy mode so highlights are removed from inventory names
uiNamespace setVariable ["AcreRadioManager_copySource", nil];

// Refresh data and all panels
[] call AcreRadioManager_fnc_getRadioList;
[] call AcreRadioManager_fnc_updateRadioInventory;
[] call AcreRadioManager_fnc_updateRadioPreview;

["Settings copied."] call AcreRadioManager_fnc_showHint;

true
