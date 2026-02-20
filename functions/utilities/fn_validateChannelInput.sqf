/*
 * Author: Eludage
 * Validates and clamps channel input to numeric values between 1 and 99.
 * Strips non-numeric characters from the edit field text.
 *
 * Arguments:
 * 0: _ctrl <CONTROL> - The edit control to validate
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [_channelEditCtrl] call AcreRadioManager_fnc_validateChannelInput;
 */

params ["_ctrl"];

if (isNull _ctrl) exitWith {
	diag_log "ERROR: Invalid control passed to validateChannelInput";
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

// Only update the control if there is something to validate
if (_cleanText isEqualTo "") exitWith {
	true
};

// Convert to number and clamp to valid channel range (1-99)
private _value = parseNumber _cleanText;
_value = _value max 1 min 99;

// Update control text with sanitized value
_ctrl ctrlSetText (str _value);

true
