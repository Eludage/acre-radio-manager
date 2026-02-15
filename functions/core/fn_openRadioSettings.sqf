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

// Open the radio settings dialog
private _dialogOpened = createDialog "AcreRadioManager_Dialog";

// Return success/failure
_dialogOpened