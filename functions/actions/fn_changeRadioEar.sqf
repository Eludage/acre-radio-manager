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

// Update UI - highlight the selected button, unhighlight others
private _display = findDisplay 16000;
if (!isNull _display) then {
	private _earButtons = [
		[_baseIDC + 12, "left"],
		[_baseIDC + 13, "center"],
		[_baseIDC + 14, "right"]
	];
	
	{
		private _btnIDC = _x select 0;
		private _btnValue = _x select 1;
		private _ctrl = _display displayCtrl _btnIDC;
		
		if (!isNull _ctrl) then {
			if (_btnValue == _newEar) then {
				_ctrl ctrlSetBackgroundColor [0.3, 0.5, 0.3, 1]; // COLOR_GREEN
			} else {
				_ctrl ctrlSetBackgroundColor [0.4, 0.4, 0.4, 1]; // COLOR_GREY_40
			};
			_ctrl ctrlCommit 0;
		};
	} forEach _earButtons;
};

true
