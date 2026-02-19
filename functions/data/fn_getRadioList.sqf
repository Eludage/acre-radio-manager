/*
 * Author: Eludage
 * Retrieves detailed information for all ACRE radios in player's inventory and stores in uiNamespace.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Array of Arrays - Each array contains radio information [id, icon, name, ptt, channel, channelName, frequency, ear, volume, isOn]
 * Returns empty string "" if no radios found
 *
 * Example:
 * private _radios = [] call AcreRadioManager_fnc_getRadioList;
 */

// Color constants for formatting
#define COLOR_WHITE "#FFFFFF"
#define COLOR_GREY "#CCCCCC"
#define COLOR_YELLOW "#FFFF00"

// Check if ACRE is loaded
if (isNil "acre_api_fnc_getCurrentRadioList") exitWith {
	uiNamespace setVariable ["AcreRadioManager_currentRadios", ""];
	""
};

// Get all radios in player's inventory
private _radios = [] call acre_api_fnc_getCurrentRadioList;

// If no radios, set variable to empty string and exit
if (count _radios == 0) exitWith {
	uiNamespace setVariable ["AcreRadioManager_currentRadios", ""];
	""
};

// Get PTT assignments - ACRE returns flat array where index = PTT number
// [radio1, radio2, radio3] means radio1=PTT1, radio2=PTT2, radio3=PTT3
private _pttAssignments = [] call acre_api_fnc_getMultiPushToTalkAssignment;

// Extract individual PTT radios from flat array
private _ptt1Radio = if (!isNil "_pttAssignments" && {typeName _pttAssignments == "ARRAY"} && {count _pttAssignments > 0}) then { _pttAssignments select 0 } else { "" };
private _ptt2Radio = if (!isNil "_pttAssignments" && {typeName _pttAssignments == "ARRAY"} && {count _pttAssignments > 1}) then { _pttAssignments select 1 } else { "" };
private _ptt3Radio = if (!isNil "_pttAssignments" && {typeName _pttAssignments == "ARRAY"} && {count _pttAssignments > 2}) then { _pttAssignments select 2 } else { "" };

// Process each radio and build array
private _radioData = [];

{
	private _radioId = _x;
	
	// Get radio base class (e.g., "ACRE_PRC343" from "ACRE_PRC343_ID_1")
	private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;
	
	// Get display name from config (e.g., "AN/PRC-343")
	private _displayName = getText (configFile >> "CfgWeapons" >> _baseClass >> "displayName");
	
	// Get radio icon/picture from config
	private _icon = getText (configFile >> "CfgWeapons" >> _baseClass >> "picture");
	
	// Determine PTT assignment (0 = none, 1-3 = PTT keys)
	// Check if radio ID matches any PTT slot
	private _ptt = 0;
	if (_radioId == _ptt1Radio) then { _ptt = 1; };
	if (_radioId == _ptt2Radio) then { _ptt = 2; };
	if (_radioId == _ptt3Radio) then { _ptt = 3; };
	
	// Get current channel number (1-based)
	private _channel = [_radioId] call acre_api_fnc_getRadioChannel;
	// Convert to number if string, default to 1 if nil or invalid
	if (typeName _channel == "STRING") then {
		_channel = parseNumber _channel;
	};
	if (typeName _channel != "SCALAR") then {
		_channel = 1;
	};
	if (_channel < 1) then {
		_channel = 1;
	};
	
	// Get channel name via helper
	private _channelName = [_radioId, _channel] call AcreRadioManager_fnc_getChannelName;
	
	// Also fetch channel data for frequency lookup below
	private _channelIndex = (_channel - 1) max 0;
	private _channelData = [_baseClass, "default", _channelIndex] call acre_api_fnc_getPresetChannelData;
	
	// Get frequency in MHz - try getting from channel data first
	private _frequency = 0;
	if (!isNil "_channelData") then {
		if (typeName _channelData == "LOCATION") then {
			// Extract from location namespace (note: key is lowercase "frequencytx")
			_frequency = _channelData getVariable ["frequencytx", 0];
		} else {
			if (typeName _channelData == "HASHMAP") then {
				_frequency = _channelData getOrDefault ["frequencyTX", 0];
			};
		};
	};
	// Fallback to direct API call
	if (_frequency == 0) then {
		private _freqRaw = [_radioId] call acre_api_fnc_getRadioFrequency;
		if (!isNil "_freqRaw") then {
			if (typeName _freqRaw == "STRING") then {
				_frequency = parseNumber _freqRaw;
			} else {
				if (typeName _freqRaw == "SCALAR") then {
					_frequency = _freqRaw;
				};
			};
		};
	};
	
	// Get spatial positioning and convert to ear string
	private _spatial = [_radioId] call acre_api_fnc_getRadioSpatial;
	private _ear = "center";
	if (!isNil "_spatial") then {
		if (typeName _spatial == "STRING") then {
			_spatial = toUpper _spatial;
			if (_spatial == "LEFT") then { _ear = "left"; };
			if (_spatial == "RIGHT") then { _ear = "right"; };
			if (_spatial == "CENTER" || _spatial == "CENTRE") then { _ear = "center"; };
		} else {
			// Handle numeric spatial
			if (typeName _spatial == "SCALAR") then {
				if (_spatial < -0.5) then { _ear = "left"; };
				if (_spatial > 0.5) then { _ear = "right"; };
			};
		};
	};
	
	// Get volume (0.0 to 1.0)
	private _volume = [_radioId] call acre_api_fnc_getRadioVolume;
	// Convert to number if string or nil
	if (isNil "_volume") then {
		_volume = 0.5;
	} else {
		if (typeName _volume == "STRING") then {
			_volume = parseNumber _volume;
		};
	};
	
	// Check if radio is powered on
	private _isOn = [_radioId] call acre_api_fnc_getRadioOnOffState;
	// Convert to boolean (ACRE returns 1 for ON, 0 for OFF)
	if (isNil "_isOn") then {
		_isOn = true; // Assume on if can't determine
	} else {
		if (typeName _isOn == "SCALAR") then {
			_isOn = (_isOn == 1); // Convert 1/0 to true/false
		} else {
			if (typeName _isOn != "BOOL") then {
				_isOn = true; // Assume on if unexpected type
			};
		};
	};
	
	// Build radio info array
	// [id, icon, name, ptt, channel, channelName, frequency, ear, volume, isOn]
	private _radioInfo = [
		_radioId,        // 0: Radio instance ID
		_icon,           // 1: Icon path
		_displayName,    // 2: Display name (type)
		_ptt,            // 3: PTT assignment (0-3)
		_channel,        // 4: Channel number
		_channelName,    // 5: Channel name/label
		_frequency,      // 6: Frequency in MHz
		_ear,            // 7: Ear assignment
		_volume,         // 8: Volume (0.0-1.0)
		_isOn            // 9: Power state
	];
	
	_radioData pushBack _radioInfo;
	
} forEach _radios;

// Store in uiNamespace for access by other functions
uiNamespace setVariable ["AcreRadioManager_currentRadios", _radioData];
// Inventory changes always sync the preview state
uiNamespace setVariable ["AcreRadioManager_previewRadios", _radioData];

// Return the radio data array
_radioData
