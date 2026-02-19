/*
 * Author: Eludage
 * Resolves the display name of a channel for a given radio and channel number.
 * Uses ACRE's preset channel data, falling back to "Channel N" if unavailable.
 *
 * Arguments:
 * 0: _radioId <STRING> - Radio instance ID (e.g., "ACRE_PRC343_ID_1")
 * 1: _channel <NUMBER> - Channel number (1-based)
 *
 * Return Value:
 * String: Resolved channel name, or "Channel N" as fallback
 *
 * Example:
 * ["ACRE_PRC152_ID_1", 2] call AcreRadioManager_fnc_getChannelName;
 */

params ["_radioId", "_channel"];

if (isNil "_radioId" || _radioId == "" || isNil "_channel" || typeName _channel != "SCALAR") exitWith {
	diag_log "ERROR: getChannelName - invalid arguments";
	format ["Channel %1", _channel]
};

private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;
private _channelIndex = (_channel - 1) max 0;
private _channelName = "";

private _channelData = [_baseClass, "default", _channelIndex] call acre_api_fnc_getPresetChannelData;
if (!isNil "_channelData") then {
	if (typeName _channelData == "LOCATION") then {
		_channelName = _channelData getVariable ["description", ""];
	} else {
		if (typeName _channelData == "HASHMAP") then {
			_channelName = _channelData getOrDefault ["label", ""];
		} else {
			if (typeName _channelData == "ARRAY" && {count _channelData > 0}) then {
				_channelName = str (_channelData select 0);
			};
		};
	};
};

if (_channelName == "") then {
	_channelName = format ["Channel %1", _channel];
};

_channelName
