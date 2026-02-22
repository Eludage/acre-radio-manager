/*
 * Author: Eludage
 * Changes the radio channel by a specified increment and updates the UI.
 *
 * Arguments:
 * 0: _radioId <STRING> - Radio instance ID
 * 1: _increment <NUMBER> - Amount to change channel by (e.g., 1 or -1)
 * 2: _displayCtrl <CONTROL> - Channel display control to update
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [_radioId, 1, _channelDisplayCtrl] call AcreRadioManager_fnc_changeRadioChannel;
 */

params ["_radioId", "_increment", "_displayCtrl"];

// Validate inputs
if (isNil "_radioId" || _radioId == "") exitWith {
	diag_log "ERROR: Invalid radio ID passed to changeRadioChannel";
	false
};

if (isNil "_increment" || typeName _increment != "SCALAR") exitWith {
	diag_log format ["ERROR: Invalid increment passed to changeRadioChannel: %1 (type: %2)", _increment, typeName _increment];
	false
};

if (isNull _displayCtrl) exitWith {
	diag_log "ERROR: Invalid display control passed to changeRadioChannel";
	false
};

// Check ACRE is available
if (isNil "acre_api_fnc_getRadioChannel" || isNil "acre_api_fnc_setRadioChannel") exitWith {
	diag_log "ERROR: ACRE API functions not available";
	false
};

// Get current channel
private _currentChannel = [_radioId] call acre_api_fnc_getRadioChannel;
if (typeName _currentChannel == "STRING") then {
	_currentChannel = parseNumber _currentChannel;
};
if (typeName _currentChannel != "SCALAR") then {
	_currentChannel = 1;
};
if (_currentChannel < 1) then {
	_currentChannel = 1;
};

// Get base class for channel count and name lookup
private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;

// PRC-148 / PRC-343: no ACRE API reliably exposes the total programmed channel count.
// Strategy: request the change, then read back what ACRE actually accepted.
// If the channel didn't move we've hit a boundary — wrap to the other end.
// To find the max channel, probe with 999; ACRE clamps to the actual maximum.
// Both radios share a 16-per-group/block structure; only the display label differs.
if ((_baseClass find "ACRE_PRC148" >= 0) || (_baseClass find "ACRE_PRC343" >= 0)) then {
	[_radioId, (_currentChannel + _increment)] call acre_api_fnc_setRadioChannel;
	private _newChannel = [_radioId] call acre_api_fnc_getRadioChannel;
	
	// ACRE rejected the change (boundary hit) — wrap around
	if (_newChannel == _currentChannel) then {
		if (_increment > 0) then {
			// At the top: wrap to channel 1
			[_radioId, 1] call acre_api_fnc_setRadioChannel;
		} else {
			// At the bottom: probe for the max by requesting an out-of-range high value
			[_radioId, 999] call acre_api_fnc_setRadioChannel;
		};
		_newChannel = [_radioId] call acre_api_fnc_getRadioChannel;
	};
	
	private _channelName = [_radioId, _newChannel] call AcreRadioManager_fnc_getChannelName;
	private _blkOrGrp = floor((_newChannel - 1) / 16) + 1;
	private _localCh = ((_newChannel - 1) mod 16) + 1;
	private _prefix = if (_baseClass find "ACRE_PRC343" >= 0) then {"Bl"} else {"Gr"};
	_displayCtrl ctrlSetText format ["%1 %2, Ch %3, %4", _prefix, _blkOrGrp, _localCh, _channelName];
	
	[] call AcreRadioManager_fnc_getRadioList;
	if (uiNamespace getVariable ["AcreRadioManager_previewIsLive", true]) then {
		[] call AcreRadioManager_fnc_updateRadioPreview;
	};
	
	true
} else {

// Get number of channels from cache or config
private _channelCache = missionNamespace getVariable ["AcreRadioManager_channelCountCache", createHashMap];
private _maxChannel = _channelCache getOrDefault [_baseClass, 0];

if (_maxChannel == 0) then {
	// PRC-117F and PRC-152 support up to 99 channels by design
	if ((_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0)) then {
		_maxChannel = 99;
	} else {
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
		
		// Count programmed channels by iterating preset data (channels are 1-based).
		// Use the active preset name so the count matches the actual mission configuration.
		if (_maxChannel == 0) then {
			private _preset = [_baseClass] call acre_api_fnc_getPreset;
			for "_i" from 1 to 100 do {
				private _testData = [_baseClass, _preset, _i] call acre_api_fnc_getPresetChannelData;
				if (isNil "_testData" || { typeName _testData != "HASHMAP" } || { count _testData == 0 }) exitWith {
					_maxChannel = _i - 1;
				};
			};
		};
		
		// Final fallback to 16 if still nothing found
		if (_maxChannel == 0) then {
			_maxChannel = 16;
		};
	};
	
	// Cache the result
	_channelCache set [_baseClass, _maxChannel];
	missionNamespace setVariable ["AcreRadioManager_channelCountCache", _channelCache];
};

// Calculate new channel with wrap-around
private _newChannel = _currentChannel + _increment;

if (_newChannel < 1) then { _newChannel = _maxChannel; };
if (_newChannel > _maxChannel) then { _newChannel = 1; };

// Only update if channel actually changed
if (_newChannel != _currentChannel) then {
	[_radioId, _newChannel] call acre_api_fnc_setRadioChannel;
	
	private _channelName = [_radioId, _newChannel] call AcreRadioManager_fnc_getChannelName;
	_displayCtrl ctrlSetText format ["%1: %2", _newChannel, _channelName];
	
	[] call AcreRadioManager_fnc_getRadioList;
	if (uiNamespace getVariable ["AcreRadioManager_previewIsLive", true]) then {
		[] call AcreRadioManager_fnc_updateRadioPreview;
	};
	
	true
} else {
	true
};

}; // end non-PRC148 branch
