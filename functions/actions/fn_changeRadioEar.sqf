/*
 * Author: Eludage
 * Changes the radio ear/spatial assignment and updates the UI.
 *
 * Arguments:
 * 0: _radioId <STRING> - Radio instance ID
 * 1: _newEar <STRING> - New ear assignment: "left", "center", or "right"
 * 2: _baseIDC <NUMBER> - Base IDC for the radio's controls
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [_radioId, "left", 16100] call AcreRadioManager_fnc_changeRadioEar;
 */

params ["_radioId", "_newEar", "_baseIDC"];

// Validate inputs
if (isNil "_radioId" || _radioId == "") exitWith {
	diag_log "ERROR: Invalid radio ID passed to changeRadioEar";
	false
};

if (isNil "_newEar" || !(_newEar in ["left", "center", "right"])) exitWith {
	diag_log format ["ERROR: Invalid ear value passed to changeRadioEar: %1", _newEar];
	false
};

if (isNil "_baseIDC" || typeName _baseIDC != "SCALAR") exitWith {
	diag_log "ERROR: Invalid baseIDC passed to changeRadioEar";
	false
};

// Check ACRE is available
if (isNil "acre_api_fnc_setRadioSpatial") exitWith {
	diag_log "ERROR: ACRE API function setRadioSpatial not available";
	false
};

// Convert ear value to what ACRE expects (uppercase string)
private _acreSpatial = toUpper _newEar;

// Set new ear assignment via ACRE API
private _result = [_radioId, _acreSpatial] call acre_api_fnc_setRadioSpatial;

// Refresh radio data and rebuild inventory (recreates ear buttons with correct class so
// colorFocused matches the new active state) and update Radio Preview
[] call AcreRadioManager_fnc_getRadioList;
[] call AcreRadioManager_fnc_updateRadioInventory;
[] call AcreRadioManager_fnc_updateRadioPreview;

true
