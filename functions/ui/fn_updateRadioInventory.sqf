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
 * Each radio gets a base IDC: 16100 + (radioIndex * 25)
 * - Radio 0 base: 16100, Radio 1 base: 16125, Radio 2 base: 16150, etc.
 * - Maximum 12 radios supported (IDC range: 16100-16399)
 * - Icon: baseIDC + 0
 * - Name (copy target button): baseIDC + 1
 * - PTT Label: baseIDC + 2
 * - PTT Buttons 1-4: baseIDC + 3 to 6
 * - Channel Label: baseIDC + 7
 * - Channel Dec/Display/Inc: baseIDC + 8, 9, 10
 * - Ear Label: baseIDC + 11
 * - Ear Buttons L/B/R: baseIDC + 12, 13, 14
 * - Volume Label: baseIDC + 15
 * - Volume Dec/Edit/Inc: baseIDC + 16, 17, 18
 * - Power Display (read-only): baseIDC + 19
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

// Limit to maximum 12 radios to prevent IDC overflow
private _maxRadios = 12 min (count _radios);
if (count _radios > _maxRadios) then {
	_radios = _radios select [0, _maxRadios];
	// Only show the hint once per dialog session to avoid repeating it on every UI rebuild
	if !(uiNamespace getVariable ["AcreRadioManager_limitHintShown", false]) then {
		[format ["Radio limit reached! Only showing first %1 of %2 radios.", _maxRadios, count _radios]] call AcreRadioManager_fnc_showHint;
		uiNamespace setVariable ["AcreRadioManager_limitHintShown", true];
	};
};

