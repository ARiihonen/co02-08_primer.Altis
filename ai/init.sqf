//this bit is for all AI scripts you want to run at mission start. Maybe you want to spawn in dudes or something.
{
	if (!isPlayer _x) then {
		_x execVM "ai\gear.sqf";
	};
} forEach allUnits;

buildings = [];
for '_i' from 1 to 24 do {
	buildings set [count buildings, call compile format ["building_%1", _i] ];
};
tension_newWaypoints = {
	_grp = _this select 0;
	_buildings = _this select 1;
	
	hint format ["Giving new waypoints to %1", _grp];
	
	_building = _buildings select floor random count _buildings;
	_positions = [_building] call BIS_fnc_buildingPositions;
	_entryPos = getPos _building;
	
	_type = "MOVE";
	_behaviour = "SAFE";
	_speed = "LIMITED";
	_formation = "COLUMN";
	_combatMode = "RED";
	
	_wpOne = _grp addWaypoint [_entryPos, 0];
	_wpOne setWaypointType _type;
	_wpOne setWaypointBehaviour _behaviour;
	_wpOne setWaypointSpeed _speed;
	_wpOne setWaypointFormation _formation;
	_wpOne setWaypointCombatMode _combatMode;
	
	for '_i' from 1 to 4 do {
		_pos = _positions select floor random count _positions;
		_wp = _grp addWaypoint [_pos, 0];
		//_wp setWaypointStatements ["true", "hint 'Waypoint finished'"];
	};
	
	_wpLast = _grp addWaypoint [waypointPosition _wpOne, 0];
	_wpLast setWaypointType "CYCLE";
	
	/*
	_wp = _grp addWaypoint [_entryPos, 0];
	_wp setWaypointStatements ["true", format ["hint 'Waypoints finished'; [(group _this), %1] call tension_newWaypoints", _buildings] ];
	*/
};

[group target, buildings] call tension_newWaypoints;