// Fix unit position when blocked in rock/ruins/object
// by pSiKO - (thanks Larrow)

params ["_unit"];

if (!alive _unit) exitWith {};
if (!isNull objectParent _unit) exitWith {};
if (speed vehicle _unit > 1) exitWith {};

private _spawnpos = (getPosATL _unit) vectorAdd [0,0,1];
private _curalt = _spawnpos select 2;
private _minalt = 5;
private _maxalt = 30;

if (_curalt >= _maxalt) exitWith {};
if (surfaceIsWater _spawnpos) exitWith {};

private _obstacle = count (nearestTerrainObjects [_unit, ["Tree","Small Tree"], 6]);
if (_obstacle > 0) exitWith {};

_obstacle = count (nearestTerrainObjects [_unit, ["House","Building"], 10]);
if (_obstacle > 0) then { _minalt = 2.3 };

private _minpos = ATLtoASL (_spawnpos vectorAdd [0,0,_minalt]);
private _maxpos = ATLtoASL (_spawnpos vectorAdd [0,0,_maxalt]);

if (lineIntersects [ATLtoASL _spawnpos, _minpos, _unit]) then {
	_unit allowDamage false;
	while { (lineIntersects [ATLtoASL _spawnpos, _maxpos, _unit]) && _curalt < _maxalt } do {
		_curalt = _curalt + 0.5;
		_spawnpos set [2, _curalt];
		sleep 0.1;
	};
	_unit setPosATL _spawnpos;
	_unit switchMove "AmovPercMwlkSrasWrflDf";
	_unit playMoveNow "AmovPercMwlkSrasWrflDf";
	sleep 3;
	_unit setHitPointDamage ["hitLegs", 0];
	_unit allowDamage true;	
};
