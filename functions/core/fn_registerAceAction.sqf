/*
 * Author: Eludage
 * Registers the Radio Manager self-action under ACRE_Interact at runtime.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_registerAceAction;
 */

private _condition = {
	params ["_target", "_player", "_params"];
	[_player, _target, ["isNotInside", "isNotSitting"]] call ace_common_fnc_canInteractWith
};

private _statement = {
	[] call AcreRadioManager_fnc_openRadioSettings;
};

private _action = [
	"AcreRadioManager_RadioSettings",
	"Manage Radio Settings",
	"",
	_statement,
	_condition
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "ACRE_Interact"], _action, true] call ace_interact_menu_fnc_addActionToClass;

true

