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

// Get number of channels from cache or config
private _channelCache = uiNamespace getVariable ["AcreRadioManager_channelCountCache", createHashMap];
private _maxChannel = _channelCache getOrDefault [_baseClass, 0];

if (_maxChannel == 0) then {
	// Special handling for known multi-channel radios
	if ((_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0)) then {
		_maxChannel = 99;
	} else {
		// Not in cache, look up from config
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
		
		// Final fallback to 16 if still nothing found
		if (_maxChannel == 0) then {
			_maxChannel = 16;
		};
	};
	
	// Cache the result
	_channelCache set [_baseClass, _maxChannel];
	uiNamespace setVariable ["AcreRadioManager_channelCountCache", _channelCache];
	
	diag_log format ["Cached channel count for %1: %2 channels", _baseClass, _maxChannel];
};

// Calculate new channel
private _newChannel = _currentChannel + _increment;

// Wrap around at boundaries (1 to maxChannel)
private _minChannel = 1;

if (_newChannel < _minChannel) then {
	_newChannel = _maxChannel;
};
if (_newChannel > _maxChannel) then {
	_newChannel = _minChannel;
};

// Only update if channel actually changed
if (_newChannel != _currentChannel) then {
	// Set new channel via ACRE API
	private _result = [_radioId, _newChannel] call acre_api_fnc_setRadioChannel;
	
	diag_log format ["Changed radio %1 channel from %2 to %3 (max: %4, result: %5)", _radioId, _currentChannel, _newChannel, _maxChannel, _result];
	
	// Get channel name - ensure channel index is valid (0-based, so max is _maxChannel - 1)
	private _channelName = "";
	private _channelIndex = (_newChannel - 1) min (_maxChannel - 1) max 0;
	private _channelData = [_baseClass, "default", _channelIndex] call acre_api_fnc_getPresetChannelData;
	if (!isNil "_channelData") then {
		if (typeName _channelData == "LOCATION") then {
			_channelName = _channelData getVariable ["description", ""];
		} else {
			if (typeName _channelData == "HASHMAP") then {
				_channelName = _channelData getOrDefault ["label", ""];
			};
		};
	};
	if (_channelName == "") then {
		_channelName = format ["Channel %1", _newChannel];
	};
	
	// Update display control
	_displayCtrl ctrlSetText format ["%1: %2", _newChannel, _channelName];
	
	true
} else {
	// Already at min/max, no change needed
	true
};
