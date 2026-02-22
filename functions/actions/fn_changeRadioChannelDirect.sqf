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
private _channelCache = missionNamespace getVariable ["AcreRadioManager_channelCountCache", createHashMap];
private _maxChannel = _channelCache getOrDefault [_baseClass, 0];

if (_maxChannel == 0) then {
	// Special handling for known multi-channel radios
	if ((_baseClass find "ACRE_PRC117F" >= 0) || (_baseClass find "ACRE_PRC152" >= 0)) then {
		_maxChannel = 99;
	} else {
		// PRC-148: its CfgWeapons numChannels = 16 (channels per group knob), not the total
		// programmed channel count. Use getPresetData to read the actual channels array length.
		if (_baseClass find "ACRE_PRC148" >= 0) then {
			private _preset = [_baseClass] call acre_api_fnc_getPreset;
			private _presetData = [_baseClass, _preset] call acre_api_fnc_getPresetData;
			if (!isNil "_presetData" && { typeName _presetData == "HASHMAP" } && { "channels" in _presetData }) then {
				_maxChannel = count (_presetData get "channels");
			};
			if (_maxChannel == 0) then { _maxChannel = 16; }; // fallback
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
		};

		// Count programmed channels by iterating preset data (channels are 1-based).
		// Use the active preset name so the count matches the actual mission configuration.
		// ACRE returns an empty HashMap {} (not nil) for channels beyond the programmed count.
		if (_maxChannel == 0) then {
			private _preset = [_baseClass] call acre_api_fnc_getPreset;
			for "_i" from 1 to 100 do {
				private _testData = [_baseClass, _preset, _i] call acre_api_fnc_getPresetChannelData;
				// ACRE returns a Location type (not nil/HashMap) for channels beyond the programmed count
				if (isNil "_testData" || { typeName _testData != "HASHMAP" } || { count _testData == 0 }) exitWith {
					_maxChannel = _i - 1;
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
	missionNamespace setVariable ["AcreRadioManager_channelCountCache", _channelCache];
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
