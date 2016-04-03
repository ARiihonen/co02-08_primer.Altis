/*
This script is defined as a pre-init function in description.ext, meaning it runs before the map initialises.
*/
#include "logic\preInit.sqf"
#include "logic\activeMods.sqf"

if (isServer) then {
	//Randomizing unit presence variables using caran_randInt and caran_presenceArray
	
	//Populate building arrays by location
	_centre = [1,2];
	_middle = [10,3] call caran_populateArray;
	_edge = [24,11] call caran_populateArray;
	
	//init all necessary variables
	buildings_red = [];
	buildings_grn = [];
	buildings_civ = [];
	
	buildings_patrol = [];
	
	statics_red = [];
	statics_grn = [];
	statics_civ = [];
	
	patrols_red = 0;
	patrols_grn = 0;
	patrols_civ = 0;
	
	patrolgroups_red = [];
	patrolgroups_grn = [];
	patrolgroups_civ = [];
	
	guards_red = [];
	guards_grn = [];
	guards_civ = [];
	
	radios = [];
	
	//Red buildings
	
	//Get one of the buildings from the centre
	buildings_red = [_centre, 1] call caran_chooseRandoms;
	_centre = _centre - buildings_red;
	
	//Get the rest of the buildings from the middle
	_new_buildings = [_middle, 1, 2] call caran_chooseRandoms;
	buildings_red = buildings_red + _new_buildings;
	_middle = _middle - _new_buildings;
	
	
	//Grn buildings
	
	//Select 2-3 buildings from remaining centre+mid buildings
	buildings_grn = [ ( _middle + _centre ), 2, 3 ] call caran_chooseRandoms;
	{
		if (_x in _centre) then {
			_centre = _centre - [_x];
		};
		
		if (_x in _middle) then {
			_middle = _middle - [_x];
		};
	} forEach buildings_grn;
	
	
	//Civ buildings
	
	//Select 1-3 buildings from the available edge HQs
	_available_civ = [11, 13, 15, 17, 19, 21];
	//available_civ = _edge
	buildings_civ = [ _available_civ, 1, 3] call caran_chooseRandoms;
	_edge = _edge - buildings_civ;
	
	
	//Patrol buildings are the ones that are not anyone's actual territory but do get traffic
	buildings_patrol = _centre + _middle + _edge;
	
	
	//Red leftover size and composition (statics vs patrols)
	_total = 0;
	if (count buildings_red == 3) then {
		_total = 6;
	} else {
		_total = 14;
	};
	patrols_red = floor random (_total/2);
	_static_count_red = _total - (patrols_red*2);
	
	//Grn leftover size and composition (statics vs patrols)
	_total = 0;
	if (count buildings_grn == 3) then {
		_total = 6;
	} else {
		_total = 14;
	};
	patrols_grn = floor random (_total/2);
	_static_count_grn = _total - (patrols_grn*2);
	
	//Civ leftover size and composition (statics vs patrols)
	_total = 0;
	switch (count buildings_civ) do {
		case 1: { _total = 22; };
		case 2: { _total = 14; };
		case 3: { _total = 6; };
	};
	patrols_civ = floor random (_total/2);
	_static_count_civ = _total - (patrols_civ*2);
	
	
	//Populating statics arrays
	
	//Red: 1-8 for each building in centre/mid, 1-2 for each on edge
	if ( (count _centre) > 0) then {
		{
			_new_statics = [(_x*8) , ( (_x*8)-7 ) ] call caran_populateArray;
			{
				statics_red set [count statics_red, _x];
			} forEach _new_statics;
		} forEach _centre;
	};
	{
		_new_statics = [(_x*8) , ( (_x*8)-7 ) ] call caran_populateArray;
		{
			statics_red set [count statics_red, _x];
		} forEach _new_statics;
	} forEach _middle;
	{
		_edge_count = _x - 10;
		
		_new_statics = [(_edge_count*2)+80 , ( (_edge_count*2)+79 ) ] call caran_populateArray;
		{
			statics_red set [count statics_red, _x];
		} forEach _new_statics;
	} forEach _edge;
	
	//Grn: Same as red
	statics_grn = [];
	{
		statics_grn set [count statics_grn, _x];
	} forEach statics_red;
	
	//Civ: 1-8 for each building on edge
	{
		_edge_count = _x - 10;
		
		_new_statics = [(_edge_count*8) , ( (_edge_count*8)-7 ) ] call caran_populateArray;
		{
			statics_civ set [count statics_civ, _x];
		} forEach _new_statics;
	} forEach _edge;
	
	//Randomising static units
	statics_red = [statics_red, _static_count_red] call caran_chooseRandoms;
	statics_grn = [statics_grn, _static_count_grn] call caran_chooseRandoms;
	statics_civ = [statics_civ, _static_count_civ] call caran_chooseRandoms;
	
	//Define strings to search for in active addons
	_checkList = [
		'ace_common',
		'asr_ai3_main',
		'task_force_radio',
		'hlcweapons_mp5',
		'hlcweapons_aks',
		'acre_',
		'rhs_',
		'rhsusf_',
		'melb',
		'scorch_invitems',
		'mnp_'
	];
	
	//Check mod checklist against active addons
	_checkList call caran_initModList;
	
	if ( "asr_ai3_main" call caran_checkMod ) then {
		call compile preprocessfile 'mods\asr.sqf';
	};
};