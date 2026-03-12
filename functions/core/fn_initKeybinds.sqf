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