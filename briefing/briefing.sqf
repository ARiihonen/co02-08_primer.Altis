//More info: 
//https://community.bistudio.com/wiki/createDiaryRecord
//https://community.bistudio.com/wiki/createDiarySubject
#include "functions.sqf";
#include "..\logic\activeMods.sqf";

//Adds briefing file
player createDiarySubject ["Diary", "Diary"];

_marker_one = format ["'marker_%1'", (buildings_red select 0)];
_marker_two = format ["'marker_%1'", (buildings_red select 1)];
_marker_three = if (count buildings_red == 3) then { format [" <marker name = '%1'>three</marker> ", format ["marker_%1", (buildings_red select 2)] ]; } else { " "; };

_intel_marker = format ["'marker_%1'", (buildings_grn select 0)];
_equip_text = "";
switch (target getVariable 'gang_style') do {
	case 'shemags': { _equip_text = "flaunt their contacts in the Middle East, seeking to shock people by wrapping shemaghs around their heads."; };
	case 'leathers': { _equip_text = "grew from a prominent motorcycle gang, and even though they have moved on from the bikes, they still show the connection to their roots by wearing driving leathers, often incorporating bandannas on their heads."; };
	case 'military': { _equip_text = "are mostly comprised of former AAF, beaten during the war and left to their own devices with no help from their government they served. They will be wearing AAF Camouflage, either on their trousers or jackets, but not full uniform."; };
	case 'sandals': { _equip_text = "formed around the surfing culture of Thelos Bay, and pride themselves in their strictly 'chill' dress. They will be wearing sandals and shorts."; };
	case 'class': { _equip_text = "operate under a mistaken assumption of class, wearing hats and straight pants with white dress shirts. They do not even take the hats off indoors, betraying their uncultured roots."; };
	case 'terrors': { _equip_text = "fancy themselves a regular paramilitary force. They will be wearing balaclavas on their heads."; };
};

_signal = if ( "task_force_radio" call caran_checkMod ) then { "SignalTFAR.txt"; } else {""; };
if ( "acre_" call caran_checkMod ) then { _signal = "SignalACRE.txt"; };

//Add new diary pages with caran_briefingFile. 
//If including variables, add them as a list to the end of the parameters list: ["ExampleSubject", "ExampleName", "ExampleFile", [ExampleParams]]
_credits = ["Diary", "Music", "Credits.txt"] call caran_briefingFile;
if ( "task_force_radio" call caran_checkMod || "acre_" call caran_checkMod ) then {
	["Diary", "Signal", _signal] call caran_briefingFile;
};
_intel = ["Diary", "Intel", "Intel.txt", [_equip_text, _intel_marker]] call caran_briefingFile;
_mission = ["Diary", "Mission", "Mission.txt", [_marker_one, _marker_three, _marker_two]] call caran_briefingFile;
_situation = ["Diary", "Situation", "Situation.txt"] call caran_briefingFile;