// Create IDC to radio ID mapping in uiNamespace for event handlers
private _idcToRadioMap = createHashMap;

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
	private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;
	
	// Calculate base IDC for this radio (16100 for first radio, 16125 for second, etc.)
	private _baseIDC = 16100 + (_radioIndex * 25);
	
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
	// In copy mode, turns into a green clickable button for matching radio types.
	private _copySource = uiNamespace getVariable ["AcreRadioManager_copySource", nil];
	private _isCopyTarget = (!isNil "_copySource") && { (_copySource select 0) == _baseClass };
	
	private _nameBtnClass = if (_isCopyTarget) then {"ARM_RscButtonGreen"} else {"ARM_RscButtonTransparent"};
	private _ctrlName = _display ctrlCreate [_nameBtnClass, _baseIDC + 1, _group];
	_ctrlName ctrlSetPosition [_xPos, _yRow, 0.20, BUTTON_HEIGHT];
	_ctrlName ctrlSetText _displayName;
	_ctrlName ctrlSetTextColor COLOR_WHITE_100;
	_ctrlName ctrlSetFontHeight 0.04; // Match RscText default used in preview
	private _nameBtnColor = if (_isCopyTarget) then {COLOR_GREEN} else {[0, 0, 0, 0]};
	_ctrlName ctrlSetBackgroundColor _nameBtnColor;
	_ctrlName ctrlEnable _isCopyTarget;
	_ctrlName setVariable ["radioId", _radioId];
	_ctrlName setVariable ["radioIndex", _radioIndex];
	_ctrlName ctrlCommit 0;
	
	_ctrlName ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _targetRadioId = _ctrl getVariable ["radioId", ""];
		private _targetRadioIndex = _ctrl getVariable ["radioIndex", -1];
		if (_targetRadioId != "" && _targetRadioIndex >= 0) then {
			[_targetRadioId, _targetRadioIndex] call AcreRadioManager_fnc_copyRadioSettings;
		};
	}];
	_xPos = _xPos + 0.204;
	
	// === PTT SECTION ===
	// PTT Label
	private _ctrlPTTLabel = _display ctrlCreate ["RscText", _baseIDC + 2, _group];
	_ctrlPTTLabel ctrlSetPosition [_xPos, _yRow, 0.056, BUTTON_HEIGHT];
	_ctrlPTTLabel ctrlSetText "PTT";
	_ctrlPTTLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlPTTLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlPTTLabel ctrlCommit 0;
	_xPos = _xPos + 0.06;
	
	// PTT Buttons: 1, 2, 3, X
	private _pttButtons = ["1", "2", "3", "X"];
	private _radioCount = count _radios;
	{
		private _btnIndex = _forEachIndex;
		private _btnText = _x;
		private _pttNum = _btnIndex + 1; // 1, 2, 3, 4 (where 4 represents X/none)
		private _actualPTT = if (_pttNum == 4) then {0} else {_pttNum}; // Convert button 4 to PTT 0
		
		private _pttBtnClass = if (_pttNum <= 3 && _ptt == _pttNum) then {"ARM_RscButtonGreen"} else {if (_pttNum == 4 && _ptt == 0) then {"ARM_RscButtonRed"} else {"ARM_RscButtonGrey40"}};
		private _ctrlPTT = _display ctrlCreate [_pttBtnClass, _baseIDC + 3 + _btnIndex, _group];
		_ctrlPTT ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
		_ctrlPTT ctrlSetText _btnText;
		_ctrlPTT ctrlSetTextColor COLOR_WHITE_100;
		
		// Determine if button should be enabled
		private _isEnabled = true;
		// Rule: X button is always disabled (can't remove PTT)
		if (_actualPTT == 0) then {
			_isEnabled = false;
		};
		// Rule: Can't select PTT greater than number of radios
		if (_actualPTT > _radioCount) then {
			_isEnabled = false;
		};
		
		// Highlight active PTT
		private _pttBtnColor = COLOR_GREY_40;
		if (_pttNum <= 3 && _ptt == _pttNum) then {
			_pttBtnColor = COLOR_GREEN;
		} else {
			if (_pttNum == 4 && _ptt == 0) then {
				_pttBtnColor = COLOR_RED;
			};
		};
		_ctrlPTT ctrlSetBackgroundColor _pttBtnColor;
		
		_ctrlPTT ctrlEnable _isEnabled;
		_ctrlPTT ctrlCommit 0;
		
		// Add click handler for enabled PTT buttons
		if (_isEnabled) then {
			// Store the PTT value and radio ID directly on the control for the event handler
			_ctrlPTT setVariable ["pttValue", _actualPTT];
			_ctrlPTT setVariable ["radioId", _radioId];
			_ctrlPTT setVariable ["baseIDC", _baseIDC];
			
			_ctrlPTT ctrlAddEventHandler ["MouseButtonDown", {
				params ["_ctrl", "_button", "_xPos", "_yPos"];
				// Only respond to left mouse button (button 0)
				if (_button != 0) exitWith {};
				
				private _pttVal = _ctrl getVariable ["pttValue", -1];
				private _radioIdVal = _ctrl getVariable ["radioId", ""];
				private _baseIDCVal = _ctrl getVariable ["baseIDC", 0];
				
				if (_radioIdVal != "" && _pttVal >= 0 && _baseIDCVal > 0) then {
					[_radioIdVal, _pttVal, _baseIDCVal] call AcreRadioManager_fnc_changeRadioPTT;
				} else {
					diag_log format ["ERROR: PTT button click failed - radioId: %1, pttVal: %2, baseIDC: %3", _radioIdVal, _pttVal, _baseIDCVal];
				};
			}];
		};
		
		_xPos = _xPos + BUTTON_WIDTH + 0.004;
	} forEach _pttButtons;
	
	_xPos = _xPos + 0.006;
	
	// === CHANNEL SECTION ===
	// Determine if radio supports channel changing via +/- buttons
	private _isRadioSupported = (_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0) || (_baseClass find "ACRE_PRC148" >= 0) || (_baseClass find "ACRE_BF888S" >= 0) || (_baseClass find "ACRE_PRC343" >= 0);
	// Determine if radio also supports direct channel input via edit field (PRC-117F and PRC-152 only)
	private _isDirectEdit = (_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0);
	
	// Channel Label
	private _ctrlChannelLabel = _display ctrlCreate ["RscText", _baseIDC + 7, _group];
	_ctrlChannelLabel ctrlSetPosition [_xPos, _yRow, 0.05, BUTTON_HEIGHT];
	_ctrlChannelLabel ctrlSetText "CH";
	_ctrlChannelLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlChannelLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlChannelLabel ctrlCommit 0;
	_xPos = _xPos + 0.054;
	
	// Channel Decrease Button
	private _ctrlChannelDec = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 8, _group];
	_ctrlChannelDec ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlChannelDec ctrlSetText "-";
	_ctrlChannelDec ctrlSetTextColor COLOR_WHITE_100;
	_ctrlChannelDec ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlChannelDec ctrlEnable _isRadioSupported;
	_ctrlChannelDec ctrlCommit 0;
	_xPos = _xPos + BUTTON_WIDTH + 0.004;
	
	// Channel Display / Edit
	// PRC-117F and PRC-152 use an edit field (direct typing); PRC-148 uses a read-only text field (+/- only)
	private _channelDisplayClass = if (_isDirectEdit) then {"ARM_RscEdit"} else {"RscText"};
	private _ctrlChannelDisplay = _display ctrlCreate [_channelDisplayClass, _baseIDC + 9, _group];
	_ctrlChannelDisplay ctrlSetPosition [_xPos, _yRow, 0.26, BUTTON_HEIGHT];
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
	_ctrlChannelDisplay ctrlSetFontHeight 0.04;
	_ctrlChannelDisplay ctrlCommit 0;
	_xPos = _xPos + 0.26 + 0.004;

	// Edit field event handlers — only wired up for radios that support direct channel input (PRC-117F, PRC-152)
	if (_isDirectEdit) then {
		_ctrlChannelDisplay setVariable ["radioId", _radioId];
		_ctrlChannelDisplay setVariable ["channelNum", _channel];

		// On click: clear the field entirely so the player types a fresh number without leftover digits
		_ctrlChannelDisplay ctrlAddEventHandler ["MouseButtonDown", {
			params ["_ctrl", "_button"];
			if (_button != 0) exitWith {};
			_ctrl ctrlSetText "";
		}];

		// On each key release: strip non-numeric characters and auto-apply when two digits are entered
		_ctrlChannelDisplay ctrlAddEventHandler ["KeyUp", {
			params ["_ctrl"];
			// If channel was already committed (text is "N: Name"), skip to avoid re-processing digits in the channel name
			if (ctrlText _ctrl find ": " >= 0) exitWith {};
			[_ctrl] call AcreRadioManager_fnc_validateChannelInput;
			private _value = parseNumber (ctrlText _ctrl);
			// Two digits entered — treat the same as pressing Enter
			if (_value >= 10) then {
				private _editDisplay = ctrlParent _ctrl;
				private _editBaseIDC = ctrlIDC _ctrl - 9;
				private _editRadioId = _ctrl getVariable ["radioId", ""];
				if (_editRadioId != "") then {
					[_editRadioId, _value, _ctrl] call AcreRadioManager_fnc_changeRadioChannelDirect;
					_ctrl setVariable ["channelNum", _value];
					// Move focus to Dec button so the edit field loses focus
					ctrlSetFocus (_editDisplay displayCtrl (_editBaseIDC + 8));
				};
			};
		}];

		// Enter key: apply the typed channel number and keep the full display text
		_ctrlChannelDisplay ctrlAddEventHandler ["KeyDown", {
			params ["_ctrl", "_key"];
			// Enter key: main (DIK 28) or numpad (DIK 156)
			if (_key == 28 || _key == 156) then {
				[_ctrl] call AcreRadioManager_fnc_validateChannelInput;
				private _value = parseNumber (ctrlText _ctrl);
				if (_value >= 1) then {
					private _editRadioId = _ctrl getVariable ["radioId", ""];
					if (_editRadioId != "") then {
						[_editRadioId, _value, _ctrl] call AcreRadioManager_fnc_changeRadioChannelDirect;
						_ctrl setVariable ["channelNum", _value];
						// Move focus away so the cursor leaves the edit field
						ctrlSetFocus (ctrlParent _ctrl displayCtrl (ctrlIDC _ctrl - 1));
					};
				};
			};
		}];

		// Focus loss: apply if the typed value is a valid channel, otherwise restore the last good display
		_ctrlChannelDisplay ctrlAddEventHandler ["KillFocus", {
			params ["_ctrl"];
			// Use parseNumber directly — it reads only the leading number, so "12: Channel 2" → 12
			// Calling validateChannelInput here would concatenate all digits in the string and corrupt the value
			private _value = parseNumber (ctrlText _ctrl);
			private _editRadioId = _ctrl getVariable ["radioId", ""];
			if (_value >= 1 && _value <= 99 && _editRadioId != "") then {
				[_editRadioId, _value, _ctrl] call AcreRadioManager_fnc_changeRadioChannelDirect;
				_ctrl setVariable ["channelNum", _value];
			} else {
				// Restore last known good display when input is empty or out of range
				private _storedChannel = _ctrl getVariable ["channelNum", 1];
				if (_editRadioId != "") then {
					private _restoredName = [_editRadioId, _storedChannel] call AcreRadioManager_fnc_getChannelName;
					_ctrl ctrlSetText format ["%1: %2", _storedChannel, _restoredName];
				};
			};
		}];
	};
	
	// Channel Increase Button
	private _ctrlChannelInc = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 10, _group];
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
				// Sync stored channel number so the edit field's KillFocus fallback stays accurate (not needed for read-only fields)
				_displayCtrl setVariable ["channelNum", [_radioIdFromBtn] call acre_api_fnc_getRadioChannel];
			};
		}];
		_ctrlChannelDec setVariable ["radioId", _radioId];

		_ctrlChannelInc ctrlAddEventHandler ["ButtonClick", {
			params ["_ctrl"];
			private _displayCtrl = ctrlParent _ctrl displayCtrl (ctrlIDC _ctrl - 1); // Get channel display control
			private _radioIdFromBtn = _ctrl getVariable ["radioId", ""];
			if (_radioIdFromBtn != "") then {
				[_radioIdFromBtn, 1, _displayCtrl] call AcreRadioManager_fnc_changeRadioChannel;
				// Sync stored channel number so the edit field's KillFocus fallback stays accurate (not needed for read-only fields)
				_displayCtrl setVariable ["channelNum", [_radioIdFromBtn] call acre_api_fnc_getRadioChannel];
			};
		}];
		_ctrlChannelInc setVariable ["radioId", _radioId];
	};
	
	_xPos = _xPos + BUTTON_WIDTH + 0.01;
	
	// === EAR SECTION ===
	// Ear Label
	private _ctrlEarLabel = _display ctrlCreate ["RscText", _baseIDC + 11, _group];
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
		
		private _earBtnClass = if (_ear == _btnValue) then {"ARM_RscButtonGreen"} else {"ARM_RscButtonGrey40"};
		private _ctrlEar = _display ctrlCreate [_earBtnClass, _baseIDC + 12 + _btnIndex, _group];
		_ctrlEar ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
		_ctrlEar ctrlSetText _btnText;
		_ctrlEar ctrlSetTextColor COLOR_WHITE_100;
		
		// Highlight active ear
		private _earBtnColor = if (_ear == _btnValue) then {COLOR_GREEN} else {COLOR_GREY_40};
		_ctrlEar ctrlSetBackgroundColor _earBtnColor;
		
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
	private _ctrlVolumeLabel = _display ctrlCreate ["RscText", _baseIDC + 15, _group];
	_ctrlVolumeLabel ctrlSetPosition [_xPos, _yRow, 0.06, BUTTON_HEIGHT];
	_ctrlVolumeLabel ctrlSetText "Vol";
	_ctrlVolumeLabel ctrlSetTextColor COLOR_GREY_70;
	_ctrlVolumeLabel ctrlSetBackgroundColor [0, 0, 0, 0];
	_ctrlVolumeLabel ctrlCommit 0;
	_xPos = _xPos + 0.064;
	
	// Volume Decrease Button
	private _ctrlVolumeDec = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 16, _group];
	_ctrlVolumeDec ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlVolumeDec ctrlSetText "-";
	_ctrlVolumeDec ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeDec ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlVolumeDec ctrlCommit 0;
	
	// Add button click handler to decrease volume by 10%
	_ctrlVolumeDec ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _btnBaseIDC = ctrlIDC _ctrl - 16;
		private _btnDisplay = ctrlParent _ctrl;
		private _editCtrl = _btnDisplay displayCtrl (_btnBaseIDC + 17);
		private _currentVolume = parseNumber (ctrlText _editCtrl);
		private _newVolume = (_currentVolume - 10) max 0 min 100;
		
		private _btnRadioId = _ctrl getVariable ["radioId", ""];
		if (_btnRadioId != "") then {
			[_btnRadioId, _newVolume, _btnBaseIDC] call AcreRadioManager_fnc_changeRadioVolume;
		};
	}];
	_ctrlVolumeDec setVariable ["radioId", _radioId];
	
	_xPos = _xPos + BUTTON_WIDTH + 0.004;
	
	// Volume Display (Edit field)
	private _ctrlVolumeEdit = _display ctrlCreate ["ARM_RscEditCentered", _baseIDC + 17, _group];
	_ctrlVolumeEdit ctrlSetPosition [_xPos, _yRow, 0.07, BUTTON_HEIGHT];
	_ctrlVolumeEdit ctrlSetText (str (round (_volume * 100)));
	_ctrlVolumeEdit ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeEdit ctrlSetBackgroundColor COLOR_GREY_30;
	_ctrlVolumeEdit ctrlCommit 0;
	
	// Add validation event handler
	_ctrlVolumeEdit ctrlAddEventHandler ["KeyUp", {
		params ["_ctrl"];
		[_ctrl, false] call AcreRadioManager_fnc_validateVolumeInput; // Don't round while typing
	}];
	_ctrlVolumeEdit ctrlAddEventHandler ["KillFocus", {
		params ["_ctrl"];
		[_ctrl, true] call AcreRadioManager_fnc_validateVolumeInput; // Round when done editing
		
		// Apply the volume change when field loses focus
		private _editBaseIDC = ctrlIDC _ctrl - 17;
		private _newVolume = parseNumber (ctrlText _ctrl);
		
		private _editRadioId = _ctrl getVariable ["radioId", ""];
		if (_editRadioId != "") then {
			[_editRadioId, _newVolume, _editBaseIDC] call AcreRadioManager_fnc_changeRadioVolume;
		};
	}];
	
	// Add Enter key handler to apply volume
	_ctrlVolumeEdit ctrlAddEventHandler ["KeyDown", {
		params ["_ctrl", "_key"];
		// Enter key: main (DIK 28) or numpad (DIK 156)
		if (_key == 28 || _key == 156) then {
			[_ctrl, true] call AcreRadioManager_fnc_validateVolumeInput; // Round when Enter is pressed
			
			private _editBaseIDC = ctrlIDC _ctrl - 17;
			private _newVolume = parseNumber (ctrlText _ctrl);
			
			private _editRadioId = _ctrl getVariable ["radioId", ""];
			if (_editRadioId != "") then {
				[_editRadioId, _newVolume, _editBaseIDC] call AcreRadioManager_fnc_changeRadioVolume;
			};
		};
	}];
	_ctrlVolumeEdit setVariable ["radioId", _radioId];
	
	_xPos = _xPos + 0.07 + 0.004;
	
	// Volume Increase Button
	private _ctrlVolumeInc = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 18, _group];
	_ctrlVolumeInc ctrlSetPosition [_xPos, _yRow, BUTTON_WIDTH, BUTTON_HEIGHT];
	_ctrlVolumeInc ctrlSetText "+";
	_ctrlVolumeInc ctrlSetTextColor COLOR_WHITE_100;
	_ctrlVolumeInc ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlVolumeInc ctrlCommit 0;
	
	// Add button click handler to increase volume by 10%
	_ctrlVolumeInc ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _btnBaseIDC = ctrlIDC _ctrl - 18;
		private _btnDisplay = ctrlParent _ctrl;
		private _editCtrl = _btnDisplay displayCtrl (_btnBaseIDC + 17);
		private _currentVolume = parseNumber (ctrlText _editCtrl);
		private _newVolume = (_currentVolume + 10) max 0 min 100;
		
		private _btnRadioId = _ctrl getVariable ["radioId", ""];
		if (_btnRadioId != "") then {
			[_btnRadioId, _newVolume, _btnBaseIDC] call AcreRadioManager_fnc_changeRadioVolume;
		};
	}];
	_ctrlVolumeInc setVariable ["radioId", _radioId];
	
	_xPos = _xPos + BUTTON_WIDTH + 0.01;
	
	// === POWER DISPLAY ===
	// Read-only indicator — changing radio power state via the ACRE API is not
	// currently supported. The button is intentionally disabled to reflect this.
	// Savestates always restore power as ON; the power state field is not persisted.
	private _powerBtnClass = if (_isOn) then {"ARM_RscButtonGreen"} else {"ARM_RscButtonRed"};
	private _ctrlPower = _display ctrlCreate [_powerBtnClass, _baseIDC + 19, _group];
	_ctrlPower ctrlSetPosition [_xPos, _yRow, 0.09, BUTTON_HEIGHT];
	private _powerColor = if (_isOn) then {COLOR_GREEN} else {COLOR_RED};
	_ctrlPower ctrlSetText (if (_isOn) then {"ON"} else {"OFF"});
	_ctrlPower ctrlSetBackgroundColor _powerColor;
	_ctrlPower ctrlSetTextColor COLOR_WHITE_100;
	_ctrlPower ctrlSetTooltip "Power state is read-only. Toggling radio power via this UI is currently not supported.";
	_ctrlPower ctrlEnable false; // Read-only: no ACRE API available to toggle power
	_ctrlPower ctrlCommit 0;
	
	// Move to next radio position
	_yOffset = _yOffset + ITEM_HEIGHT;
	
} forEach _radios;

// Store IDC to radio ID mapping in uiNamespace for event handlers to use
uiNamespace setVariable ["AcreRadioManager_idcToRadioMap", _idcToRadioMap];

true
