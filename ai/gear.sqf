#include "..\logic\gear.sqf"

//Get _this class and make sure it's all uppercase since BI classnames are super inconsistent
_gang = _this getVariable "gang_style";

_class = typeOf _this;
_class = toUpper _class;

//Remove all gear. Remove if only adding items or swapping non-containers
_this call caran_clearInventory;

//Define default gear types. Leave as is if no change from default unit required (or remove both from here and from calls at the end of this file)
_uniform = "";
_vest = "";
_backpack = "";
_headwear = ["",""];

_items = [ ["FirstAidKit", 2, "Uniform"] ];
_link_items = ["ItemMap", "ItemCompass", "ItemWatch", "ItemRadio"];

_primary_weapon = ["arifle_Mk20_plain_F", "hgun_PDW2000_F", "srifle_DMR_01_F", "arifle_TRG21_F", "SMG_01_F", "arifle_Katiba_F"];
if ( "rhs_" call caran_checkMod ) then {
	_primary_weapon = ["rhs_weap_ak74m", "rhs_weap_ak74m_2mag", "rhs_weap_ak74m_folded", "rhs_weap_akms"];
};
if ( "hlcweapons_aks" call caran_checkMod ) then {
	_primary_weapon = ["hlc_rifle_ak47", "hlc_rifle_ak74", "hlc_rifle_akm", "hlc_rifle_aks74", "hlc_rifle_aks74u"];
};
_primary_weapon_items = ["acc_flashlight"];

//primary weapon randomisation and ammo assignment:
_primary_weapon = _primary_weapon select floor random count _primary_weapon;
_primary_ammo_array = [];
switch _primary_weapon do {
	case "arifle_Mk20_plain_F": {
		_primary_ammo_array = ["30Rnd_556x45_Stanag", 8, "Vest"];
	};
	
	case "hgun_PDW2000_F": {
		_primary_ammo_array = ["30Rnd_9x21_Mag", 8, "Vest"];
	};
	
	case "srifle_DMR_01_F": {
		_primary_ammo_array = ["10Rnd_762x54_Mag", 8, "Vest"];
	};
	
	case "arifle_TRG21_F": {
		_primary_ammo_array = ["30Rnd_556x45_Stanag", 8, "Vest"];
	};
	
	case "SMG_01_F": {
		_primary_ammo_array = ["30Rnd_45ACP_Mag_SMG_01", 8, "Vest"];
	};
	
	case "arifle_Katiba_F": {
		_primary_ammo_array = ["30Rnd_65x39_caseless_green", 8, "Vest"];
	};
	
	case "rhs_weap_ak74m": {
		_primary_ammo_array = ["rhs_30Rnd_545x39_AK", 6, "Vest"];
		_primary_weapon_items = ["rhs_acc_2dpZenit"];
	};
	
	case "rhs_weap_ak74m_2mag": {
		_primary_ammo_array = ["rhs_30Rnd_545x39_AK", 6, "Vest"];
		_primary_weapon_items = ["rhs_acc_2dpZenit", "rhs_acc_dtk"];
	};
	
	case "rhs_weap_ak74m_folded": {
		_primary_ammo_array = ["rhs_30Rnd_545x39_AK", 6, "Vest"];
		_primary_weapon_items = ["rhs_acc_2dpZenit", "rhs_acc_dtk1"];
	};
	
	case "rhs_weap_akm": {
		_primary_ammo_array = ["rhs_30Rnd_762x39mm", 8, "Vest"];
		_primary_weapon_items = ["rhs_acc_2dpZenit"];
	};
	
	case "rhs_weap_akms": {
		_primary_ammo_array = ["rhs_30Rnd_762x39mm", 8, "Vest"];
		_primary_weapon_items = ["rhs_acc_2dpZenit"];
	};
	
	case "hlc_rifle_ak47": {
		_primary_ammo_array = ["hlc_30Rnd_762x39_b_ak", 6, "Vest"];
		_primary_weapon_items = [];
	};
	
	case "hlc_rifle_ak74": {
		_primary_ammo_array = ["hlc_30Rnd_545x39_B_AK", 6, "Vest"];
		_primary_weapon_items = [];
	};
	
	case "hlc_rifle_akm": {
		_primary_ammo_array = ["hlc_30Rnd_762x39_b_ak", 6, "Vest"];
		_primary_weapon_items = [];
	};
	
	case "hlc_rifle_aks74": {
		_primary_ammo_array = ["hlc_30Rnd_545x39_B_AK", 6, "Vest"];
		_primary_weapon_items = [];
	};
	
	case "hlc_rifle_aks74u": {
		_primary_ammo_array = ["hlc_30Rnd_545x39_B_AK", 6, "Vest"];
		_primary_weapon_items = [];
	};
};

//Gang clothing selections:

