/*
This runs on the server machine after objects have initialised in the map. Anything the server needs to set up before the mission is started is set up here.
*/

//set respawn tickets to 0
[missionNamespace, 1] call BIS_fnc_respawnTickets;
[missionNamespace, -1] call BIS_fnc_respawnTickets;

//Convert building number lists into building object lists
_new_red = [];
{
	_building = call compile format ["building_%1", _x];
	_new_red set [count _new_red, _building];
} forEach buildings_red;
buildings_red = _new_red;

_new_grn = [];
{
	_building = call compile format ["building_%1", _x];
	_new_grn set [count _new_grn, _building];
} forEach buildings_grn;
buildings_grn = _new_grn;

_new_civ = [];
{
	_building = call compile format ["building_%1", _x];
	_new_civ set [count _new_civ, _building];
} forEach buildings_civ;
buildings_civ = _new_civ;

//Randomise civilian faction amount based on building amount
_civ_groups = [1];
switch (count buildings_civ) do {
	case 2: {
		if (random 1 < 0.5) then {
			_civ_groups = [1,2];
		};
	};
	
	case 3: {
		_rand = random 1;

		if (_rand < 0.3) then {
			_civ_groups = [1,2,3];
		} else {
			if (_rand < 0.6) then {
				_civ_groups = [1,2];
			};
		};
	};
};

//Initialise relevant lists for each civilian faction
_civ_factions = [];
{
	call compile format ["buildings_civ_%1 = [];", _x];
	call compile format ["patrolgroups_civ_%1 = [];", _x];
	call compile format ["sentries_civ_%1 = [];", _x];
	call compile format ["units_civ_%1 = [];", _x];
	
	_civ_factions set [count _civ_factions, format ["civ_%1", _x] ];
} forEach _civ_groups;

{
	_buildinglists = [];
	{
		_buildinglists set [count _buildinglists, call compile format ["buildings_%1", _x] ];
	} forEach _civ_factions;
	
	
} forEach buildings_civ;

{

} forEach patrolgroups_civ;

{

} forEach sentries_civ;

//Style randomisation for factions
_factions = ["red", "grn"] + _civ_factions;
_styles = ["shemags", "leathers", "military", "sandals", "class", "terrors"];
{
	_style = _styles select floor random count _styles;
	_styles = _styles - [_style];
	
	missionNamespace setVariable [ format["style_%1", _faction], _style ];
	
	{
		_x setVariable ["gang_style", _style];
	} forEach ( call compile format ["units_%1", _faction] );
} forEach _factions;

//Task setting: ["TaskName", locality, ["Description", "Title", "Marker"], target, "STATE", priority, showNotification, true] call BIS_fnc_setTask;
if (playersNumber west > 4) then {
	["MainTask", true, ["Retrieve the X", "Retrieve X", ""], nil, "ASSIGNED", 0, false, true] call BIS_fnc_setTask;
} else {
	["MainTask", true, ["Take out the gang member with the X", "Kill Target", ""], nil, "ASSIGNED", 0, false, true] call BIS_fnc_setTask;
};

//Spawns a thread that will run a loop to keep an eye on mission progress and to end it when appropriate, checking which ending should be displayed.
_progress = [] spawn {
	
	//Init all variables you need in this loop
	_ending = false;
	_players_dead = false;
	_players_away = false;
	
	objective_owner = target;
	objective_achieved = false;
	
	//handledamage for each AI
	

	//Starts a loop to check mission status every second, update tasks, and end mission when appropriate
	while {!_ending} do {
		
		//Mission ending condition check
		if ( _players_dead || (_players_away && objective_retreived) ) then {
			_ending = true;
			
			if (playersNumber west > 4) then {
				if (objective_retreived) then {
					["MainTask", "SUCCEEDED", false] call BIS_fnc_taskSetState;
				} else {
					["MainTask", "FAILED", false] call BIS_fnc_taskSetState;
				};
				
			} else {
			
				if (!alive target) then {
					["MainTask", "SUCCEEDED", false] call BIS_fnc_taskSetState;
				} else {
					["MainTask", "FAILED", false] call BIS_fnc_taskSetState;
				};
			};
			
			sleep 15;
			
			//Runs end.sqf on everyone. For varying mission end states, calculate the correct one here and send it as an argument for end.sqf
			[[[],"end.sqf"], "BIS_fnc_execVM", true, false] spawn BIS_fnc_MP;
		};
		
		//Updating tasks example: ["TaskName", "STATE", false] call BIS_fnc_taskSetState;
		//Custom task update notification: [ ["NotificationName", ["Message"]], "BIS_fnc_showNotification"] call BIS_fnc_MP;
		
		/*
		//Sets _players_dead as true if nobody is still alive
		_players_dead = true;
		{
			if (alive _x) then {
				_players_dead = false;
			};
		} forEach playableUnits;
		
		//Sets players_away as true if nobody is in the area and the objective has been retreived
		_players_away = true;
		{
			if ( (_x in list trigger_ao) && alive _x ) then {
				_players_away = false;
			};
		} forEach playableUnits;
		*/
		
	};
};

//client inits wait for serverInit to be true before starting, to make sure all variables the server sets up are set up before clients try to refer to them (which would cause errors)
serverInit = true;
publicVariable "serverInit";