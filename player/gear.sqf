#include "..\logic\gear.sqf"

//Get player class and make sure it's all uppercase since BI classnames are super inconsistent
_class = typeOf player;
_class = toUpper _class;

//Remove all gear. Remove if only adding items or swapping non-containers
player call caran_clearInventory;

//Define default gear types. Leave as is if no change from default unit required (or remove both from here and from calls at the end of this file)
_uniform = 'U_C_WorkerCoveralls';
_vest = 'V_PlateCarrier1_blk';
_backpack = '';
_headwear = ['H_HelmetB_light_black','G_Balaclava_lowprofile'];

if ( 'mnp' call caran_checkMod ) then {
	_uniform = ['MNP_CombatUniform_PPU_B','MNP_CombatUniform_PPU_A'] select floor random 1;
};

_items = [];
_link_items = ['ItemMap', 'ItemCompass', 'ItemWatch'];

if ( 'acre_' call caran_checkMod ) then {
	_items set [count _items, ['ACRE_PRC148']];
} else {
	_link_items set [count _link_items, 'ItemRadio'];
};

if ( 'ace_' call caran_checkMod ) then {
	_items set [ count _items, ['ACE_fieldDressing', 6, 'Uniform'] ];
	_items set [ count _items, ['ACE_packingBandage', 5, 'Uniform'] ];
	_items set [ count _items, ['ACE_morphine', 4, 'Uniform'] ];
	_items set [ count _items, ['ACE_epinephrine', 4, 'Uniform'] ];
	_items set [ count _items, ['ACE_tourniquet', 2, 'Uniform'] ];
	_items set [ count _items, ['ACE_earplugs', 1, 'Uniform'] ];
} else {
	_items set [ count _items, ['FirstAidKit', 2, 'Uniform']];
};

{
	_items set [ count _items, [_x, 2, 'Vest'] ];
} forEach ['SmokeShellGreen', 'ChemlightGreen', 'HandGrenade'];

_primary_weapon = 'SMG_02_F';
_primary_weapon_items = ['acc_flashlight', 'optic_Aco'];
_primary_ammo_array = ['30Rnd_9x21_Mag', 8, 'Vest'];

if ( 'hlcweapons_mp5' call caran_checkMod ) then {
	_primary_weapon =  'hlc_smg_mp5a4';
	_primary_ammo_array = ['hlc_30Rnd_9x19_B_MP5', 8, 'Vest'];
};

_handgun = 'hgun_P07_F';
_handgun_items = [];
_handgun_ammo_array = ['16Rnd_9x21_Mag', 2, 'Vest'];

switch _class do {

	case 'B_SOLDIER_SL_F': {
		if ( 'ace_' call caran_checkMod ) then {
			_items set [ count _items, ['ACE_microDagr', 1, 'Vest'] ];
		} else {
			_link_items set [ count _link_items, 'ItemGPS' ];
		};
	};
	
	case 'B_SOLDIER_TL_F': {
		if ( 'ace_' call caran_checkMod ) then {
			_items set [ count _items, ['ACE_microDagr', 1, 'Vest'] ];
		} else {
			_link_items set [ count _link_items, 'ItemGPS' ];
		};
	};
	
	case 'B_MEDIC_F': {
		_backpack = 'B_AssaultPack_blk';
		
		if ( 'ace_' call caran_checkMod ) then {
			_items set [ count _items, ['ACE_bloodIV', 5, 'Backpack']];
			{ _items set [count _items, [_x, 10, 'Backpack']]; } forEach ['ACE_morphine', 'ACE_epinephrine', 'ACE_tourniquet'];
			{ _items set [count _items, [_x, 20, 'Backpack']]; } forEach ['ACE_packingBandage', 'ACE_fieldDressing'];
		} else {
			_items set [ count _items, ['Medikit', 1, 'Backpack']];
			_items set [ count _items, ['FirstAidKit', 10, 'Backpack']];
		};
	};
	
	case 'B_SOLDIER_M_F': {
		_primary_weapon = 'arifle_MX_Black_F';
		_primary_weapon_items = ['acc_flashlight', 'optic_Hamr'];
		_primary_ammo_array = ['30Rnd_65x39_caseless_mag', 8, 'Vest'];
		
		if ( 'rhsusf_' call caran_checkMod ) then {
			_primary_weapon = 'rhs_weap_m4a1_carryhandle_grip2';
			_primary_weapon_items = ['acc_flashlight', 'rhsusf_acc_ACOG_pip'];
			_primary_ammo_array = ['rhs_mag_30Rnd_556x45_Mk318_Stanag', 8, 'Vest'];
		};
	};
	
	case 'B_SOLDIER_AR_F': {
		_primary_weapon = 'LMG_Mk200_F';
		_primary_ammo_array = ['200Rnd_65x39_cased_Box_Tracer', 2, 'Vest'];
		
		_handgun_ammo_array = ['16Rnd_9x21_Mag', 1, 'Vest'];
		
		if ( 'rhsusf_' call caran_checkMod ) then {
			_primary_weapon = 'rhs_weap_M590_5RD';
			_primary_weapon_items = [];
			_primary_ammo_array = ['rhsusf_5Rnd_00Buck', 15, 'Vest'];
		};
	};
	
	case 'B_HELIPILOT_F': {
		if ( 'rhsusf_' call caran_checkMod ) then {
			_headwear = ['rhsusf_bowman_cap','G_Aviator'];
		} else {
			_headwear = ['H_Cap_headphones','G_Aviator'];
		};
		
		_uniform = 'U_I_HeliPilotCoveralls';
	};
};

if (player == leader group player && !('ItemGPS' in (items player + assignedItems player) || 'ACE_microDagr' in (items player + assignedItems player) ) ) then {
	if ( 'ace_' call caran_checkMod ) then {
		_items set [ count _items, ['ACE_microDagr', 1, 'Vest'] ];
	} else {
		_link_items set [ count _link_items, 'ItemGPS' ];
	};
};

//Adding gear. 
[player, _uniform, _vest, _backpack, _headwear] call caran_addClothing;
[player, _items] call caran_addInventoryItems;
[player, _link_items] call caran_addLinkedItems;
[player, _primary_weapon, _primary_weapon_items, _primary_ammo_array] call caran_addPrimaryWeapon;
[player, _handgun, _handgun_items, _handgun_ammo_array] call caran_addHandgun;