//shemags:
_uniform_shemags = ["U_BG_Guerrilla_6_1", "U_BG_Guerilla2_2", "U_BG_Guerilla2_1", "U_BG_Guerilla2_3"];
_vest_shemags = ["V_BandollierB_blk", "V_BandollierB_cbr", "V_BandollierB_rgr", "V_BandollierB_khk"];
_headwear_shemags = [ ["H_Shemag_olive", ""], ["H_ShemagOpen_tan", ""], ["H_ShemagOpen_khk", ""] ];

//leathers:
_uniform_leathers = "U_C_Driver_4";
_vest_leathers = "V_BandollierB_blk";
_headwear_leathers = [ ["H_Bandanna_gry", "G_Bandanna_aviator"], ["H_Bandanna_gry", "G_Bandanna_blk"] ];

//military:
_uniform_military = ["U_BG_Guerilla1_1", "U_BG_leader"];
_vest_military = ["V_TacVest_blk", "V_TacVest_brn", "V_TacVest_camo", "V_TacVest_khk", "V_TacVest_oli", "V_I_G_resistanceLeader_F"];
_headwear_military = ["H_Beret_blk", "G_Aviator"];

//sandals:
_uniform_sandals = ["U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy", "U_C_Poloshirt_redwhite", "U_C_Poloshirt_salmon", "U_C_Poloshirt_stripped", "U_C_Poloshirt_tricolour"];
_vest_sandals = _vest_shemags;
_headwear_sandals = [
	["H_Cap_tan", "H_Cap_red", "H_Cap_oli", "H_Cap_grn", "H_Cap_blu", "H_Cap_blk"],
	["G_Sport_Greenblack", "G_Sport_Blackred", "G_Sport_Checkered", "G_Sport_BlackWhite", "G_Sport_Blackyellow", "G_Sport_Red", "G_Shades_Red", "G_Shades_Green", "G_Shades_Blue", "G_Shades_Black"]
];

//class:
_uniform_class = "U_Marshal";
_vest_class = _vest_shemags;
_headwear_class = [
	["H_Hat_tan", "H_Hat_grey", "H_Hat_checker", "H_Hat_brown"],
	["G_Spectacles_Tinted", "G_Squares", "G_Squares_Tinted", "G_Spectacles"]
];

//terrors:
_uniform_terrors = _uniform_shemags + ["U_I_G_resistanceLeader_F"];
_vest_terrors = _best_shemags;
_headwear_terrors = [ ["","G_Balaclava_blk"], ["","G_Balaclava_oli"] ];


//Define and assign non-standard gear here.
switch _gang do {
	case "shemags": {
		_uniform = _uniform_shemags select floor random count _uniforms_shemags;
		_vest = _vest_shemags select floor random count _vest_shemags;
		_headwear = _headwear_shemags select floor random count _headwear_shemags;
	};
	
	case "leathers": {
		_uniform = _uniform_leathers;
		_vest = _vest_leathers;
		_headwear = _headwear_leathers select floor random count _headwear_leathers;
	};
	
	case "military": {
		_uniform = _uniform_military select floor random count _uniforms_military;
		_vest = _vest_military select floor random count _vest_military;
		_headwear = _headwear_military;
		
		if (random 1 < 0.5) then {
			_headwear set [1, ""];
		};
	};
	
	case "sandals": {
		_uniform = _uniform_sandals select floor random count _uniforms_sandals;
		_vest = _vest_sandals select floor random count _vest_sandals;
		_headwear = [
			(_headwear_sandals select 0) select floor random count (_headwear_sandals select 0),
			(_headwear_sandals select 1) select floor random count (_headwear_sandals select 1)
		];
		
		if (random 1 < 0.5) then {
			_headwear set [0, ""];
		};
		
		if (random 1 < 0.5) then {
			_headwear set [1, ""];
		};
	};
	
	case "class": {
		_uniform = _uniform_class;
		_vest = _vest_class select floor random count _vest_class;
		_headwear = [
			(_headwear_class select 0) select floor random count (_headwear_class select 0),
			(_headwear_class select 1) select floor random count (_headwear_class select 1)
		];
		
		if (random 1 < 0.5) then {
			_headwear set [1, ""];
		};
	};
	
	case "terrors": {
		_uniform = _uniform_terrors select floor random count _uniforms_terrors;
		_vest = _vest_terrors select floor random count _vest_terrors;
		_headwear = _headwear_terrors select floor random count _headwear_terrors;
	};
};

//Adding gear. 
[_this, _uniform, _vest, _backpack, _headwear] call caran_addClothing;
[_this, _items] call caran_addInventoryItems;
[_this, _link_items] call caran_addLinkedItems;
[_this, _primary_weapon, _primary_weapon_items, _primary_ammo_array] call caran_addPrimaryWeapon;