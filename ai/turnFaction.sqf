_factions = _this select 0;
_side = _this select 1;

diag_log format ['Turn Factions %1 to %2', _factions, _side];

{
	_faction = _x;
	
	if (_faction == 'grn' && _side != civilian) then {
		
		switch _side do {
			case east: { resistance setFriend [west, 0]; west setFriend [resistance, 0]; };
			case west: { resistance setFriend [east, 0]; east setFriend [resistance, 0]; };
		};

	} else {
		call compile format ["
			{
				_grp = _x;
				_building = _x getVariable ['building', 42];
				
				_new_groups = [];
				_deleted_groups = [];
				if ( (side _grp != east && side _grp != _side) || _side == civilian ) then {
					_new_grp = createGroup _side;
					
					_new_groups set [count _new_groups, _new_grp];
					_deleted_groups set [count _deleted_groups, _grp];
					
					_new_grp setVariable ['building', _building, true];
					(units _grp) joinSilent _new_grp;
					_new_grp copyWaypoints _grp;
				};
				
				{
					groups_%1 set [count groups_%1, _x];
				} forEach _new_groups;
				
				{
					groups_%1 = groups_%1 - [_x];
				} forEach _deleted_groups;
				
			} forEach groups_%1;
		",
		_faction
		];
	};
} forEach _factions;