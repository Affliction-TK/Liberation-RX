params [ "_sector", "_radius", "_number" ];

if (_number == 0) exitWith {};
if (_number >= 1) then {
	sleep 4;
	[_sector, _radius, _number - 1] spawn ied_trap_manager;
};

private _activation_radius = 3;
private _infantry_trigger = 1;
private _hostilecount = 0;

private _ied_type = selectRandom GRLIB_ide_traps;
private _ied_power = selectRandom [
	"SatchelCharge_Remote_Ammo",
	"DemoCharge_Remote_Ammo",
	"DemoCharge_Remote_Ammo",
	"DemoCharge_Remote_Ammo",
	"DemoCharge_Remote_Ammo",	
	"GrenadeHand",
	"GrenadeHand",	
	"GrenadeHand"
];

private _sector_pos = markerPos _sector;
private _ide_pos = (_sector_pos getPos [floor(random _radius), random(360)]) findEmptyPosition [0,20,"B_Quadbike_01_F"];
private _goes_boom = false;

if (count _ide_pos > 0 && random 100 < GRLIB_MineProbability) then {
	private _ied_obj = createVehicle [_ied_type, _ide_pos, [], 3, "None"];
	[_ied_obj] call F_clearCargo;
	_ied_obj allowDamage false;
	_ied_obj setVariable ["R3F_LOG_disabled", true, true];
	_ied_obj setVariable ["GRLIB_intel_search", true, true];
	_ied_obj setPos (getPos _ied_obj);
	_ied_obj enableSimulationGlobal false;
	_ide_pos = getPosATL _ied_obj;

	private _timeout = time + (60 * 60);
	if (floor random 2 == 0) exitWith {
		waitUntil { sleep 1; time > _timeout };
		deleteVehicle _ied_obj;
	};

	while { time < _timeout && !_goes_boom } do {
		sleep (1 + floor random 3);
		_hostilecount = [_ide_pos, _activation_radius] call F_getNearbyPlayers;
		if (count _hostilecount >= _infantry_trigger) then {
			sleep (floor random 4);
			[_ied_obj] spawn {
				params ["_obj"];
				sleep (floor random 3);
				for "_i" from 1 to 5 do {
					playSound3D ["A3\Missions_F_Oldman\Data\sound\beep.ogg", _obj, false, ATLToASL (getPosATL _obj), 4, 1, 100];
					sleep 0.5;
				};
			};
			sleep 2;
			private _explo = _ied_power createVehicle _ide_pos;
			_explo setDamage 1;

			stats_ieds_detonated = stats_ieds_detonated + 1;
			publicVariable "stats_ieds_detonated";
			_goes_boom = true;
		};
	};
	deleteVehicle _ied_obj;
};
