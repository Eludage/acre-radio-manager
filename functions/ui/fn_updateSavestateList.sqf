/*
 * Author: Eludage
 * Updates the savestate list in the Radio Preview Options section.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_updateSavestateList;
 *
 * IDC Naming Convention:
 * Each savestate entry gets a base IDC: 16700 + (index * 5)
 * - Entry 0 ("Last Presets"): 16700
 * - Entry 1: 16705
 * - Entry 2: 16710, etc.
 * - Maximum 20 savestates (IDC range: 16700-16799)
 * - Edit field:   baseIDC + 0
 * - Load button:   baseIDC + 1
 * - Save button:   baseIDC + 2
 * - Apply button:  baseIDC + 3
 */

// Color constants
#define COLOR_GREY_15 [0.15, 0.15, 0.15, 1]
#define COLOR_GREY_30 [0.3, 0.3, 0.3, 1]
#define COLOR_GREY_40 [0.4, 0.4, 0.4, 1]
#define COLOR_GREY_50 [0.5, 0.5, 0.5, 1]
#define COLOR_WHITE_100 [1, 1, 1, 1]

// Size constants (reference: 16:9 small interface, safezoneW ≈ 0.86)
// _scale is derived from the savestate group's usable width (0.17 * safezoneW minus the
// 0.021 VScrollbar) divided by the sum of all unscaled control widths in a row (0.39).
private _scale = (0.17 * safezoneW - 0.021) / 0.39;
private _btnW        = 0.06  * _scale;
private _btnH        = 0.06  * _scale;
private _nameFieldW  = 0.17  * _scale;
private _entryPad    = 0.01  * _scale;
private _itemH       = 0.08  * _scale;

private _display = findDisplay 16000;
if (isNull _display) exitWith {
	diag_log "ERROR: Radio Manager dialog not found";
	false
};

private _group = _display displayCtrl 16030;
if (isNull _group) exitWith {
	diag_log "ERROR: Radio Preview Options group not found";
	false
};

// Get savestates from profileNamespace
private _savestates = profileNamespace getVariable ["AcreRadioManager_savestates", createHashMap];

// Build list of savestate names (always include "Last Presets" first)
private _savestateNames = ["Last Presets"];
{
	if (_x != "Last Presets") then {
		_savestateNames pushBack _x;
	};
} forEach (keys _savestates);

// Store current savestate names in uiNamespace for other functions
uiNamespace setVariable ["AcreRadioManager_currentSavestateNames", _savestateNames];

// Limit to maximum 20 savestates to prevent IDC overflow
private _maxSavestates = 20 min (count _savestateNames);
if (count _savestateNames > _maxSavestates) then {
	_savestateNames = _savestateNames select [0, _maxSavestates];
	[format ["Savestate limit reached! Only showing first %1 of %2 savestates.", _maxSavestates, count _savestateNames]] call AcreRadioManager_fnc_showHint;
};

// Get currently selected savestate index (if any)
private _selectedIndex = uiNamespace getVariable ["AcreRadioManager_selectedSavestateIndex", -1];

// Clear existing controls from the group
private _controls = allControls _group;
{
	ctrlDelete _x;
} forEach _controls;

private _yOffset = 0.01 * _scale;

