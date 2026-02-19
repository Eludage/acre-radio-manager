/*
 * Author: Eludage
 * Displays a hint message that automatically clears after 5 seconds.
 * Uses a counter to prevent an older spawned clear from wiping a newer hint.
 *
 * Arguments:
 * 0: _message <STRING> - The message to display
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * ["Settings applied."] call AcreRadioManager_fnc_showHint;
 */

params ["_message"];

if (isNil "_message" || typeName _message != "STRING") exitWith {
	diag_log "ERROR: showHint called with invalid message";
	false
};

// Increment hint counter so any previous spawned clear knows it is stale
private _id = (uiNamespace getVariable ["AcreRadioManager_hintCounter", 0]) + 1;
uiNamespace setVariable ["AcreRadioManager_hintCounter", _id];

hint _message;

[5, _id] spawn {
	params ["_duration", "_hintId"];
	sleep _duration;
	if ((uiNamespace getVariable ["AcreRadioManager_hintCounter", 0]) == _hintId) then {
		hint "";
	};
};

true
