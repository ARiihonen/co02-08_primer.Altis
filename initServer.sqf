/*
This runs on the server machine after objects have initialised in the map. Anything the server needs to set up before the mission is started is set up here.
*/

//set respawn tickets to 0
[missionNamespace, 1] call BIS_fnc_respawnTickets;
[missionNamespace, -1] call BIS_fnc_respawnTickets;

//Add map markers for buildings and make triggers be nice
{
	_marker = createMarker [(format ['marker_building_%1', _x]), (call compile format ['building_%1', _x]) ];
	_marker setMarkerShape 'RECTANGLE';
	_marker setMarkerBrush 'SolidBorder';
	_marker setMarkerColor 'ColorOPFOR';
	_marker setMarkerAlpha 1;
	_trigger = (call compile format ['trigger_%1', _x]);
	
	_marker setMarkerDir (triggerArea _trigger select 2);
	_len_x = (triggerArea _trigger select 0);
	_len_y = (triggerArea _trigger select 1);
	_marker setMarkerSize [_len_x, _len_y];

	_trigger setTriggerActivation ['WEST', 'EAST D', false];
} forEach buildings_red;

{
	_marker = createMarker [(format ['marker_building_%1', _x]), (call compile format ['building_%1', _x]) ];
	_marker setMarkerShape 'RECTANGLE';
	_marker setMarkerBrush 'SolidBorder';
	_marker setMarkerColor 'ColorRED';
	_marker setMarkerAlpha 1;
	_trigger = (call compile format ['trigger_%1', _x]);
	
	_marker setMarkerDir (triggerArea _trigger select 2);
	_len_x = (triggerArea _trigger select 0);
	_len_y = (triggerArea _trigger select 1);
	_marker setMarkerSize [_len_x, _len_y];

	_trigger setTriggerActivation ['WEST', 'GUER D', false];
} forEach buildings_grn;

{
	_marker = createMarker [(format ['marker_building_%1', _x]), (call compile format ['building_%1', _x]) ];
	_marker setMarkerShape 'RECTANGLE';
	_marker setMarkerBrush 'SolidBorder';
	_marker setMarkerColor 'ColorRED';
	_marker setMarkerAlpha 1;
	_trigger = (call compile format ['trigger_%1', _x]);
	
	_marker setMarkerDir (triggerArea _trigger select 2);
	_len_x = (triggerArea _trigger select 0);
	_len_y = (triggerArea _trigger select 1);
	_marker setMarkerSize [_len_x, _len_y];

	_trigger setTriggerActivation ['WEST', 'CIV D', false];
} forEach buildings_civ;

{
	_marker = createMarker [(format ['marker_building_%1', _x]), (call compile format ['building_%1', _x]) ];
	_marker setMarkerShape 'RECTANGLE';
	_marker setMarkerBrush 'SolidBorder';
	_marker setMarkerColor 'ColorGrey';
	_marker setMarkerAlpha 1;
	_trigger = (call compile format ['trigger_%1', _x]);

	_marker setMarkerDir (triggerArea _trigger select 2);
	_len_x = (triggerArea _trigger select 0);
	_len_y = (triggerArea _trigger select 1);
	_marker setMarkerSize [_len_x, _len_y];
} forEach buildings_patrol;

//Convert building number lists into building object lists
_new_red = [];
{
	_building = call compile format ['building_%1', _x];
	_new_red set [count _new_red, _building];
} forEach buildings_red;
buildings_red = _new_red;

_new_grn = [];
{
	_building = call compile format ['building_%1', _x];
	_new_grn set [count _new_grn, _building];
} forEach buildings_grn;
buildings_grn = _new_grn;

_new_civ = [];
{
	_building = call compile format ['building_%1', _x];
	_new_civ set [count _new_civ, _building];
} forEach buildings_civ;
buildings_civ = _new_civ;

