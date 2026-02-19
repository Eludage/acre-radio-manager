/*
 * Author: Eludage
 * Resolves the display name of a channel for a given radio and channel number.
 * Uses acre_api_fnc_getPresetChannelField with the universal field name "label",
 * which ACRE2 internally maps via fnc_mapChannelFieldName to the correct
 * per-radio field (e.g. "label" for PRC-148, "description" for PRC-152,
 * "name" for PRC-117F). Falls back to "Channel N" when no name is set.
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

private _channelName = "";

// acre_api_fnc_getPresetChannelField calls fnc_mapChannelFieldName internally,
// converting the universal "label" field to the radio-specific storage key:
//   ACRE_PRC148  → "label"
//   ACRE_PRC152  → "description"
//   ACRE_PRC117F → "name"
// Channel names programmed on the radio are stored in the active preset data.
private _baseClass = [_radioId] call acre_api_fnc_getBaseRadio;
private _preset = [_baseClass] call acre_api_fnc_getPreset;
private _fieldValue = [_baseClass, _preset, _channel, "label"] call acre_api_fnc_getPresetChannelField;

if (!isNil "_fieldValue" && { typeName _fieldValue == "STRING" } && { _fieldValue != "" }) then {
	_channelName = _fieldValue;
};

if (_channelName == "") then {
	_channelName = format ["Channel %1", _channel];
};

_channelName
