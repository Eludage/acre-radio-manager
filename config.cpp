class CfgPatches
{
    class AcreRadioManager
    {
        name = "Acre Radio Manager";
        author = "Eludage";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {
            "cba_main",
            "ace_interact_menu",
            "acre_main"
        };
    };
};

class CfgVehicles {
    class Man;
    class CAManBase: Man {
        class ACE_SelfActions {
            class ACRE_Interact {
                class RadioSettings {
                    displayName = "Manage Radio Settings";
                    condition = "true";
                    statement = "call AcreRadioManager_fnc_openRadioSettings";
                    exceptions[] = {"isNotInside", "isNotSitting"};
                };
            };
        };
    };
};

class CfgFunctions
{
    class AcreRadioManager
    {
        tag = "AcreRadioManager";
        // ===== Core / Initialization =====
        class core
        {
            file = "AcreRadioManager\functions\core";
            class openRadioSettings {}; // Opens the main dialog
        };
    };
};

// Include dialog definitions from external file
#include "radioSettingsDialog.hpp"