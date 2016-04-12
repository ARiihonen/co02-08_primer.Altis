//Runs on both server and clients after initServer.sqf is finished
waitUntil {!isNil 'serverInit'};
waitUntil {serverInit};

#include "logic\activeMods.sqf"

//initialise mods if active
if ( 'task_force_radio' call caran_checkMod ) then {
	_load = [] execVM 'mods\tfar.sqf';
};

if ('acre_' call caran_checkMod ) then {
	_load = [] execVM 'mods\acre.sqf';
};

if ( 'ace_' call caran_checkMod ) then {
	_load = [] execVM 'mods\ace.sqf';
};

//Player init: this will only run on players. Use it to add the briefing and any player-specific stuff like action-menu items.
if (!isServer || (isServer && !isDedicated) ) then {
	//put in briefings
	briefing = [] execVM 'briefing\briefing.sqf';
	
	//Init target marker tracking if GPS equipped
	target_marker = createMarker ['marker_target', missionNamespace getVariable 'objective_owner'];
	target_marker setMarkerShape 'ICON';
	target_marker setMarkerType 'empty';
	target_marker setMarkerSize [0.5, 0.5];
	
	targetMarker = {
		while { (missionNamespace getVariable 'objective_owner' != target || [trigger_dangerzone, vehicle target] call BIS_fnc_inTrigger) && ( 'ItemGPS' in (items player + assignedItems player) || 'ACE_microDAGR' in (items player + assignedItems player) ) } do {
			sleep 1;
			
			target_marker setMarkerPos (getPos (missionNamespace getVariable 'objective_owner'));
			target_marker setMarkerTypeLocal 'mil_objective';
			target_marker setMarkerTextLocal 'Objective';
			target_marker setMarkerColorLocal 'ColorOPFOR';
			target_marker setMarkerAlphaLocal 1;
		};
		
		target_marker setMarkerTypeLocal 'empty';
		target_marker setMarkerTextLocal '';
		target_marker setMarkerColorLocal 'default';
		target_marker setMarkerAlphaLocal 0;
	};
	
	//Make trigger to handle activation
	trigger_trackmarker = createTrigger ['EmptyDetector', [0,0,0], false];
	trigger_trackmarker setTriggerActivation ['NONE', 'PRESENT', true];
	trigger_trackmarker setTriggerStatements [
		"(missionNamespace getVariable 'objective_owner' != target || [trigger_dangerzone, vehicle target] call BIS_fnc_inTrigger) && ( 'ItemGPS' in (assignedItems player) || 'ACE_microDAGR' in (items player) )",
		"_target_marker = [] spawn targetMarker;",
		""
	];
	
	//Satellite tracking for helicopter camera
	satelliteTracker = {
		[
			'HeloCamera', 
			'onEachFrame', 
			{
				//Friendly markers
				_objective_real = (missionNamespace getVariable 'objective_owner');
				{
					if ('ItemGPS' in (assignedItems _x) || 'ACE_microDagr' in (items _x) ) then {
						_icon = '\A3\ui_f\data\map\markers\military\dot_CA.paa';
						_colour = [0, 0, 1, 0.5];
						_pos = visiblePosition _x;
						_text = format ['Ground GPS %1 m', floor(player distance _x)];

						drawIcon3D [_icon, _colour , _pos , 0.5, 0.5, 0, _text, 0, 0.025, 'TahomaB'];
					};
					
					if ('sc_harddrive' in (items _x + assignedItems _x) ) then {
						_objective_real = _x;
					};
				} forEach playableUnits;
				
				if (_objective_real != target || [trigger_dangerzone, vehicle target] call BIS_fnc_inTrigger) then {
					//Target marker
					_icon = '\A3\ui_f\data\map\markers\military\objective_CA.paa';
					_colour = [1, 0, 0, 0.5];
					_pos = visiblePosition _objective_real;
					_text = format ['Objective: %1 m', floor(player distance _objective_real)];
					
					drawIcon3D [_icon, _colour , _pos , 0.5, 0.5, 0, _text, 0, 0.025, 'TahomaB'];
				};
			},
			[]
		] call BIS_fnc_addStackedEventHandler;
	};
	
	//Make trigger to activate/deactivate as needed
	trigger_satellite = createTrigger ['EmptyDetector', [0,0,0], false];
	trigger_satellite setTriggerActivation ['NONE', 'PRESENT', true];
	trigger_satellite setTriggerStatements [
		"vehicle player == helo && ( assignedVehicleRole player select 0 == 'Turret') && cameraView == 'GUNNER'",
		"_satellite = [] spawn satelliteTracker;",
		"['HeloCamera', 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;"
	];
	
	if (!('melb' call caran_checkMod)) then {
		addHeloAction = {
			_id = player addAction ['View Camera', 
				"
					if ('ItemGPS' in (assignedItems player) || 'ACE_microDagr' in (items player)) then {
						player setVariable ['had_gps', true, false];
					};
					player linkItem 'B_UavTerminal';
					player connectTerminalToUAV helo_camera;
					player action ['SwitchToUAVGunner', helo_camera];
					
					waitUntil { cameraView != 'GUNNER' };
					player unLinkItem 'B_UavTerminal';
					
					if (player getVariable ['had_gps', false]) then {
						if ('ace_' call caran_checkMod) then {
							player addItemToVest 'ACE_microDagr';
						} else {
							player linkItem 'ItemGPS';
						};
					};
				", 
				nil, 
				6, 
				false, 
				true, 
				'', 
				''
			];
			
			player setVariable ['camera_action', _id, false];
		};
		
		removeHeloAction = {
			player removeAction (player getVariable ['camera_action', 0]);
		};
		
		trigger_helocamera = createTrigger ['EmptyDetector', [0,0,0], false];
		trigger_helocamera setTriggerActivation ['NONE', 'PRESENT', true];
		trigger_helocamera setTriggerStatements [
			"vehicle player == helo && ( assignedVehicleRole player select 0 == 'Turret')",
			"call addHeloAction;",
			"call removeHeloAction;"
		];
	};
};

execVM 'logic\hcHandle.sqf';