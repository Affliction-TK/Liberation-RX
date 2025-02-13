if (!isServer) exitwith {};
#include "sideMissionDefines.sqf"

private ["_townName", "_marker_mission"];

_setupVars = {
	_missionType = "STR_AMMODELI";
	_locationsArray = [LRX_MissionMarkersMil] call checkSpawn;
	_ignoreAiDeaths = true;
};

_setupObjects = {
	_townName = markerText _missionLocation;
	_missionPos = [(markerpos _missionLocation)] call F_findSafePlace;
	if (count _missionPos == 0) exitWith {
    	diag_log format ["--- LRX Error: side mission %1, cannot find spawn point!", localize _missionType];
    	false;
	};
	_aiGroup = createGroup [GRLIB_side_civilian, true];
	private _man1 = _aiGroup createUnit ["C_Marshal_F", _missionPos, [], 0, "NONE"];
	[_man1] joinSilent _aiGroup;
	_man1 setVariable ['GRLIB_can_speak', true, true];
	_man1 setVariable ["GRLIB_A3W_Mission_DL4", true, true];
	_man1 setVariable ["acex_headless_blacklist", true, true];
	_man1 allowDamage false;
	[_man1, "LHD_krajPaluby"] spawn F_startAnimMP;
	_marker_mission = ["DEL1", _missionPos] call createMissionMarkerCiv;
	_missionHintText = ["STR_AMMODELI_MESSAGE1", sideMissionColor, _townName];
	true;
};

_waitUntilMarkerPos = nil;
_waitUntilExec = nil;
_waitUntilCondition = nil;
_waitUntilSuccessCondition = { ([_missionPos, basic_weapon_typename, 3] call checkMissionItems) };

_failedExec = {
	// Mission failed
	{ [_x, -2] call F_addReput } forEach (AllPlayers - (entities "HeadlessClient_F"));
	deleteMarker _marker_mission;
	_failedHintMessage = ["STR_AMMODELI_MESSAGE2", sideMissionColor, _townName];
	A3W_delivery_failed = A3W_delivery_failed + 1;
};

_successExec = {
	// Mission completed
	private _winner = ([_missionPos, 50] call F_getNearbyPlayers) select 0;
	if (!isNil "_winner") then {
		private _bonus = round (22 + random 25);
        [_bonus] remoteExec ["remote_call_a3w_info", owner _winner];
        [_winner, _bonus] call F_addScore;
		[_winner, 5] call F_addReput;
	};
	_successHintMessage = ["STR_AMMODELI_MESSAGE3", sideMissionColor];
	deleteMarker _marker_mission;
	A3W_delivery_failed = 0;
};

_this call sideMissionProcessor;
