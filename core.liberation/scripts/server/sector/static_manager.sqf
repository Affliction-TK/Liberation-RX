params ["_sector", "_count"];

if (_count == 0) exitWith {};
if (_count > 1) then {
	sleep 3;
	[_sector, _count - 1] spawn static_manager;
};

// Create
private _radius = GRLIB_capture_size - 20;
if (_sector in sectors_bigtown) then { _radius = _radius * 1.4 };

private _spawn_pos = (markerPos _sector) getPos [_radius, random 360];
if (surfaceIsWater _spawn_pos) exitWith {};
_spawn_pos set [2, 0.5];

// Static
private _vehicle = createVehicle [selectRandom opfor_statics, _spawn_pos, [], 0, "None"];
_vehicle addMPEventHandler ["MPKilled", {_this spawn kill_manager}];
_vehicle addEventHandler ["HandleDamage", { _this call damage_manager_static }];
_vehicle setVariable ["R3F_LOG_disabled", true, true];
_vehicle setVariable ["GRLIB_vehicle_owner", "server", true];
sleep 1;

// Crew
[_vehicle, GRLIB_side_enemy] call F_forceCrew;
private _grp = group (gunner _vehicle);
sleep 1;

// Spotters
_unit = _grp createUnit [opfor_spotter, _vehicle, [], 3, "None"];
[_unit] joinSilent _grp;
_unit addMPEventHandler ["MPKilled", {_this spawn kill_manager}];
sleep 0.5;
_unit = _grp createUnit [opfor_spotter, _vehicle, [], 3, "None"];
[_unit] joinSilent _grp;
_unit addMPEventHandler ["MPKilled", {_this spawn kill_manager}];

_vehicle setVariable ["GRLIB_vehicle_gunner", units _grp];
_vehicle setVariable ["GRLIB_vehicle_reward", true, true];

[_vehicle] call F_aceLockVehicle;

diag_log format [ "Spawn Static Weapon (%1) on sector %2 at %3", typeOf _vehicle, _sector, time ];

_spawn_pos = getPos _vehicle;

// AI (managed by manage_static.sqf)
[_grp, _spawn_pos, 20] spawn patrol_ai;

private _hc = [] call F_lessLoadedHC;
if (isDedicated && !isNull _hc) exitWith {
	_grp setGroupOwner (owner _hc);
	sleep 1;
};

// Cleanup
waitUntil {
	sleep 30;
	([_vehicle, GRLIB_sector_size, GRLIB_side_friendly] call F_getUnitsCount == 0 && !(_sector in (active_sectors + A3W_sectors_in_use)))
};
if (!isNull _vehicle) then { deleteVehicle _vehicle };
{ deleteVehicle _x } forEach (units _grp);
deleteGroup _grp;