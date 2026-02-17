/*
 * Author: Eludage
 * Dynamically creates controls for each radio in the inventory section.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_updateRadioInventory;
 *
 * IDC Naming Convention:
 * Each radio gets a base IDC: 16100 + (radioIndex * 100)
 * - Radio 0 base: 16100, Radio 1 base: 16200, Radio 2 base: 16300, etc.
 * - Icon: baseIDC + 0
 * - Name: baseIDC + 1
 * - PTT Label: baseIDC + 9
 * - PTT Buttons 1-4: baseIDC + 10 to 13
 * - Channel Label: baseIDC + 19
 * - Channel Dec/Display/Inc: baseIDC + 20, 21, 22
 * - Ear Label: baseIDC + 29
 * - Ear Buttons L/B/R: baseIDC + 30, 31, 32
 * - Volume Label: baseIDC + 39
 * - Volume Dec/Edit/Inc: baseIDC + 40, 41, 42
 * - Power Button: baseIDC + 50
 */

// Color constants
#define COLOR_GREY_30 [0.3, 0.3, 0.3, 1]
#define COLOR_GREY_40 [0.4, 0.4, 0.4, 1]
#define COLOR_GREY_50 [0.5, 0.5, 0.5, 1]
#define COLOR_GREY_70 [0.7, 0.7, 0.7, 1]
#define COLOR_WHITE_100 [1, 1, 1, 1]
#define COLOR_GREEN [0.3, 0.5, 0.3, 1]
#define COLOR_GREEN_ACTIVE [0.4, 0.6, 0.4, 1]
#define COLOR_RED [0.5, 0.2, 0.2, 1]
#define COLOR_RED_ACTIVE [0.6, 0.3, 0.3, 1]

// Size constants
#define ITEM_HEIGHT 0.07
#define ITEM_PADDING 0.01
#define BUTTON_WIDTH 0.05
#define BUTTON_HEIGHT 0.056

private _display = findDisplay 16000;
if (isNull _display) exitWith {
	diag_log "ERROR: Radio Manager dialog not found";
	false
};

private _group = _display displayCtrl 16010;
if (isNull _group) exitWith {
	diag_log "ERROR: Radio inventory group not found";
	false
};

// Get radio data from uiNamespace
private _radios = uiNamespace getVariable ["AcreRadioManager_currentRadios", []];
if (_radios isEqualTo "") exitWith {
	true
};

// Create IDC to radio ID mapping in uiNamespace for event handlers
private _idcToRadioMap = createHashMap;

private _yOffset = 0;

