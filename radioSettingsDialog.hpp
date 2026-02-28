// Radio Settings Dialog Definitions
// This file contains all UI/dialog class definitions

// Color macros (button and accent colors)
#define COLOR_RED {0.5, 0.2, 0.2, 1}
#define COLOR_RED_ACTIVE {0.6, 0.3, 0.3, 1}
#define COLOR_DARK_RED {0.4, 0.2, 0.2, 1}
#define COLOR_DARK_RED_ACTIVE {0.5, 0.3, 0.3, 1}
#define COLOR_GREEN {0.3, 0.5, 0.3, 1}
#define COLOR_GREEN_ACTIVE {0.4, 0.6, 0.4, 1}
#define COLOR_BLUE {0.3, 0.3, 0.5, 1}
#define COLOR_BLUE_ACTIVE {0.4, 0.4, 0.6, 1}
#define COLOR_YELLOW {1, 0.8, 0, 1}
#define COLOR_GOLDEN_BROWN {0.5, 0.4, 0.2, 1}
#define COLOR_GOLDEN_BROWN_ACTIVE {0.6, 0.5, 0.3, 1}

#define COLOR_WHITE_10 {1, 1, 1, 0.1}
#define COLOR_WHITE_100 {1, 1, 1, 1}

#define COLOR_BLACK_0 {0, 0, 0, 0}
#define COLOR_BLACK_50 {0, 0, 0, 0.5}
#define COLOR_BLACK_65 {0, 0, 0, 0.65}
#define COLOR_BLACK_100 {0, 0, 0, 1}

#define COLOR_GREY_05 {0.05, 0.05, 0.05, 1}
#define COLOR_GREY_10 {0.1, 0.1, 0.1, 1}
#define COLOR_GREY_15 {0.15, 0.15, 0.15, 1}
#define COLOR_GREY_20 {0.2, 0.2, 0.2, 1}
#define COLOR_GREY_30 {0.3, 0.3, 0.3, 1}
#define COLOR_GREY_40 {0.4, 0.4, 0.4, 1}
#define COLOR_GREY_50 {0.5, 0.5, 0.5, 1}
#define COLOR_GREY_60 {0.6, 0.6, 0.6, 1}
#define COLOR_GREY_70 {0.7, 0.7, 0.7, 1}

class ARM_RscStatic // Base class for static elements, see https://community.bistudio.com/wiki/CT_STATIC
{
    access = 0;
    type = 0;
    idc = -1;
    // default value for safe usage
    colorBackground[] = COLOR_BLACK_0;
    colorText[] = COLOR_WHITE_100;
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0;
    w = 0;
    style = 0;
    shadow = 1;
    colorShadow[] = COLOR_BLACK_50;
    font = "RobotoCondensed";
    sizeEx = 0.04;
    linespacing = 1;
    tooltipColorText[] = COLOR_WHITE_100;
    tooltipColorBox[] = COLOR_WHITE_100;
    tooltipColorShade[] = COLOR_BLACK_65;
};

class ARM_RscPanel: ARM_RscStatic // Intended for background/card panels
{
    colorBackground[] = COLOR_GREY_05;
    shadow = 0;
};

class ARM_RscBoxTitle: ARM_RscStatic // Intended for box titles
{
    colorText[] = COLOR_YELLOW;
    font = "RobotoCondensedBold";
    sizeEx = 0.04;
    shadow = 1;
};

class ARM_RscTextLabel: ARM_RscStatic // Intended for normal text labels
{
    colorText[] = COLOR_WHITE_100;
    font = "RobotoCondensed";
    sizeEx = 0.03;
    shadow = 1;
};

class ARM_RscTextCentered: ARM_RscStatic // Centered text variant
{
    style = 2; // ST_CENTER
    colorText[] = COLOR_WHITE_100;
    font = "RobotoCondensed";
    sizeEx = 0.03;
    shadow = 1;
};

class ARM_RscButton // Base class for buttons, see https://community.bistudio.com/wiki/CT_BUTTON
{
    access = 0;
    type = 1;
    text = "";
    colorText[] = COLOR_WHITE_100;
    colorDisabled[] = COLOR_GREY_40;
    colorBackground[] = COLOR_BLACK_50;
    colorBackgroundDisabled[] = COLOR_BLACK_50;
    colorBackgroundActive[] = COLOR_BLACK_100;
    colorFocused[] = COLOR_BLACK_50;
    colorShadow[] = COLOR_BLACK_0;
    colorBorder[] = COLOR_BLACK_100;
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
    idc = -1;
    style = 2;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    shadow = 2;
    font = "RobotoCondensed";
    sizeEx = 0.03;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    borderSize = 0;
};

