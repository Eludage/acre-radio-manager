/*
 * Author: Eludage
 * Opens the Acre Radio Manager settings dialog.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_openRadioSettings;
 */

// Retrieve current radio list and store in uiNamespace
private _radioList = [] call AcreRadioManager_fnc_getRadioList;

// Debug: Log radio list
diag_log "=== ACRE Radio List ===";
if (typeName _radioList == "STRING") then {
	diag_log "No radios found in inventory.";
} else {
	diag_log format ["Found %1 radio(s):", count _radioList];
	{
		private _radioId = _x select 0;
		private _icon = _x select 1;
		private _name = _x select 2;
		private _ptt = _x select 3;
		private _channel = _x select 4;
		private _channelName = _x select 5;
		private _frequency = _x select 6;
		private _ear = _x select 7;
		private _volume = _x select 8;
		private _isOn = _x select 9;
		
		diag_log format ["Radio %1: %2", _forEachIndex + 1, _name];
		diag_log format ["  ID: %1", _radioId];
		diag_log format ["  PTT: %1 | Channel: %2 (%3)", _ptt, _channel, _channelName];
		diag_log format ["  Freq: %1 MHz | Ear: %2 | Vol: %3%4", _frequency, _ear, round(_volume * 100), "%"];
		diag_log format ["  Power: %1 | Icon: %2", if (_isOn) then {"ON"} else {"OFF"}, _icon];
	} forEach _radioList;
};
diag_log "======================";

// Open the radio settings dialog
private _dialogOpened = createDialog "AcreRadioManager_Dialog";

// Return success/failure
_dialogOpened