_new_patrol = [];
{
	_building = call compile format ['building_%1', _x];
	_building setVariable ['faction', 'none'];
	
	_new_patrol set [count _new_patrol, _building];
} forEach buildings_patrol;
buildings_patrol = _new_patrol;

//build lists of sentries and guards
sentries_red = [];
sentries_grn = [];
sentries_civ = [];

guards_red = [];
guards_grn = [];
guards_civ = [];
{
	if ( (_x getVariable ['building', 42]) != 42) then {
		_x setVariable ['building', ( call compile format ['building_%1', _x getVariable 'building'] ), true];
	};
	
	if ( (_x getVariable ['building', 42]) in buildings_patrol ) then {
		switch (side _x) do {
			case east: { sentries_red set [count sentries_red, _x]; };
			case resistance: { sentries_grn set [count sentries_grn, _x]; };
			case civilian: { sentries_civ set [count sentries_civ, _x]; };
		};
	} else {
		switch (side _x) do {
			case east: { if ( (_x getVariable ['building', 42]) in buildings_red ) then { guards_red set [count guards_red, _x]; }; };
			case resistance: { if ( (_x getVariable ['building', 42]) in buildings_grn ) then { guards_grn set [count guards_grn, _x]; }; };
			case civilian: { if ( (_x getVariable ['building', 42]) in buildings_civ ) then { guards_civ set [count guards_civ, _x]; }; };
		};
	};
} forEach allGroups;

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

//Initialise and build relevant lists for each civilian faction
_buildings_per_group = floor( (count buildings_civ) / (count _civ_groups) );
_patrols_per_group = floor( (count patrolgroups_civ) / (count _civ_groups) );
_sentries_per_group = floor( (count sentries_civ) / (count _civ_groups) );

