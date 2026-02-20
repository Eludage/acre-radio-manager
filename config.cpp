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
            class changeRadioChannel {}; // Changes radio channel by increment and updates UI
            class changeRadioChannelDirect {}; // Sets radio channel directly to a given number and updates UI
            class changeRadioEar {}; // Changes radio ear/spatial assignment and updates UI
            class changeRadioVolume {}; // Changes radio volume and updates UI
            class changeRadioPTT {}; // Changes radio PTT assignment with smart swapping
            class addSavestate {}; // Adds a new savestate entry
            class removeSavestate {}; // Removes the selected savestate entry
            class loadSavestate {}; // Loads a savestate and applies it to the current radios
            class saveSavestate {}; // Saves the current radio settings to a savestate
            class applySavestate {}; // Applies a savestate to the actual ACRE radios, matching by radio type
            class copyRadioSettings {}; // Copies preview radio settings onto a target inventory radio (used by copy mode)
            class renameSavestate {}; // Renames a savestate entry
            class savePresets {}; // Saves the current radio settings and flushes all pending savestate changes to disk
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
            class updateSavestateList {}; // Dynamically creates savestate list controls
        };
        // ===== Utilities / Helpers =====
        class utilities
        {
            file = "AcreRadioManager\functions\utilities";
            class debugLogRadioList {}; // Logs radio list to debug console
            class validateVolumeInput {}; // Validates and clamps volume input (0-100), optionally rounds to nearest 10
            class validateChannelInput {}; // Validates and clamps channel input (1-99), strips non-numeric characters
            class getChannelName {}; // Resolves channel display name from ACRE preset data for a given radio and channel number
            class showHint {}; // Displays a hint message that auto-clears after 5 seconds
        };
    };
};

// Include dialog definitions from external file
#include "radioSettingsDialog.hpp"