/*
 * Author: FernandimModelador
 * Registers the ACRE Radio Manager keybind during preInit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_initKeybinds;
 */

#include "\a3\ui_f\hpp\defineDIKCodes.inc"

[
	"ACRE Radio Manager",
	"Open_Menu_Key",
	"Open Menu",
	{
		[] call AcreRadioManager_fnc_openRadioSettings;
		true
	},
	"",
	[DIK_C, [false, true, true]]
] call CBA_fnc_addKeybind;

true