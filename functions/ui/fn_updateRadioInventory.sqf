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
#define ITEM_HEIGHT 0.08
#define ITEM_PADDING 0.005
#define BUTTON_WIDTH 0.03
#define BUTTON_HEIGHT 0.025

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
	diag_log "No radios to display";
	true
};

diag_log format ["Creating UI for %1 radios", count _radios];

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
	
	// Calculate base IDC for this radio (16100 for first radio, 16200 for second, etc.)
	private _baseIDC = 16100 + (_radioIndex * 100);
	
	// Store mapping for event handlers
	_idcToRadioMap set [_baseIDC, _radioId];
	
	// === ICON ===
	private _ctrlIcon = _display ctrlCreate ["RscPicture", _baseIDC + 0, _group];
	_ctrlIcon ctrlSetPosition [0.005, _yOffset + 0.005, 0.06, 0.06];
	_ctrlIcon ctrlSetText _icon;
	_ctrlIcon ctrlCommit 0;
	
	// === RADIO NAME ===
	private _ctrlName = _display ctrlCreate ["RscText", _baseIDC + 1, _group];
	_ctrlName ctrlSetPosition [0.07, _yOffset + 0.005, 0.15, 0.025];
	_ctrlName ctrlSetText _displayName;
	_ctrlName ctrlSetTextColor COLOR_WHITE_100;
	_ctrlName ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlName ctrlCommit 0;
	
	// === PTT SECTION ===
	private _xPTT = 0.07;
	private _yPTT = _yOffset + 0.032;
	
	// PTT Label
	private _ctrlPTTLabel = _display ctrlCreate ["RscText", _baseIDC + 9, _group];
	_ctrlPTTLabel ctrlSetPosition [_xPTT, _yPTT, 0.04, BUTTON_HEIGHT];
	_ctrlPTTLabel ctrlSetText "PTT:";
	_ctrlPTTLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlPTTLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlPTTLabel ctrlCommit 0;
	
	_xPTT = _xPTT + 0.035;
	
	// PTT Buttons: 1, 2, 3, X
	private _pttButtons = ["1", "2", "3", "X"];
	{
		private _btnIndex = _forEachIndex;
		private _btnText = _x;
		private _pttNum = _btnIndex + 1; // 1, 2, 3, 4
		
		private _ctrlPTT = _display ctrlCreate ["RscButton", _baseIDC + 10 + _btnIndex, _group];
		_ctrlPTT ctrlSetPosition [_xPTT + (_btnIndex * (BUTTON_WIDTH + 0.003)), _yPTT, BUTTON_WIDTH, BUTTON_HEIGHT];
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
	} forEach _pttButtons;
	
	// === CHANNEL SECTION ===
	private _xChannel = 0.24;
	private _yChannel = _yPTT;
	
	// Channel Label
	private _ctrlChannelLabel = _display ctrlCreate ["RscText", _baseIDC + 19, _group];
	_ctrlChannelLabel ctrlSetPosition [_xChannel, _yChannel, 0.03, BUTTON_HEIGHT];
	_ctrlChannelLabel ctrlSetText "CH:";
	_ctrlChannelLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlChannelLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlChannelLabel ctrlCommit 0;
	
	_xChannel = _xChannel + 0.032;
	
	// Channel Decrease Button
	private _ctrlChannelDec = _display ctrlCreate ["RscButton", _baseIDC + 20, _group];
	_ctrlChannelDec ctrlSetPosition [_xChannel, _yChannel, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlChannelDec ctrlSetText "-";
	_ctrlChannelDec ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelDec ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlChannelDec ctrlCommit 0;
	
	_xChannel = _xChannel + BUTTON_WIDTH + 0.003;
	
	// Channel Display
	private _ctrlChannelDisplay = _display ctrlCreate ["RscText", _baseIDC + 21, _group];
	_ctrlChannelDisplay ctrlSetPosition [_xChannel, _yChannel, 0.12, BUTTON_HEIGHT];
	_ctrlChannelDisplay ctrlSetText format ["%1: %2", _channel, _channelName];
	_ctrlChannelDisplay ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelDisplay ctrlSetBackgroundColor COLOR_GREY_30;
	_ctrlChannelDisplay ctrlCommit 0;
	
	_xChannel = _xChannel + 0.12 + 0.003;
	
	// Channel Increase Button
	private _ctrlChannelInc = _display ctrlCreate ["RscButton", _baseIDC + 22, _group];
	_ctrlChannelInc ctrlSetPosition [_xChannel, _yChannel, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlChannelInc ctrlSetText "+";
	_ctrlChannelInc ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelInc ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlChannelInc ctrlCommit 0;
	
	// === EAR SECTION ===
	private _xEar = 0.47;
	private _yEar = _yPTT;
	
	// Ear Label
	private _ctrlEarLabel = _display ctrlCreate ["RscText", _baseIDC + 29, _group];
	_ctrlEarLabel ctrlSetPosition [_xEar, _yEar, 0.035, BUTTON_HEIGHT];
	_ctrlEarLabel ctrlSetText "Ear:";
	_ctrlEarLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlEarLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlEarLabel ctrlCommit 0;
	
	_xEar = _xEar + 0.038;
	
	// Ear Buttons: L, B, R
	private _earButtons = [["L", "left"], ["B", "center"], ["R", "right"]];
	{
		private _btnData = _x;
		private _btnText = _btnData select 0;
		private _btnValue = _btnData select 1;
		private _btnIndex = _forEachIndex;
		
		private _ctrlEar = _display ctrlCreate ["RscButton", _baseIDC + 30 + _btnIndex, _group];
		_ctrlEar ctrlSetPosition [_xEar + (_btnIndex * (BUTTON_WIDTH + 0.003)), _yEar, BUTTON_WIDTH, BUTTON_HEIGHT];
		_ctrlEar ctrlSetText _btnText;
		_ctrlEar ctrlSetTextColor COLOR_WHITE_100;
		
		// Highlight active ear
		if (_ear == _btnValue) then {
			_ctrlEar ctrlSetBackgroundColor COLOR_GREEN;
		} else {
			_ctrlEar ctrlSetBackgroundColor COLOR_GREY_40;
		};
		
		_ctrlEar ctrlCommit 0;
	} forEach _earButtons;
	
	// === VOLUME SECTION ===
	private _xVolume = 0.59;
	private _yVolume = _yPTT;
	
	// Volume Label
	private _ctrlVolumeLabel = _display ctrlCreate ["RscText", _baseIDC + 39, _group];
	_ctrlVolumeLabel ctrlSetPosition [_xVolume, _yVolume, 0.035, BUTTON_HEIGHT];
	_ctrlVolumeLabel ctrlSetText "Vol:";
	_ctrlVolumeLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlVolumeLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlVolumeLabel ctrlCommit 0;
	
	_xVolume = _xVolume + 0.038;
	
	// Volume Decrease Button
	private _ctrlVolumeDec = _display ctrlCreate ["RscButton", _baseIDC + 40, _group];
	_ctrlVolumeDec ctrlSetPosition [_xVolume, _yVolume, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlVolumeDec ctrlSetText "-";
	_ctrlVolumeDec ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeDec ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlVolumeDec ctrlCommit 0;
	
	_xVolume = _xVolume + BUTTON_WIDTH + 0.003;
	
	// Volume Display (Edit field)
	private _ctrlVolumeEdit = _display ctrlCreate ["RscEdit", _baseIDC + 41, _group];
	_ctrlVolumeEdit ctrlSetPosition [_xVolume, _yVolume, 0.04, BUTTON_HEIGHT];
	_ctrlVolumeEdit ctrlSetText (str (round (_volume * 100)));
	_ctrlVolumeEdit ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeEdit ctrlSetBackgroundColor COLOR_GREY_30;
	_ctrlVolumeEdit ctrlCommit 0;
	
	_xVolume = _xVolume + 0.04 + 0.003;
	
	// Volume Increase Button
	private _ctrlVolumeInc = _display ctrlCreate ["RscButton", _baseIDC + 42, _group];
	_ctrlVolumeInc ctrlSetPosition [_xVolume, _yVolume, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlVolumeInc ctrlSetText "+";
	_ctrlVolumeInc ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeInc ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlVolumeInc ctrlCommit 0;
	
	// === POWER BUTTON ===
	private _xPower = 0.09;
	private _yPower = _yOffset + 0.06;
	
	// Power Button (Toggle On/Off)
	private _ctrlPower = _display ctrlCreate ["RscButton", _baseIDC + 50, _group];
	_ctrlPower ctrlSetPosition [_xPower, _yPower, 0.06, BUTTON_HEIGHT];
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

diag_log "Radio inventory UI created successfully";

true