_civfactions = [];
{
	call compile format ["
		buildings_civ_%1 = [];
		if (_forEachIndex == (count _civ_groups - 1)) then {
			{
				buildings_civ_%1 set [count buildings_civ_%1, _x];
			} forEach buildings_civ;
		} else {
			while { count buildings_civ_%1 < _buildings_per_group } do {
				buildings_civ_%1 set [count buildings_civ_%1, (buildings_civ select 0)];
				buildings_civ = buildings_civ - [buildings_civ select 0];
			};
		};
		
		guards_civ_%1 = [];
		{
			if (_x getVariable 'building' in buildings_civ_%1) then {
				guards_civ_%1 set [count guards_civ_%1, _x];
			};
		} forEach guards_civ;
		
		patrolgroups_civ_%1 = [];
		if (_forEachIndex == (count _civ_groups - 1)) then {
			{
				patrolgroups_civ_%1 set [count patrolgroups_civ_%1, _x];
			} forEach patrolgroups_civ;
		} else {
			while { count patrolgroups_civ_%1 < _patrols_per_group } do {
				patrolgroups_civ_%1 set [count patrolgroups_civ_%1, (patrolgroups_civ select 0)];
				patrolgroups_civ = patrolgroups_civ - [patrolgroups_civ select 0];
			};
		};
		
		sentries_civ_%1 = [];
		if (_forEachIndex == (count _civ_groups - 1)) then {
			{
				sentries_civ_%1 set [count sentries_civ_%1, _x];
			} forEach sentries_civ;
		} else {
			while { count sentries_civ_%1 < _sentries_per_group } do {
				sentries_civ_%1 set [count sentries_civ_%1, (sentries_civ select 0)];
				sentries_civ = sentries_civ - [sentries_civ select 0];
			};
		};
		
		groups_civ_%1 = [];
		{
			groups_civ_%1 set [count groups_civ_%1, _x];
		} forEach (patrolgroups_civ_%1 + sentries_civ_%1 + guards_civ_%1);

	", _x];
	
	_civfactions set [count _civfactions, format ['civ_%1', _x] ];
} forEach _civ_groups;

//build other unit lists (all patrols, all sentries, plus targets for red)
groups_red = [(group target)];
{
	groups_red set [count groups_red, _x];
} forEach (patrolgroups_red + sentries_red + guards_red);

groups_grn = [];
{
	groups_grn set [count groups_grn, _x];
} forEach (patrolgroups_grn + sentries_grn + guards_grn);

//Style randomisation for factions
factions = ['red', 'grn'] + _civfactions;
_styles = ['shemags', 'leathers', 'military', 'sandals', 'class', 'terrors'];
{
	_faction = _x;
	_style = _styles select floor random count _styles;
	_styles = _styles - [_style];
	
	missionNamespace setVariable [ format['style_%1', _faction], _style ];
	
	{
		{
			_x setVariable ['gang_style', _style, true];
			_x setVariable ['faction', _faction, true];
		} forEach (units _x);
	} forEach ( call compile format ['groups_%1', _faction] );
	
	{
		_x setVariable ['faction', _faction, true];
	} forEach ( call compile format ['buildings_%1', _faction] );
} forEach factions;

//Task setting: ['TaskName', locality, ['Description', 'Title', 'Marker'], target, 'STATE', priority, showNotification, true] call BIS_fnc_setTask;
['MainTask', true, ['Retrieve the Hard Drive containing data on a large explosives cache hidden during the war.', 'Retrieve HDD', ''], nil, 'ASSIGNED', 0, false, true] call BIS_fnc_setTask;

//Switch helo to MELB if available
if ( 'melb' call caran_checkMod ) then {
	_old_helo = helo;
	_pos = getPos helo;
	_dir = getDir helo;
	
	helo = 'MELB_MH6M' createVehicle (markerPos 'helospawn');
	publicVariable 'helo';
	deleteVehicle _old_helo;
	deleteVehicle helo_camera;
	helo setPos _pos;
	helo setDir _dir;
};

//Spawns a thread that will run a loop to keep an eye on mission progress and to end it when appropriate, checking which ending should be displayed.
_progress = [] spawn {
	
	//Init all variables you need in this loop
	_ending = false;
	_players_dead = false;
	_players_away = false;
	
	//Init objective
	missionNamespace setVariable ['objective_owner', target, true];
	
	//Handle neutrals going enemy when damaged by players
	{
		if (!isPlayer _x && side _x != east) then {
			_x addEventHandler ['HandleDamage', "
				_target = _this select 0;
				_source = _this select 3;
				_damage = _this select 2;
				
				if (isPlayer _source) then {
					[[(_target getVariable 'faction')], east] execVM 'ai\turnFaction.sqf';
				};
				
				_damage
			"];
		};
	} forEach allUnits;

	//Starts a loop to check mission status every second, update tasks, and end mission when appropriate
	while {!_ending} do {
		
		sleep 1;
		
		//Mission ending condition check
		if ( _players_dead || (_players_away && !alive target ) ) then {
			_ending = true;
			
			_end = 'Lose';
			{
				if (alive _x && !([trigger_area, (getPos (vehicle _x) )] call BIS_fnc_inTrigger ) ) then {
					if ( ('sc_harddrive' in (items _x + assignedItems _x) ) || _x == (missionNamespace getVariable 'objective_owner') ) then {
						_end = 'Win';
					};
				};
			} forEach playableUnits;
			
			if (_end == 'Win') then {
				['MainTask', 'SUCCEEDED', false] call BIS_fnc_taskSetState;
			} else {
				['MainTask', 'FAILED', false] call BIS_fnc_taskSetState;
			};
			
			sleep 15;
			
			//Runs end.sqf on everyone. For varying mission end states, calculate the correct one here and send it as an argument for end.sqf
			[[_end,'end.sqf'], 'BIS_fnc_execVM', true, false] spawn BIS_fnc_MP;
		};
		
		//Induce chaos when target is dead
		if (!(missionNamespace getVariable ['shit_in_fan', false])) then {
			if (!alive (missionNamespace getVariable 'objective_owner')) then {
				missionNamespace setVariable ['shit_in_fan', true];

				{
					_faction = _x;
					_rand = random 1;
					
					if (_rand < 0.6) then {
					
						if (_rand > 0.4) then {
								[[_faction], east] execVM 'ai\turnFaction.sqf';
						} else {
							
							if (_rand > 0.2) then {
								[[_faction], resistance] execVM 'ai\turnFaction.sqf';
							} else {
								[[_faction], west] execVM 'ai\turnFaction.sqf';
							};
						};
					};
				} forEach (factions - ['red']);
			};
		};
		
		//Induce extra chaos when leaving target area
		if (!(missionNamespace getVariable ['shit_totally_in_fan', false])) then {
			if (!alive target) then {
				_bool = true;
				{
					if ( ([trigger_dangerzone, (getPos (vehicle _x) )] call BIS_fnc_inTrigger) && alive _x ) then {
						_bool = false;
					};
				} forEach playableUnits;
				
				if (_bool) then {
					missionNamespace setVariable ['shit_totally_in_fan', true];
					
					civilian setFriend [civilian, 0];
					civilian setFriend [resistance, 0];
					civilian setFriend [west, 0];
					civilian setFriend [east, 0];
					resistance setFriend [east, 0];
					resistance setFriend [west, 0];
					resistance setFriend [civilian, 0];
					east setFriend [resistance, 0];
					east setFriend [civilian, 0];
				};
			};
		};
		
		//Sets _players_dead as true if nobody is still alive
		_players_dead = true;
		{
			if (alive _x) then {
				_players_dead = false;
			};
		} forEach playableUnits;
		
		//Sets players_away as true if nobody is in the area and the mission has been started
		_players_away = true;
		{
			if ( ([trigger_area, (getPos (vehicle _x) )] call BIS_fnc_inTrigger) && alive _x ) then {
				_players_away = false;
			};
		} forEach playableUnits;
		
	};
};

//Handle objective actions if SC inventory items is not on
if (!('scorch_invitems' call caran_checkMod )) then {
	_objective_action = [] spawn {
		while { true } do {
			
			waitUntil { !alive (missionNamespace getVariable 'objective_owner') };
			_previous_owner = missionNamespace getVariable 'objective_owner';
			diag_log format ["%1 dead!", _previous_owner];
			
			[
				(missionNamespace getVariable 'objective_owner'), 
				[
					'Retrieve Hard Drive', 
					"missionNamespace setVariable ['objective_owner', player, true];", 
					nil, 
					10, 
					false, 
					true, 
					'', 
					"
						!alive _target && _target distance _this < 3
					"
				]
			] remoteExec ['addAction', west, false];
			
			waitUntil { alive (missionNamespace getVariable 'objective_owner') };
			
			_previous_owner remoteExec ['removeAllActions', west, false];
			diag_log format ["%1 is new objective owner!", (missionNamespace getVariable 'objective_owner') ];
		};
	};
};

//Play random music from radios
_radios_music =  [] spawn {

	{
		_x spawn {
			while { true } do {
				_radio = _this;
				_position = _radio modelToWorld [0,0,0];
				
				_filePath = [(str missionConfigFile), 0, -15] call BIS_fnc_trimString;
				_music_list = [ 
					['music\dance.ogg', 180], 
					['music\dubstep.ogg', 130], 
					['music\house.ogg', 265], 
					['music\moose.ogg', 180],
					['music\rumble.ogg', 180]
				];
				_selection = _music_list select floor random count _music_list;
				
				_song = _selection select 0;
				_filePath = _filePath + _song;
				
				_length = _selection select 1;
				
				playSound3D [_filePath, _radio, true, _position, 0.5, 1, 0];
				sleep _length;
			};
		};
	} forEach radios;
};

//client inits wait for serverInit to be true before starting, to make sure all variables the server sets up are set up before clients try to refer to them (which would cause errors)
serverInit = true;
publicVariable 'serverInit';