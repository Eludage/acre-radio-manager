/*
 * Author: Eludage
 * Sets the radio channel directly to a specified channel number and updates the UI.
 *
 * Arguments:
 * 0: _radioId <STRING> - Radio instance ID
 * 1: _targetChannel <NUMBER> - Direct channel number to set (1-99)
 * 2: _displayCtrl <CONTROL> - Channel display control to update
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [_radioId, 5, _channelDisplayCtrl] call AcreRadioManager_fnc_changeRadioChannelDirect;
 */

params ["_radioId", "_targetChannel", "_displayCtrl"];

// Validate inputs
if (isNil "_radioId" || _radioId == "") exitWith {
	diag_log "ERROR: Invalid radio ID passed to changeRadioChannelDirect";
	false
};

if (isNil "_targetChannel" || typeName _targetChannel != "SCALAR") exitWith {
	diag_log format ["ERROR: Invalid channel passed to changeRadioChannelDirect: %1 (type: %2)", _targetChannel, typeName _targetChannel];
	false
};

if (isNull _displayCtrl) exitWith {
	diag_log "ERROR: Invalid display control passed to changeRadioChannelDirect";
	false
};

// Check ACRE is available
if (isNil "acre_api_fnc_getRadioChannel" || isNil "acre_api_fnc_setRadioChannel") exitWith {
	diag_log "ERROR: ACRE API functions not available";
	false
};

// Get base class for channel count lookup
private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;

// Get max channel count from cache or config
private _channelCache = uiNamespace getVariable ["AcreRadioManager_channelCountCache", createHashMap];
private _maxChannel = _channelCache getOrDefault [_baseClass, 0];

if (_maxChannel == 0) then {
	// Special handling for known multi-channel radios
	if ((_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0)) then {
		_maxChannel = 99;
	} else {
		// Look up from config
		_maxChannel = getNumber (configFile >> "CfgWeapons" >> _baseClass >> "numChannels");
		if (_maxChannel == 0) then {
			_maxChannel = getNumber (configFile >> "CfgAcreRadios" >> _baseClass >> "numChannels");
		};
		if (_maxChannel == 0) then {
			_maxChannel = getNumber (configFile >> "CfgWeapons" >> _baseClass >> "numberOfChannels");
		};
		if (_maxChannel == 0) then {
			_maxChannel = getNumber (configFile >> "CfgAcreRadios" >> _baseClass >> "numberOfChannels");
		};

		// If config lookup failed, count channels by iterating preset data
		if (_maxChannel == 0) then {
			for "_i" from 0 to 99 do {
				private _testData = [_baseClass, "default", _i] call acre_api_fnc_getPresetChannelData;
				if (isNil "_testData") exitWith {
					_maxChannel = _i;
				};
			};
		};

		// Final fallback
		if (_maxChannel == 0) then {
			_maxChannel = 16;
		};
	};

	// Cache the result
	_channelCache set [_baseClass, _maxChannel];
	uiNamespace setVariable ["AcreRadioManager_channelCountCache", _channelCache];
};

// Clamp to valid channel range
private _newChannel = _targetChannel max 1 min _maxChannel;

// Resolve channel name and apply via ACRE API
private _channelName = [_radioId, _newChannel] call AcreRadioManager_fnc_getChannelName;
[_radioId, _newChannel] call acre_api_fnc_setRadioChannel;

// Update display control to full "N: Name" format
_displayCtrl ctrlSetText format ["%1: %2", _newChannel, _channelName];

// Refresh radio data and update Radio Preview only when showing live inventory
[] call AcreRadioManager_fnc_getRadioList;
if (uiNamespace getVariable ["AcreRadioManager_previewIsLive", true]) then {
	[] call AcreRadioManager_fnc_updateRadioPreview;
};

true