class ARM_RscButtonGrey40: ARM_RscButton {
    colorBackground[] = COLOR_GREY_40;
    colorFocused[] = COLOR_GREY_40;
    colorBackgroundActive[] = COLOR_GREY_50;
};

class ARM_RscButtonGreen: ARM_RscButton {
    colorBackground[] = COLOR_GREEN;
    colorFocused[] = COLOR_GREEN;
    colorBackgroundActive[] = COLOR_GREEN_ACTIVE;
};

class ARM_RscButtonRed: ARM_RscButton {
    colorBackground[] = COLOR_RED;
    colorFocused[] = COLOR_RED;
    colorBackgroundActive[] = COLOR_RED_ACTIVE;
};

class ARM_RscButtonTransparent: ARM_RscButton {
    colorBackground[] = COLOR_BLACK_0;
    colorBackgroundDisabled[] = COLOR_BLACK_0;
    colorBackgroundActive[] = COLOR_BLACK_0;
    colorFocused[] = COLOR_BLACK_0;
    colorDisabled[] = COLOR_WHITE_100;
    colorShadow[] = COLOR_BLACK_0;
    colorBorder[] = COLOR_BLACK_0;
};

class ARM_RscListbox // Base class for listboxes, see https://community.bistudio.com/wiki/CT_LISTBOX
{
    access = 0;
    type = 5;
    style = 0;
    w = 0.4;
    h = 0.4;
    font = "RobotoCondensedLight";
    sizeEx = 0.03;
    rowHeight = 0.03;
    colorText[] = COLOR_WHITE_100;
    colorSelect[] = COLOR_BLACK_100;
    colorSelect2[] = COLOR_BLACK_100;
    colorSelectBackground[] = COLOR_GREY_30;
    colorSelectBackground2[] = COLOR_GREY_20;
    colorBackground[] = COLOR_GREY_05;
    colorDisabled[] = COLOR_GREY_40;
    maxHistoryDelay = 1.0;
    soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect", 0.09, 1};
    period = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
    arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
    shadow = 0;
    class ListScrollBar {
        color[] = COLOR_WHITE_100;
        colorActive[] = COLOR_WHITE_100;
        colorDisabled[] = COLOR_WHITE_10;
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
    };
};

class ARM_RscEdit // Base class for edit fields, see https://community.bistudio.com/wiki/CT_EDIT
{
    access = 0;
    type = 2;
    style = 64;  // ST_NO_RECT
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    colorBackground[] = COLOR_GREY_15;
    colorText[] = COLOR_WHITE_100;
    colorDisabled[] = COLOR_GREY_50;
    colorSelection[] = COLOR_GREY_50;
    font = "RobotoCondensed";
    sizeEx = 0.03;
    autocomplete = "";
    text = "";
    shadow = 0;
    maxChars = 10000;
    canModify = 1;
};

class ARM_RscEditCentered: ARM_RscEdit // Centered edit field variant
{
    style = 66; // ST_NO_RECT + ST_CENTER (64 + 2)
};

class ARM_RscControlsGroup // Base class for scrollable control groups, see https://community.bistudio.com/wiki/CT_CONTROLS_GROUP
{
    access = 0;
    type = 15; // CT_CONTROLS_GROUP
    idc = -1;
    style = 16; // ST_MULTI
    x = 0;
    y = 0;
    w = 1;
    h = 1;
    shadow = 0;
    class VScrollbar
    {
        width = 0.021;
        autoScrollSpeed = -1;
        autoScrollDelay = 5;
        autoScrollRewind = 0;
        shadow = 0;
        color[] = COLOR_WHITE_100;
        colorActive[] = COLOR_WHITE_100;
        colorDisabled[] = COLOR_WHITE_10;
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
    };
    class HScrollbar
    {
        height = 0;
    };
    class Controls {};
};

class AcreRadioManager_Dialog
{
    idd = 16000;
    movingEnable = true;
    onUnload = "[] call AcreRadioManager_fnc_savePresets;";
    class ControlsBackground
    {
        // Full Background
        class Background: ARM_RscPanel
        {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.1 * safezoneH + safezoneY;
            w = 0.7 * safezoneW;
            h = 0.8 * safezoneH;
            colorBackground[] = COLOR_GREY_10;
        };
    };

