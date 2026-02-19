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

// Ensure "Last Presets" exists in savestates
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];
if !("Last Presets" in _savestates) then {
	_savestates set ["Last Presets", []];
	profileNamespace setVariable ["AcreRadioManager_savestates", _savestates];
};

// Open the radio settings dialog
private _dialogOpened = createDialog "AcreRadioManager_Dialog";

// If dialog opened successfully, populate the radio inventory
if (_dialogOpened) then {
	// Initialize previewRadios to match inventory on open
	uiNamespace setVariable ["AcreRadioManager_previewRadios", uiNamespace getVariable ["AcreRadioManager_currentRadios", []]];
	[] call AcreRadioManager_fnc_updateRadioInventory;
	[] call AcreRadioManager_fnc_updateRadioPreview;
	[] call AcreRadioManager_fnc_updateSavestateList;
};

// Return success/failure
_dialogOpened