{
	private _savestateName = _x;
	private _index = _forEachIndex;
	private _baseIDC = 16700 + (_index * 5);
	
	private _yRow = _yOffset;
	private _xPos = 0.01 * _scale;
	
	// Determine if this is the special "Last Presets" entry
	private _isLastPresets = (_savestateName == "Last Presets");
	
	// === NAME EDIT FIELD ===
	private _ctrlEdit = _display ctrlCreate ["ARM_RscEdit", _baseIDC + 0, _group];
	_ctrlEdit ctrlSetPosition [_xPos, _yRow, _nameFieldW, _btnH];
	_ctrlEdit ctrlSetText _savestateName;
	_ctrlEdit ctrlSetTextColor COLOR_WHITE_100;
	_ctrlEdit ctrlSetBackgroundColor COLOR_GREY_15;
	_ctrlEdit ctrlEnable (!_isLastPresets); // Disable for "Last Presets"
	_ctrlEdit ctrlCommit 0;
	
	// Store index for rename handler
	_ctrlEdit setVariable ["savestateIndex", _index];
	_ctrlEdit setVariable ["oldName", _savestateName];
	
	// Add handler to track selection (for Remove button)
	_ctrlEdit ctrlAddEventHandler ["MouseButtonDown", {
		params ["_ctrl", "_button"];
		if (_button == 0) then { // Left click
			private _selIndex = _ctrl getVariable ["savestateIndex", -1];
			private _oldIndex = uiNamespace getVariable ["AcreRadioManager_selectedSavestateIndex", -1];
			uiNamespace setVariable ["AcreRadioManager_selectedSavestateIndex", _selIndex];
			
			// Update selection highlight without rebuilding entire list
			private _ehDisplay = findDisplay 16000;
			if (!isNull _ehDisplay) then {
				private _ehGroup = _ehDisplay displayCtrl 16030;
				if (!isNull _ehGroup) then {
					// Unhighlight old selection
					if (_oldIndex >= 0) then {
						private _oldCtrl = _ehDisplay displayCtrl (16700 + (_oldIndex * 5));
						if (!isNull _oldCtrl) then {
							_oldCtrl ctrlSetBackgroundColor [0.15, 0.15, 0.15, 1];
							_oldCtrl ctrlCommit 0;
						};
					};
					// Highlight new selection
					_ctrl ctrlSetBackgroundColor [0.3, 0.3, 0.3, 1];
					_ctrl ctrlCommit 0;
				};
			};
		};
	}];
	
	// Add handler to rename savestate when edit field loses focus
	if (!_isLastPresets) then {
		_ctrlEdit ctrlAddEventHandler ["KillFocus", {
			params ["_ctrl"];
			private _oldName = _ctrl getVariable ["oldName", ""];
			private _newName = ctrlText _ctrl;
			
			if (_newName != "" && _newName != _oldName) then {
				[_oldName, _newName] call AcreRadioManager_fnc_renameSavestate;
			};
		}];
	};
	
	_xPos = _xPos + _nameFieldW + _entryPad;
	
	// === LOAD BUTTON ===
	private _ctrlLoad = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 1, _group];
	_ctrlLoad ctrlSetPosition [_xPos, _yRow, _btnW, _btnH];
	_ctrlLoad ctrlSetText "Load";
	_ctrlLoad ctrlSetTextColor COLOR_WHITE_100;
	_ctrlLoad ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlLoad ctrlCommit 0;
	
	// Store savestate name for load handler
	_ctrlLoad setVariable ["savestateName", _savestateName];
	_ctrlLoad ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _name = _ctrl getVariable ["savestateName", ""];
		if (_name != "") then {
			[_name] call AcreRadioManager_fnc_loadSavestate;
		};
	}];
	
	_xPos = _xPos + _btnW + _entryPad;
	
	// === SAVE BUTTON ===
	private _ctrlSave = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 2, _group];
	_ctrlSave ctrlSetPosition [_xPos, _yRow, _btnW, _btnH];
	_ctrlSave ctrlSetText "Save";
	_ctrlSave ctrlSetTextColor COLOR_WHITE_100;
	_ctrlSave ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlSave ctrlEnable (!_isLastPresets); // Disable for "Last Presets"
	_ctrlSave ctrlCommit 0;
	
	// Store savestate name for save handler
	_ctrlSave setVariable ["savestateName", _savestateName];
	_ctrlSave ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _name = _ctrl getVariable ["savestateName", ""];
		if (_name != "") then {
			[_name] call AcreRadioManager_fnc_saveSavestate;
		};
	}];
	
	_xPos = _xPos + _btnW + _entryPad;
	
	// === APPLY BUTTON ===
	private _ctrlApply = _display ctrlCreate ["ARM_RscButtonGrey40", _baseIDC + 3, _group];
	_ctrlApply ctrlSetPosition [_xPos, _yRow, _btnW, _btnH];
	_ctrlApply ctrlSetText "Apply";
	_ctrlApply ctrlSetTextColor COLOR_WHITE_100;
	_ctrlApply ctrlSetBackgroundColor COLOR_GREY_40;
	_ctrlApply ctrlCommit 0;
	
	// Store savestate name for apply handler
	_ctrlApply setVariable ["savestateName", _savestateName];
	_ctrlApply ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _name = _ctrl getVariable ["savestateName", ""];
		if (_name != "") then {
			[_name] call AcreRadioManager_fnc_applySavestate;
		};
	}];
	
	// Highlight if this is the selected savestate
	if (_index == _selectedIndex) then {
		_ctrlEdit ctrlSetBackgroundColor COLOR_GREY_30;
	};
	
	_yOffset = _yOffset + _itemH;
	
} forEach _savestateNames;

true
