/*
 * Author: Eludage
 * Dynamically creates read-only controls for each radio in the preview section.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_updateRadioPreview;
 *
 * IDC Naming Convention:
 * Each radio gets a base IDC: 16400 + (radioIndex * 25)
 * - Radio 0 base: 16400, Radio 1 base: 16425, Radio 2 base: 16450, etc.
 * - Maximum 12 radios supported (IDC range: 16400-16699)
 * - Icon: baseIDC + 0
 * - Name: baseIDC + 1
 * - PTT Label: baseIDC + 2
 * - PTT Display: baseIDC + 3
 * - Channel Label: baseIDC + 7
 * - Channel Display: baseIDC + 9
 * - Ear Label: baseIDC + 11
 * - Ear Display: baseIDC + 12
 * - Volume Label: baseIDC + 15
 * - Volume Display: baseIDC + 17
 * - Power Display: baseIDC + 19
 * - Copy Button: baseIDC + 21
 */

// Color constants
#define COLOR_GREY_30 [0.3, 0.3, 0.3, 1]
#define COLOR_GREY_40 [0.4, 0.4, 0.4, 1]
#define COLOR_GREY_70 [0.7, 0.7, 0.7, 1]
#define COLOR_WHITE_100 [1, 1, 1, 1]
#define COLOR_GREEN [0.3, 0.5, 0.3, 1]
#define COLOR_RED [0.5, 0.2, 0.2, 1]

// Size constants (reference: 16:9 small interface, safezoneW ≈ 0.86)
// _scale is derived from the preview group's usable width (0.50 * safezoneW minus the
// 0.021 VScrollbar) divided by the sum of all unscaled control widths in a row (1.182).
private _scale = (0.50 * safezoneW - 0.021) / 1.182;
private _btnW  = 0.05  * _scale;
private _btnH  = 0.056 * _scale;
private _itemH = 0.07  * _scale;

private _display = findDisplay 16000;
if (isNull _display) exitWith {
	diag_log "ERROR: Radio Manager dialog not found";
	false
};

private _group = _display displayCtrl 16020;
if (isNull _group) exitWith {
	diag_log "ERROR: Radio preview group not found";
	false
};

// Get radio data from uiNamespace (preview state - may differ from inventory after loading a savestate)
private _radios = uiNamespace getVariable ["AcreRadioManager_previewRadios", []];
if (count _radios == 0) exitWith {
	true
};

// Limit to maximum 12 radios to prevent IDC overflow
private _maxRadios = 12 min (count _radios);
if (count _radios > _maxRadios) then {
	_radios = _radios select [0, _maxRadios];
};

