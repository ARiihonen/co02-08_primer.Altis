//this bit is for all AI scripts you want to run at mission start. Maybe you want to spawn in dudes or something.
{
	if (side _x != west) then {
		_x execVM 'ai\gear.sqf';
	};
} forEach allUnits;

primer_patrolWaypoints = {
	_grp = _this select 0;
	_buildings = _this select 1;
	
	_building = _buildings select floor random count _buildings;
	_positions = [_building] call BIS_fnc_buildingPositions;
	_entryPos = getPos _building;
	
	_type = 'MOVE';
	_behaviour = 'SAFE';
	_speed = 'LIMITED';
	_formation = 'COLUMN';
	_combatMode = 'RED';
	
	_wpOne = _grp addWaypoint [_entryPos, 0];
	_wpOne setWaypointType _type;
	_wpOne setWaypointBehaviour _behaviour;
	_wpOne setWaypointSpeed _speed;
	_wpOne setWaypointFormation _formation;
	_wpOne setWaypointCombatMode _combatMode;
	_wpOne setWaypointStatements ['true', format ['{ _x setPos [(getPos _x select 0), (getPos _x select 1), (getPos %1 select 2)]; } forEach (units group this);', _building]];
	
	for '_i' from 1 to (1 + floor (random 4)) do {
		_pos = _positions select floor random count _positions;
		_wp = _grp addWaypoint [_pos, 0];
		_wp setWaypointTimeout [10, 15, 60];
	};
	
	_wpLast = _grp addWaypoint [waypointPosition _wpOne, 0];
	_wpLast setWaypointStatements ['true', format ['[(group this), %1] call primer_patrolWaypoints;', _buildings] ];
};

[group target, buildings_red] call primer_patrolWaypoints;
{
	_patrols = call compile format ['patrolgroups_%1', _x];
	{
		[_x, buildings_patrol] call primer_patrolWaypoints;
	} forEach _patrols;
	
	_guards = call compile format ['guards_%1', _x];
	{
		[_x, [(_x getVariable 'building')]] call primer_patrolWaypoints;
	} forEach _guards;
} forEach factions;