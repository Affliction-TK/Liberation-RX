params ["_unit"];
private _commanderobj = allPlayers select {( typeOf _x == commander_classname )};
(_unit in _commanderobj);