{
	private _radioData = _x;
	private _radioIndex = _forEachIndex;
	
	// Extract radio information
	private _radioId = _radioData select 0;
	private _icon = _radioData select 1;
	private _displayName = _radioData select 2;
	private _ptt = _radioData select 3;
	private _channel = _radioData select 4;
	private _channelName = _radioData select 5;
	private _frequency = _radioData select 6;
	private _ear = _radioData select 7;
	private _volume = _radioData select 8;
	private _isOn = _radioData select 9;
	
	// Calculate base IDC for this radio (16500 for first radio, 16550 for second, etc.)
	private _baseIDC = 16500 + (_radioIndex * 50);
	
	// Store mapping for event handlers
	_idcToRadioMap set [_baseIDC, _radioId];
	
	// All controls on same Y position for single row
	private _yRow = _yOffset + 0.006;
	private _xPos = 0.01;
	
	// === ICON ===
	private _ctrlIcon = _display ctrlCreate ["RscPicture", _baseIDC + 0, _group];
	_ctrlIcon ctrlSetPosition [_xPos, _yRow, 0.064, 0.064];
	_ctrlIcon ctrlSetText _icon;
	_ctrlIcon ctrlCommit 0;
	_xPos = _xPos + 0.07;
	
	// === RADIO NAME ===
	private _ctrlName = _display ctrlCreate ["RscText", _baseIDC + 1, _group];
	_ctrlName ctrlSetPosition [_xPos, _yRow, 0.20, BUTTON_HEIGHT];
	_ctrlName ctrlSetText _displayName;
	_ctrlName ctrlSetTextColor COLOR_WHITE_100;
	_ctrlName ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlName ctrlCommit 0;
	_xPos = _xPos + 0.204;
	
	// === PTT SECTION ===
	// PTT Label
	private _ctrlPTTLabel = _display ctrlCreate ["RscText", _baseIDC + 9, _group];
	_ctrlPTTLabel ctrlSetPosition [_xPos, _yRow, 0.056, BUTTON_HEIGHT];
	_ctrlPTTLabel ctrlSetText "PTT";
	_ctrlPTTLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlPTTLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlPTTLabel ctrlCommit 0;
	_xPos = _xPos + 0.06;
	
	// PTT Buttons: 1, 2, 3, X
	private _pttButtons = ["1", "2", "3", "X"];
	{
		private _btnIndex = _forEachIndex;
		private _btnText = _x;
		private _pttNum = _btnIndex + 1; // 1, 2, 3, 4
		
		private _ctrlPTT = _display ctrlCreate ["RscButton", _baseIDC + 10 + _btnIndex, _group];
		_ctrlPTT ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
		_ctrlPTT ctrlSetText _btnText;
		_ctrlPTT ctrlSetTextColor COLOR_WHITE_100;
		
		// Highlight active PTT
		if (_pttNum <= 3 && _ptt == _pttNum) then {
			_ctrlPTT ctrlSetBackgroundColor COLOR_GREEN;
		} else {
			if (_pttNum == 4 && _ptt == 0) then {
				_ctrlPTT ctrlSetBackgroundColor COLOR_RED;
			} else {
				_ctrlPTT ctrlSetBackgroundColor COLOR_GREY_40;
			};
		};
		
		_ctrlPTT ctrlCommit 0;
		_xPos = _xPos + BUTTON_WIDTH + 0.004;
	} forEach _pttButtons;
	
	_xPos = _xPos + 0.006;
	
	// === CHANNEL SECTION ===
	// Determine if radio supports channel changing (only PRC-117F and PRC-152)
	private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;
	private _isRadioSupported = (_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0);
	
	// Channel Label
	private _ctrlChannelLabel = _display ctrlCreate ["RscText", _baseIDC + 19, _group];
	_ctrlChannelLabel ctrlSetPosition [_xPos, _yRow, 0.05, BUTTON_HEIGHT];
	_ctrlChannelLabel ctrlSetText "CH";
	_ctrlChannelLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlChannelLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlChannelLabel ctrlCommit 0;
	_xPos = _xPos + 0.054;
	
	// Channel Decrease Button
	private _ctrlChannelDec = _display ctrlCreate ["RscButton", _baseIDC + 20, _group];
	_ctrlChannelDec ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlChannelDec ctrlSetText "-";
	_ctrlChannelDec ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelDec ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlChannelDec ctrlEnable _isRadioSupported;
	_ctrlChannelDec ctrlCommit 0;
	_xPos = _xPos + BUTTON_WIDTH + 0.004;
	
	// Channel Display
	private _ctrlChannelDisplay = _display ctrlCreate ["RscText", _baseIDC + 21, _group];
	_ctrlChannelDisplay ctrlSetPosition [_xPos, _yRow, 0.26, BUTTON_HEIGHT];
	if (_isRadioSupported) then {
		_ctrlChannelDisplay ctrlSetText format ["%1: %2", _channel, _channelName];
	} else {
		_ctrlChannelDisplay ctrlSetText "Radio not supported";
	};
	_ctrlChannelDisplay ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelDisplay ctrlSetBackgroundColor COLOR_GREY_30;
	_ctrlChannelDisplay ctrlCommit 0;
	_xPos = _xPos + 0.26 + 0.004;
	
	// Channel Increase Button
	private _ctrlChannelInc = _display ctrlCreate ["RscButton", _baseIDC + 22, _group];
	_ctrlChannelInc ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlChannelInc ctrlSetText "+";
	_ctrlChannelInc ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelInc ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlChannelInc ctrlEnable _isRadioSupported;
	_ctrlChannelInc ctrlCommit 0;
	
	// Add event handlers for channel buttons (only if radio is supported)
	if (_isRadioSupported) then {
		_ctrlChannelDec ctrlAddEventHandler ["ButtonClick", {
			params ["_ctrl"];
			private _displayCtrl = ctrlParent _ctrl displayCtrl (ctrlIDC _ctrl + 1); // Get channel display control
			private _radioIdFromBtn = _ctrl getVariable ["radioId", ""];
			if (_radioIdFromBtn != "") then {
				[_radioIdFromBtn, -1, _displayCtrl] call AcreRadioManager_fnc_changeRadioChannel;
			};
		}];
		_ctrlChannelDec setVariable ["radioId", _radioId];
		
		_ctrlChannelInc ctrlAddEventHandler ["ButtonClick", {
			params ["_ctrl"];
			private _displayCtrl = ctrlParent _ctrl displayCtrl (ctrlIDC _ctrl - 1); // Get channel display control
			private _radioIdFromBtn = _ctrl getVariable ["radioId", ""];
			if (_radioIdFromBtn != "") then {
				[_radioIdFromBtn, 1, _displayCtrl] call AcreRadioManager_fnc_changeRadioChannel;
			};
		}];
		_ctrlChannelInc setVariable ["radioId", _radioId];
	};
	
	_xPos = _xPos + BUTTON_WIDTH + 0.01;
	
	// === EAR SECTION ===
	// Ear Label
	private _ctrlEarLabel = _display ctrlCreate ["RscText", _baseIDC + 29, _group];
	_ctrlEarLabel ctrlSetPosition [_xPos, _yRow, 0.056, BUTTON_HEIGHT];
	_ctrlEarLabel ctrlSetText "Ear";
	_ctrlEarLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlEarLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlEarLabel ctrlCommit 0;
	_xPos = _xPos + 0.06;
	
	// Ear Buttons: L, B, R
	private _earButtons = [["L", "left"], ["B", "center"], ["R", "right"]];
	{
		private _btnData = _x;
		private _btnText = _btnData select 0;
		private _btnValue = _btnData select 1;
		private _btnIndex = _forEachIndex;
		
		private _ctrlEar = _display ctrlCreate ["RscButton", _baseIDC + 30 + _btnIndex, _group];
		_ctrlEar ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
		_ctrlEar ctrlSetText _btnText;
		_ctrlEar ctrlSetTextColor COLOR_WHITE_100;
		
		// Highlight active ear
		if (_ear == _btnValue) then {
			_ctrlEar ctrlSetBackgroundColor COLOR_GREEN;
		} else {
			_ctrlEar ctrlSetBackgroundColor COLOR_GREY_40;
		};
		
		_ctrlEar ctrlCommit 0;
		
		// Add event handler for ear button
		_ctrlEar ctrlAddEventHandler ["ButtonClick", {
			params ["_ctrl"];
			private _radioIdFromBtn = _ctrl getVariable ["radioId", ""];
			private _earValue = _ctrl getVariable ["earValue", ""];
			private _baseIDCFromBtn = _ctrl getVariable ["baseIDC", 0];
			if (_radioIdFromBtn != "" && _earValue != "" && _baseIDCFromBtn > 0) then {
				[_radioIdFromBtn, _earValue, _baseIDCFromBtn] call AcreRadioManager_fnc_changeRadioEar;
			};
		}];
		_ctrlEar setVariable ["radioId", _radioId];
		_ctrlEar setVariable ["earValue", _btnValue];
		_ctrlEar setVariable ["baseIDC", _baseIDC];
		
		_xPos = _xPos + BUTTON_WIDTH + 0.004;
	} forEach _earButtons;
	
	_xPos = _xPos + 0.01;
	
	// === VOLUME SECTION ===
	// Volume Label  
	private _ctrlVolumeLabel = _display ctrlCreate ["RscText", _baseIDC + 39, _group];
	_ctrlVolumeLabel ctrlSetPosition [_xPos, _yRow, 0.06, BUTTON_HEIGHT];
	_ctrlVolumeLabel ctrlSetText "Vol";
	_ctrlVolumeLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlVolumeLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlVolumeLabel ctrlCommit 0;
	_xPos = _xPos + 0.064;
	
	// Volume Decrease Button
	private _ctrlVolumeDec = _display ctrlCreate ["RscButton", _baseIDC + 40, _group];
	_ctrlVolumeDec ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlVolumeDec ctrlSetText "-";
	_ctrlVolumeDec ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeDec ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlVolumeDec ctrlCommit 0;
	_xPos = _xPos + BUTTON_WIDTH + 0.004;
	
	// Volume Display (Edit field)
	private _ctrlVolumeEdit = _display ctrlCreate ["ARM_RscEditCentered", _baseIDC + 41, _group];
	_ctrlVolumeEdit ctrlSetPosition [_xPos, _yRow, 0.07, BUTTON_HEIGHT];
	_ctrlVolumeEdit ctrlSetText (str (round (_volume * 100)));
	_ctrlVolumeEdit ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeEdit ctrlSetBackgroundColor COLOR_GREY_30;
	_ctrlVolumeEdit ctrlCommit 0;
	
	// Add validation event handler
	_ctrlVolumeEdit ctrlAddEventHandler ["KeyUp", {
		params ["_ctrl"];
		[_ctrl] call AcreRadioManager_fnc_validateVolumeInput;
	}];
	_ctrlVolumeEdit ctrlAddEventHandler ["KillFocus", {
		params ["_ctrl"];
		[_ctrl] call AcreRadioManager_fnc_validateVolumeInput;
	}];
	
	_xPos = _xPos + 0.07 + 0.004;
	
	// Volume Increase Button
	private _ctrlVolumeInc = _display ctrlCreate ["RscButton", _baseIDC + 42, _group];
	_ctrlVolumeInc ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlVolumeInc ctrlSetText "+";
	_ctrlVolumeInc ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeInc ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlVolumeInc ctrlCommit 0;
	_xPos = _xPos + BUTTON_WIDTH + 0.01;
	
	// === POWER BUTTON ===
	// Power Button (Toggle On/Off)
	private _ctrlPower = _display ctrlCreate ["RscButton", _baseIDC + 50, _group];
	_ctrlPower ctrlSetPosition [_xPos, _yRow, 0.09, BUTTON_HEIGHT];
	if (_isOn) then {
		_ctrlPower ctrlSetText "ON";
		_ctrlPower ctrlSetBackgroundColor COLOR_GREEN;
	} else {
		_ctrlPower ctrlSetText "OFF";
		_ctrlPower ctrlSetBackgroundColor COLOR_RED;
	};
	_ctrlPower ctrlSetTextColor COLOR_WHITE_100;
	_ctrlPower ctrlCommit 0;
	
	// Move to next radio position
	_yOffset = _yOffset + ITEM_HEIGHT;
	
} forEach _radios;

// Store IDC to radio ID mapping in uiNamespace for event handlers to use
uiNamespace setVariable ["AcreRadioManager_idcToRadioMap", _idcToRadioMap];

true
