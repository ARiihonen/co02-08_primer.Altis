//This runs on every respawning player AND players spawning in for the first time EVEN IF description.ext has set respawnOnStart to 0. Yeah, I don't get it either.
#include "logic\activeMods.sqf";

_gear = player execVM 'player\gear.sqf'; //running the gear script

if ( 'task_force_radio' call caran_checkMod || 'acre_' call caran_checkMod ) then {
	call caran_playerRadioSetup;
};

if (!('melb' call caran_checkMod)) then {
	_camera_available = [] spawn {
		
		while { true } do {
			
			waitUntil { vehicle player == helo && ( assignedVehicleRole player select 0 == 'Turret') };
			
			_id = player addAction ['View Camera', 
				"
					player linkItem 'B_UavTerminal';
					player connectTerminalToUAV helo_camera;
					player action ['SwitchToUAVGunner', helo_camera];
					
					waitUntil { cameraView != 'GUNNER' };
					player unLinkItem 'B_UavTerminal';
				", 
				nil, 
				6, 
				false, 
				true, 
				'', 
				''
			];
			
			waitUntil { !(vehicle player == helo && ( assignedVehicleRole player select 0 == 'Turret') ) };
			
			player removeAction _id;
		};
	};
};

_satellite = [] spawn {
	[
		'HeloCamera', 
		'onEachFrame', 
		{
			if ( vehicle player == helo && ( assignedVehicleRole player select 0 == 'Turret') && cameraView == 'GUNNER'  ) then {
				
				//Friendly markers
				_objective_real = (missionNamespace getVariable 'objective_owner');
				{
					if ('ItemGPS' in (items _x + assignedItems _x) || 'ACE_microDagr' in (items _x + assignedItems _x) ) then {
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

_gps_track = [] spawn {

	target_marker = createMarker ['marker_target', missionNamespace getVariable 'objective_owner'];
	target_marker setMarkerShape 'ICON';
	target_marker setMarkerType 'empty';
	target_marker setMarkerSize [0.5, 0.5];

	while { true } do {
		
		waitUntil { 'ItemGPS' in (items player + assignedItems player) || 'ACE_microDagr' in (items player + assignedItems player) };
		
		while { 'ItemGPS' in (items player + assignedItems player) || 'ACE_microDagr' in (items player + assignedItems player) } do {
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
};