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
// [_radioList] call AcreRadioManager_fnc_debugLogRadioList;

// Open the radio settings dialog
private _dialogOpened = createDialog "AcreRadioManager_Dialog";

// If dialog opened successfully, populate the radio inventory
if (_dialogOpened) then {
	[] call AcreRadioManager_fnc_updateRadioInventory;
};

// Return success/failure
_dialogOpened