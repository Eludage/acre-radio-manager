/*
 * Author: Eludage
 * Validates and clamps volume input to numeric values between 0 and 100.
 *
 * Arguments:
 * 0: _ctrl <CONTROL> - The edit control to validate
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [_volumeEditCtrl] call AcreRadioManager_fnc_validateVolumeInput;
 */

params ["_ctrl"];

if (isNull _ctrl) exitWith {
	diag_log "ERROR: Invalid control passed to validateVolumeInput";
	false
};

// Get current text
private _text = ctrlText _ctrl;

// Remove any non-numeric characters
private _cleanText = "";
{
	private _char = _x;
	if (_char in ["0","1","2","3","4","5","6","7","8","9"]) then {
		_cleanText = _cleanText + _char;
	};
} forEach (toArray _text apply {toString [_x]});

// Convert to number, default to 0 if empty
private _value = 0;
if (_cleanText != "") then {
	_value = parseNumber _cleanText;
};

// Clamp between 0 and 100
_value = _value max 0 min 100;

// Update control text with validated value
_ctrl ctrlSetText (str _value);

true
