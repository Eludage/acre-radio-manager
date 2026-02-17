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
        // ===== Actions / User Interactions =====
        class actions
        {
            file = "AcreRadioManager\functions\actions";
            class changeRadioChannel {}; // Changes radio channel and updates UI
            class changeRadioEar {}; // Changes radio ear/spatial assignment and updates UI
        };
        // ===== Data / ACRE Interface =====
        class data
        {
            file = "AcreRadioManager\functions\data";
            class getRadioList {}; // Retrieves all radios and their settings from ACRE
        };
        // ===== UI / Interface Updates =====
        class ui
        {
            file = "AcreRadioManager\functions\ui";
            class updateRadioInventory {}; // Dynamically creates radio inventory controls
            class updateRadioPreview {}; // Dynamically creates radio preview controls
        };
        // ===== Utilities / Helpers =====
        class utilities
        {
            file = "AcreRadioManager\functions\utilities";
            class debugLogRadioList {}; // Logs radio list to debug console
            class validateVolumeInput {}; // Validates and clamps volume input (0-100)
        };
    };
};

// Include dialog definitions from external file
#include "radioSettingsDialog.hpp"