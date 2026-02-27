/*
 * Author: Eludage
 * Changes the radio volume and updates the UI.
 *
 * Arguments:
 * 0: _radioId <STRING> - Radio instance ID
 * 1: _newVolumePercent <NUMBER> - New volume percentage (0-100)
 * 2: _baseIDC <NUMBER> - Base IDC for the radio's controls
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [_radioId, 75, 16100] call AcreRadioManager_fnc_changeRadioVolume;
 */

params ["_radioId", "_newVolumePercent", "_baseIDC"];

// Validate inputs
if (isNil "_radioId" || _radioId == "") exitWith {
	diag_log "ERROR: Invalid radio ID passed to changeRadioVolume";
	false
};

if (isNil "_newVolumePercent" || typeName _newVolumePercent != "SCALAR") exitWith {
	diag_log format ["ERROR: Invalid volume passed to changeRadioVolume: %1 (type: %2)", _newVolumePercent, typeName _newVolumePercent];
	false
};

if (isNil "_baseIDC" || typeName _baseIDC != "SCALAR") exitWith {
	diag_log "ERROR: Invalid baseIDC passed to changeRadioVolume";
	false
};

// Clamp volume between 0 and 100
_newVolumePercent = _newVolumePercent max 0 min 100;

// Check ACRE is available
if (isNil "acre_api_fnc_setRadioVolume") exitWith {
	diag_log "ERROR: ACRE API function setRadioVolume not available";
	false
};

// Convert percentage (0-100) to ACRE volume (0.0-1.0)
private _acreVolume = _newVolumePercent / 100;

// Set new volume via ACRE API
private _result = [_radioId, _acreVolume] call acre_api_fnc_setRadioVolume;

// Update UI - update the volume edit field
private _display = findDisplay 16000;
if (!isNull _display) then {
	private _volumeEditCtrl = _display displayCtrl (_baseIDC + 17);
	if (!isNull _volumeEditCtrl) then {
		_volumeEditCtrl ctrlSetText (str (round _newVolumePercent));
		_volumeEditCtrl ctrlCommit 0;
	};
};

// Refresh radio data and update UI
[] call AcreRadioManager_fnc_getRadioList;
[] call AcreRadioManager_fnc_updateRadioInventory;
if (uiNamespace getVariable ["AcreRadioManager_previewIsLive", true]) then {
	[] call AcreRadioManager_fnc_updateRadioPreview;
};

true