    class Controls
    {
        // ============== RADIOS IN INVENTORY SECTION ==============
        class RadiosInventoryTitle: ARM_RscBoxTitle
        {
            idc = -1;
            text = "Radios in Inventory";
            x = 0.16 * safezoneW + safezoneX;
            y = 0.11 * safezoneH + safezoneY;
            w = 0.20 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class RadiosInventoryBackground: ARM_RscPanel
        {
            idc = -1;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.14 * safezoneH + safezoneY;
            w = 0.68 * safezoneW;
            h = 0.31 * safezoneH;
            colorBackground[] = COLOR_GREY_15;
        };

        class RadiosInventoryGroup: ARM_RscControlsGroup
        {
            idc = 16010;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.14 * safezoneH + safezoneY;
            w = 0.68 * safezoneW;
            h = 0.31 * safezoneH;
            
            class Controls
            {
                // Controls will be created dynamically at runtime
            };
        };

        // ============== Radio Preview SECTION ==============
        class RadioPreviewTitle: ARM_RscBoxTitle
        {
            idc = -1;
            text = "Radio Preview";
            x = 0.16 * safezoneW + safezoneX;
            y = 0.46 * safezoneH + safezoneY;
            w = 0.20 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class RadioPreviewBackground: ARM_RscPanel
        {
            idc = -1;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.49 * safezoneH + safezoneY;
            w = 0.50 * safezoneW;
            h = 0.31 * safezoneH;
            colorBackground[] = COLOR_GREY_15;
        };

        class RadioPreviewGroup: ARM_RscControlsGroup
        {
            idc = 16020;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.49 * safezoneH + safezoneY;
            w = 0.50 * safezoneW;
            h = 0.31 * safezoneH;
            
            class Controls
            {
                // Controls will be created dynamically at runtime
            };
        };

        // ============== Radio Preview Options SECTION ==============
        class RadioSavestatesTitle: ARM_RscBoxTitle
        {
            idc = -1;
            text = "Radio Savestates";
            x = 0.67 * safezoneW + safezoneX;
            y = 0.46 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.025 * safezoneH;
        };

        class RadioSavestatesBackground: ARM_RscPanel
        {
            idc = -1;
            x = 0.67 * safezoneW + safezoneX;
            y = 0.49 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.26 * safezoneH;
            colorBackground[] = COLOR_GREY_15;
        };

        class RadioSavestatesGroup: ARM_RscControlsGroup
        {
            idc = 16030;
            x = 0.67 * safezoneW + safezoneX;
            y = 0.49 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.26 * safezoneH;
            
            class Controls
            {
                // Controls will be created dynamically at runtime
            };
        };

        class RadioSavestatesButtonsBackground: ARM_RscPanel
        {
            idc = -1;
            x = 0.67 * safezoneW + safezoneX;
            y = 0.76 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_GREY_15;
        };

        class AddSavestateButton: ARM_RscButton
        {
            idc = 16031;
            text = "Add Savestate";
            x = 0.68 * safezoneW + safezoneX;
            y = 0.77 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.02 * safezoneH;
            action = "[] call AcreRadioManager_fnc_addSavestate;";
            colorBackground[] = COLOR_GREY_30;
            colorFocused[] = COLOR_GREY_30;
            colorBackgroundActive[] = COLOR_GREY_50;
        };

        class RemoveSavestateButton: ARM_RscButton
        {
            idc = 16032;
            text = "Remove Savestate";
            x = 0.76 * safezoneW + safezoneX;
            y = 0.77 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.02 * safezoneH;
            action = "[] call AcreRadioManager_fnc_removeSavestate;";
            colorBackground[] = COLOR_GREY_30;
            colorFocused[] = COLOR_GREY_30;
            colorBackgroundActive[] = COLOR_GREY_50;
        };

        // ============== CLOSE BUTTON ==============
        class CloseButton: ARM_RscButton
        {
            idc = 16011;
            text = "Close";
            x = 0.74 * safezoneW + safezoneX;
            y = 0.84 * safezoneH + safezoneY;
            w = 0.1 * safezoneW;
            h = 0.04 * safezoneH;
            action = "closeDialog 0;";
            colorBackground[] = COLOR_GREY_30;
            colorFocused[] = COLOR_GREY_30;
            colorBackgroundActive[] = COLOR_GREY_50;
            sizeEx = 0.05;
        };
    };
};