// Clear existing controls before rebuilding
{
	ctrlDelete _x;
} forEach (allControls _group);

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
	private _ear = _radioData select 6;
	private _volume = _radioData select 7;
	private _isOn = _radioData select 8;
	// Index 9 holds a baseClass override when loaded from a savestate (no live radio ID available)
	private _radioBaseClass = if (count _radioData > 9) then { _radioData select 9 } else { "" };
	
	// Calculate base IDC for this radio (16400 for first radio, 16425 for second, etc.)
	private _baseIDC = 16400 + (_radioIndex * 25);
	
	// All controls on same Y position for single row
	private _yRow = _yOffset + 0.006 * _scale;
	private _xPos = 0.01 * _scale;
	
	// === ICON ===
	private _ctrlIcon = _display ctrlCreate ["RscPicture", _baseIDC + 0, _group];
	_ctrlIcon ctrlSetPosition [_xPos, _yRow, 0.064 * _scale, 0.064 * _scale];
	_ctrlIcon ctrlSetText _icon;
	_ctrlIcon ctrlCommit 0;
	_xPos = _xPos + 0.07 * _scale;
	
	// === RADIO NAME ===
	private _ctrlName = _display ctrlCreate ["ARM_RscTextCentered", _baseIDC + 1, _group];
	_ctrlName ctrlSetPosition [_xPos, _yRow, 0.20 * _scale, _btnH];
	_ctrlName ctrlSetText _displayName;
	_ctrlName ctrlSetTextColor COLOR_WHITE_100;
	_ctrlName ctrlSetFontHeight (0.04 * _scale);
	_ctrlName ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlName ctrlCommit 0;
	_xPos = _xPos + 0.20 * _scale + 0.004 * _scale;
	
	// === PTT SECTION ===
	// PTT Label
	private _ctrlPTTLabel = _display ctrlCreate ["RscText", _baseIDC + 2, _group];
	_ctrlPTTLabel ctrlSetPosition [_xPos, _yRow, 0.056 * _scale, _btnH];
	_ctrlPTTLabel ctrlSetText "PTT";
	_ctrlPTTLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlPTTLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlPTTLabel ctrlCommit 0;
	_xPos = _xPos + 0.06 * _scale;
	
	// PTT Display - single button showing current value
	private _pttText = "X";
	private _pttColor = COLOR_RED;
	if (_ptt > 0 && _ptt <= 3) then {
		_pttText = str _ptt;
		_pttColor = COLOR_GREEN;
	};
	
	private _pttBtnClass = if (_ptt > 0 && _ptt <= 3) then {"ARM_RscButtonGreen"} else {"ARM_RscButtonRed"};
	private _ctrlPTTDisplay = _display ctrlCreate [_pttBtnClass, _baseIDC + 3, _group];
	_ctrlPTTDisplay ctrlSetPosition [_xPos, _yRow, _btnW, _btnH];
	_ctrlPTTDisplay ctrlSetText _pttText;
	_ctrlPTTDisplay ctrlSetTextColor COLOR_WHITE_100;
	_ctrlPTTDisplay ctrlSetBackgroundColor _pttColor;
	_ctrlPTTDisplay ctrlEnable false;
	_ctrlPTTDisplay ctrlCommit 0;
	_xPos = _xPos + _btnW + 0.01 * _scale;
	
	// === CHANNEL SECTION ===
	// Determine if radio supports channel changing (PRC-117F, PRC-152, PRC-148, BF-888S and PRC-343)
	// Use stored baseClass override (savestate rows) or look it up from the live radio ID.
	private _baseClass = if (_radioBaseClass != "") then { _radioBaseClass } else { [_radioId] call acre_api_fnc_getBaseRadio };
	private _isRadioSupported = (_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0) || (_baseClass find "ACRE_PRC148" >= 0) || (_baseClass find "ACRE_BF888S" >= 0) || (_baseClass find "ACRE_PRC343" >= 0);
	
	// Channel Label
	private _ctrlChannelLabel = _display ctrlCreate ["RscText", _baseIDC + 7, _group];
	_ctrlChannelLabel ctrlSetPosition [_xPos, _yRow, 0.05 * _scale, _btnH];
	_ctrlChannelLabel ctrlSetText "CH";
	_ctrlChannelLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlChannelLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlChannelLabel ctrlCommit 0;
	_xPos = _xPos + 0.054 * _scale;
	
	// Channel Display
	private _ctrlChannelDisplay = _display ctrlCreate ["RscText", _baseIDC + 9, _group];
	_ctrlChannelDisplay ctrlSetPosition [_xPos, _yRow, 0.26 * _scale, _btnH];
	if (_isRadioSupported) then {
		if ((_baseClass find "ACRE_PRC148" >= 0) || (_baseClass find "ACRE_PRC343" >= 0)) then {
			private _blkOrGrp = floor((_channel - 1) / 16) + 1;
			private _localCh = ((_channel - 1) mod 16) + 1;
			private _prefix = if (_baseClass find "ACRE_PRC343" >= 0) then {"Bl"} else {"Gr"};
			_ctrlChannelDisplay ctrlSetText format ["%1 %2, Ch %3, %4", _prefix, _blkOrGrp, _localCh, _channelName];
		} else {
			_ctrlChannelDisplay ctrlSetText format ["%1: %2", _channel, _channelName];
		};
	} else {
		_ctrlChannelDisplay ctrlSetText "Radio not supported";
	};
	_ctrlChannelDisplay ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelDisplay ctrlSetBackgroundColor COLOR_GREY_30;
	_ctrlChannelDisplay ctrlCommit 0;
	_xPos = _xPos + 0.26 * _scale + 0.01 * _scale;
	
	// === EAR SECTION ===
	// Ear Label
	private _ctrlEarLabel = _display ctrlCreate ["RscText", _baseIDC + 11, _group];
	_ctrlEarLabel ctrlSetPosition [_xPos, _yRow, 0.056 * _scale, _btnH];
	_ctrlEarLabel ctrlSetText "Ear";
	_ctrlEarLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlEarLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlEarLabel ctrlCommit 0;
	_xPos = _xPos + 0.06 * _scale;
	
	// Ear Display - single button showing current value
	private _earText = "B";
	if (_ear == "left") then { _earText = "L"; };
	if (_ear == "right") then { _earText = "R"; };
	
	private _ctrlEarDisplay = _display ctrlCreate ["ARM_RscButtonGreen", _baseIDC + 12, _group];
	_ctrlEarDisplay ctrlSetPosition [_xPos, _yRow, _btnW, _btnH];
	_ctrlEarDisplay ctrlSetText _earText;
	_ctrlEarDisplay ctrlSetTextColor COLOR_WHITE_100;
	_ctrlEarDisplay ctrlSetBackgroundColor COLOR_GREEN;
	_ctrlEarDisplay ctrlEnable false;
	_ctrlEarDisplay ctrlCommit 0;
	_xPos = _xPos + _btnW + 0.01 * _scale;
	
	// === VOLUME SECTION ===
	// Volume Label
	private _ctrlVolumeLabel = _display ctrlCreate ["RscText", _baseIDC + 15, _group];
	_ctrlVolumeLabel ctrlSetPosition [_xPos, _yRow, 0.06 * _scale, _btnH];
	_ctrlVolumeLabel ctrlSetText "Vol";
	_ctrlVolumeLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlVolumeLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlVolumeLabel ctrlCommit 0;
	_xPos = _xPos + 0.064 * _scale;
	
	// Volume Display
	private _ctrlVolumeDisplay = _display ctrlCreate ["ARM_RscTextCentered", _baseIDC + 17, _group];
	_ctrlVolumeDisplay ctrlSetPosition [_xPos, _yRow, 0.07 * _scale, _btnH];
	_ctrlVolumeDisplay ctrlSetText (str (round (_volume * 100)));
	_ctrlVolumeDisplay ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeDisplay ctrlSetBackgroundColor COLOR_GREY_30;
	_ctrlVolumeDisplay ctrlCommit 0;
	_xPos = _xPos + 0.07 * _scale + 0.01 * _scale;
	
	// === POWER BUTTON ===
	// Power Display (read-only button)
	private _powerBtnClass = if (_isOn) then {"ARM_RscButtonGreen"} else {"ARM_RscButtonRed"};
	private _ctrlPowerDisplay = _display ctrlCreate [_powerBtnClass, _baseIDC + 19, _group];
	_ctrlPowerDisplay ctrlSetPosition [_xPos, _yRow, 0.09 * _scale, _btnH];
	private _powerColor = if (_isOn) then {COLOR_GREEN} else {COLOR_RED};
	_ctrlPowerDisplay ctrlSetText (if (_isOn) then {"ON"} else {"OFF"});
	_ctrlPowerDisplay ctrlSetBackgroundColor _powerColor;
	_ctrlPowerDisplay ctrlSetTextColor COLOR_WHITE_100;
	_ctrlPowerDisplay ctrlEnable false;
	_ctrlPowerDisplay ctrlCommit 0;
	_xPos = _xPos + 0.09 * _scale + 0.01 * _scale;
	
	// === COPY BUTTON ===
	// Enters copy mode: highlights matching radio names in the inventory green
	// so the player can click one to paste these preview settings onto it.
	private _ctrlCopyButton = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 21, _group];
	_ctrlCopyButton ctrlSetPosition [_xPos, _yRow, 0.09 * _scale, _btnH];
	_ctrlCopyButton ctrlSetText "Copy";
	_ctrlCopyButton ctrlSetTextColor COLOR_WHITE_100;
	_ctrlCopyButton ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlCopyButton ctrlCommit 0;
	
	_ctrlCopyButton setVariable ["radioIndex", _radioIndex];
	_ctrlCopyButton ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _srcIndex = _ctrl getVariable ["radioIndex", -1];
		private _previewRadios = uiNamespace getVariable ["AcreRadioManager_previewRadios", []];
		if (_srcIndex < 0 || _srcIndex >= count _previewRadios) exitWith {};
		private _srcData = _previewRadios select _srcIndex;
		// Use stored baseClass override if available (savestate preview rows have no live radio ID)
		private _srcBaseClass = if (count _srcData > 9) then { _srcData select 9 } else { [(_srcData select 0)] call acre_api_fnc_getBaseRadio };
		uiNamespace setVariable ["AcreRadioManager_copySource", [
			_srcBaseClass,
			_srcData select 3, // ptt
			_srcData select 4, // channel
			_srcData select 6, // ear
			_srcData select 7  // volume
		]];
		// Rebuild inventory UI to apply green highlight to matching radio names
		[] call AcreRadioManager_fnc_updateRadioInventory;
	}];
	
	// Move to next radio position
	_yOffset = _yOffset + _itemH;
	
} forEach _radios;

true
