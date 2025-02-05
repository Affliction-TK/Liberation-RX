params [ "_position", "_distance", "_side" ];

if (_side == GRLIB_side_friendly) exitWith {
    private _countblufor = (units GRLIB_side_friendly - units group chimeraofficer);
    {
        (alive _x) && !(captive _x) &&
        (_x distance2D _position < _distance) &&
        (getPosATL _x select 2 < 150) && (speed (vehicle _x) <= 80) &&
        !(_x getVariable ["GRLIB_mission_AI", false])
    } count _countblufor;
};

if (_side == GRLIB_side_enemy) exitWith {
    {
        (alive _x) && !(captive _x) &&
        (_x distance2D _position < _distance) &&
        (getPosATL _x select 2 < 150) && (speed (vehicle _x) <= 80) &&
        !(_x getVariable ["GRLIB_mission_AI", false]) &&
        !(_x getVariable ["GRLIB_is_prisoner", false]) &&
        !(_x getVariable ["ACE_isUnconscious", false])
    } count (units GRLIB_side_enemy);
};

if (_side == GRLIB_side_civilian) exitWith {
    {
        (alive _x) && !(captive _x) &&
        (_x distance2D _position < _distance) &&
        (isNil {_x getVariable "GRLIB_vehicle_owner"}) &&
        (isNil {_x getVariable "PAR_Grp_ID"})
    } count (units GRLIB_side_civilian);
};

0;
