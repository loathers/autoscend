boolean is100FamRun()
{
	// answers the question of "is this a 100% familiar run"
	
	if(get_property("auto_100familiar").to_familiar() == $familiar[none])
	{
		return false;
	}
	
	// if you reached this line, then it means that auto_100familiar is set to some specific familiar.
	return true;
}

boolean doNotBuffFamiliar100Run()
{
	//indicates that we are in a 100% familiar run with a familiar that should not be buffed. Either because it hinders you or is useless.
	//this list was last updated after ghost of crimbo commerce familiar was added.
	if(!is100FamRun())
	{
		return false;
	}
	familiar hundred_fam = to_familiar(get_property("auto_100familiar"));
	
	//these familiars always harm you and never aid you
	if($familiars[black cat, O.A.F.] contains hundred_fam)
	{
		return true;
	}
	
	//these familiars sometimes harm you and sometimes attack the enemy
	if($familiars[Fuzzy Dice, Stab Bat, Killer Bee, Scary Death Orb, RoboGoose] contains hundred_fam)
	{
		return true;
	}
	
	//these familiars do not actively hinder you. insead they simply do nothing. should not be buffed to save on MP.
	if($familiars[Pet Rock, Toothsome Rock, Bulky Buddy Box, Holiday Log, Homemade Robot, Software Bug, Bad Vibe, Pet Coral] contains hundred_fam)
	{
		return true;
	}
	
	return false;
}

boolean isAttackFamiliar(familiar fam)
{
	//is the familiar called fam able to deal damage to the enemy
	if(fam.physical_damage || fam.elemental_damage)
	{
		return true;
	}
	
	//these familiars vary by configuration. TODO actually check their configuration
	if($familiars[Mini-Crimbot,
	El Vibrato Megadrone,
	Reanimated Reanimator,
	Comma Chameleon,
	Mad Hatrack,
	Fancypants Scarecrow
	] contains fam)
	{
		return true;
	}
	if(fam == $familiar[Mini-Adventurer])
	{
		int miniAdvClass = get_property("miniAdvClass").to_int();
		if(miniAdvClass == 1 ||		//seal clubber
		(miniAdvClass == 2 && my_level() >= 5) ||		//turtle tamer
		(miniAdvClass == 3 && my_level() >= 15) ||		//pastamancer
		(miniAdvClass == 4 && my_level() >= 5) ||		//sauceror
		(miniAdvClass == 5 && my_level() >= 10))		//disco bandit
		{
			return true;
		}
		return false;
	}
	if(fam == $familiar[Reagnimated Gnome])
	{
		//can be an attack familiar with this part equipped
		//todo: is it possible to know if it will be equipped after this check?
		if(possessEquipment($item[gnomish athlete\'s foot]))
		{
			return true;
		}
		//but not if the part is not even owned
		return false;
	}
	
	if($familiars[Doppelshifter,				//random familiar every fight. can be an attack familiar
	Dandy Lion									//attacks if you equip a whip.
	] contains fam)
	{
		return true;
	}
	
	return false;
}

boolean auto_famKill(familiar fam, location place)
{
	if(!isAttackFamiliar(fam))
	{
		return false;
	}

	int passiveDamage = numeric_modifier("Damage Aura") + numeric_modifier("Sporadic Damage Aura ") + numeric_modifier("Thorns") + numeric_modifier("Sporadic Thorns");
	
	foreach mon, freq in appearance_rates(place)
	{
		//Mafia doesn't output the expected damage of the familiar so going with the highest possible for most users (NPZR)
		if(mon != $monster[none] && monster_hp(mon) < (floor(1.5 * (familiar_weight(fam) +weight_adjustment() + 3)) + passiveDamage))
		{
			return true;
		}
	}
	return false;
}

boolean pathHasFamiliar() 	// check for cases where the path bans traditional familiars.
{
	if(is_boris() || is_jarlsberg() || is_pete() || isActuallyEd() || in_darkGyffte() || in_lta() || in_pokefam())
	{
		return false;
	}
	
	//You, Robot has familiars... but only if your head attachment is set to birdcage.
	if(in_robot() && get_property("youRobotTop").to_int() != 2)
	{
		return false;	//our top is not currently set to birdcage so familiars are disabled.
	}
	
	return true;
}

boolean pathAllowsChangingFamiliar()
{
		if(!pathHasFamiliar())
		{
			return false;
		}

		// path check for case(s) where Path has familiars but forces you to use one of its choice
		if(in_quantumTerrarium())
		{
			return false;
		}

	return true;
}

boolean auto_have_familiar(familiar fam)
{
	if(!pathHasFamiliar())
	{
		return false;
	}
	if(!auto_is_valid(fam))
	{
		return false;
	}
	
	//handle blacklisting of familiars by users
	int[familiar] blacklist;
	if(get_property("auto_blacklistFamiliar") != "")
	{
		string[int] noFams = split_string(get_property("auto_blacklistFamiliar"), ";");
		foreach index, fam in noFams
		{
			blacklist[to_familiar(trim(fam))] = 1;
		}
	}
	if(blacklist contains fam)
	{
		return false;
	}
	
	return have_familiar(fam);
}

boolean canChangeFamiliar()
{
	// answers the question "am I allowed to change familiar?" in the general sense
	
	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return false;
	}
	
	if(is100FamRun())
	{
		return false;
	}
	
	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return false;
	}
	
	return true;
}

boolean canChangeToFamiliar(familiar target)
{
	// answers the question of "am I allowed to change familiar to a familiar named target"
	
	if(my_familiar() == target)
	{
		return true;
	}

	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return false;
	}
	
	// if you don't have a familiar, you can't change to it.
	if(!auto_have_familiar(target))
	{
		return false;
	}
	
	// if this path doesn't allow this familiar, you can't change to it
	if(!auto_is_valid(target))
	{
		return false;
	}
	
	// You are allowed to change to a familiar if it is also the goal of the current 100% run.
	if(get_property("auto_100familiar").to_familiar() == target)
	{
		return true;
	}
	
	//kolhs specific check that needs to go here specifically. can not take familiars >10 lbs base weight into school zone.
	if(kolhs_mandatorySchool() || 				//we are in kolhs and are adventuring in a school zone
	get_property("_NC772_directive") != "")		//we are in kolhs and doing saved by the bell NC
	{
		if(target != $familiar[Steam-Powered Cheerleader] &&	//sole exception to the rule
		familiar_weight(target) > 10)
		{
			return false;
		}
	}

	// Avant Guard specific allowance of familiars for non-adv.php zones
	if (in_avantGuard())
	{
		if ($familiar[Burly Bodyguard] == target)
		{
			return true; // always allowed
		}
		else if (get_property("auto_nonAdvLoc").to_boolean())
		{
			if ($familiar[Gelatinous Cubeling] == target && in_hardcore())
			{
				return true; // don't need Gel Cube in Normal
			}
			else if ($familiars[Cookbookbat, Mini Kiwi] contains target)
			{
				return true; // might be worth farming some of these drops if we can?
			}
		}
		return false;
	}

	// Don't allow switching to a target of none.
	if(target == $familiar[none])	
	{	
		return false;	
	}
	
	// You are allowed to use your /current/ familiar in Quantum Terrarium runs.
	if(target == my_familiar() && in_quantumTerrarium())
	{
		return true;
	}

	// check path limitations, as well as 100% runs for a different familiar than target
	if(!canChangeFamiliar())
	{
		return false;
	}
	
	// If target is in the Crown of Thrones or Buddy Bjorn, we can't switch to it either.
	if (target == my_enthroned_familiar() || target == my_bjorned_familiar())
	{
		return false;
	}

	// if you reached this point, then auto_100familiar must not be set to anything, you are allowed to change familiar.
	return true;
}

familiar findNonRockFamiliarInTerrarium()
{
	static boolean[familiar] blacklistFamiliars = $familiars[pet rock,
		toothsome rock,
		bulky buddy box,
		holiday log,
		software bug,
		bad vibe,
		pet coral,
		synthetic rock,
		pixel rock];

	foreach fam in $familiars[]
	{
		if(blacklistFamiliars contains fam)
		{
			continue;
		}
		if(in_terrarium(fam) && have_familiar(fam))
		{
			return fam;
		}
	}
	return $familiar[none];
}

familiar findRockFamiliarInTerrarium()
{
	static boolean[familiar] petRockFamiliars = $familiars[pet rock,
		toothsome rock,
		bulky buddy box,
		holiday log,
		software bug,
		bad vibe,
		pet coral,
		synthetic rock,
		pixel rock];

	foreach fam in $familiars[]
	{
		if(in_terrarium(fam) && have_familiar(fam) && petRockFamiliars contains fam)
		{
			return fam;
		}
	}
	return $familiar[none];
}

familiar lookupFamiliarDatafile(string type)
{
	//This function looks through /data/autoscend_familiars.txt for the matching "type" in order and selects the first match whose conditions are met. Said conditions typically include path exclusions and a check to see if that familiar dropped something today.
	//we do not want a fallback here. if no matching familiar is found then do nothing here, a familiar will be automatically set in pre adventure
	
	auto_log_debug("lookupFamiliarDatafile is checking for type [" + type + "]");
	// store what type of fam we are looking for
	set_property("auto_lastFamiliarLookupType",type);
	string [string,int,string] familiars_text;
	if(!file_to_map("autoscend_familiars.txt", familiars_text))
	{
		abort("Could not load /data/autoscend_familiars.txt");
	}
	foreach i,name,conds in familiars_text[type]
	{
		familiar thisFamiliar = name.to_familiar();
		if(thisFamiliar == $familiar[none])
		{
			if(name != "none")
			{
				auto_log_error("lookupFamiliarDatafile failed to convert string [" + name + "] to familiar");
				auto_log_error(type + "; " + i + "; " + conds);
			}
			continue;
		}
		if(!auto_check_conditions(conds))		//checks for the conditions specified in the data file
			continue;
		if(!canChangeToFamiliar(thisFamiliar))	//check various things that could prevent us from changing to it
			continue;
		return thisFamiliar;
	}
	
	//no suitable familiars found in datafile
	auto_log_debug(`Could not find any "{type}" type familiars!`);
	return $familiar[none];
}

boolean handleFamiliar(string type)
{
	//This function calls familiar lookupFamiliarDatafile(string type) and if a result is found will send it over to handleFamiliar(familiar fam) so it can be set as our target familiar to be used during pre adventure.
	//we do not want a fallback here. if no matching familiar is found then do nothing here, a familiar will be automatically set in pre adventure
	
	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return false;	//familiar changing temporarily disabled.
	}
	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return false;
	}
	
	familiar target = lookupFamiliarDatafile(type);
	
	if(target != $familiar[none])
	{
		return handleFamiliar(target);
	}
	return false;
}

boolean handleFamiliar(familiar fam)
{
	//This function takes a specific named familiar and sets it as our target familiar. To be changed during pre_adventure.

	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return false;
	}
	if(fam == $familiar[none])
	{
		return false;
	}
	if(get_property("auto_familiarChoice").to_familiar() == fam)	//this should go after $familiar[none] check
	{
		return true;	//desired target is already set as the familiar I will be switching to.
	}
	
	//[Ms. Puck Man] and [Puck Man] are interchangeable. so interchange them if needed.
	if((fam == $familiar[Ms. Puck Man]) && !auto_have_familiar($familiar[Ms. Puck Man]) && auto_have_familiar($familiar[Puck Man]))
	{
		fam = $familiar[Puck Man];
	}
	if((fam == $familiar[Puck Man]) && !auto_have_familiar($familiar[Puck Man]) && auto_have_familiar($familiar[Ms. Puck Man]))
	{
		fam = $familiar[Ms. Puck Man];
	}
	
	if(!canChangeToFamiliar(fam))
	{
		return false;
	}
	
	//bjorning has priority
	if(my_bjorned_familiar() == fam)
	{
		return false;
	}

	set_property("auto_familiarChoice", fam);
	set_property("_auto_thisLoopHandleFamiliar", true);
	return true;
}

boolean autoChooseFamiliar(location place)
{
	//if no familiar target was set this loop. then automatically determine which familiar to use
	
	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return false;
	}
	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return false;		//will just error in those paths
	}
	familiar familiar_target_100 = get_property("auto_100familiar").to_familiar();
	if(familiar_target_100 != $familiar[none])
	{
		return handleFamiliar(familiar_target_100);		//do not break 100 familiar runs
	}
	
	// Can only use burly bodyguard, except in non-adventure.php zones. In those, we want the Gelatinous Cubeling for Daily Dungeon drops
	if (in_avantGuard())
	{
		if (get_property("auto_nonAdvLoc").to_boolean())
		{
			if (wantCubeling())
			{
				return handleFamiliar($familiar[Gelatinous Cubeling]);
			}
			else
			{
				foreach fam in $familiars[Cookbookbat, Mini Kiwi, Hobo in Sheep's Clothing]
				{
					if (canChangeToFamiliar(fam))
					{
						return handleFamiliar(fam);
					}
				}
			}
		}
		return handleFamiliar($familiar[Burly Bodyguard]);
	}
	
	//High priority checks that are too complicated for the datafile
	familiar famChoice = $familiar[none];

	// Blackbird/Crow cut turns in the Black Forest but we only need to equip them
	// if we don't have them in inventory.
	if($location[The Black Forest] == place)
	{
		if(!in_bhy())
		{
			if(item_amount($item[Reassembled Blackbird]) == 0 && canChangeToFamiliar($familiar[Reassembled Blackbird]))
			{
				famChoice = $familiar[Reassembled Blackbird];
			}
		}
		else
		{
			if(item_amount($item[Reconstituted Crow]) == 0 && canChangeToFamiliar($familiar[Reconstituted Crow]))
			{
				famChoice = $familiar[Reconstituted Crow];
			}
		}
	}

	// Gremlins have special familiar handling.
	if ($locations[Next to that Barrel with Something Burning in it, Out By that Rusted-Out Car, Over Where the Old Tires Are, Near an Abandoned Refrigerator] contains place) {
		famChoice = lookupFamiliarDatafile("gremlins");
	}
	
	// places where item drop is required to help save adventures.
	if ($locations[Guano Junction, The Beanbat Chamber, Cobb's Knob Harem, The Goatlet, Itznotyerzitz Mine,
	Twin Peak, The Penultimate Fantasy Airship, The Hidden Temple, The Hidden Bowling Alley, The Haunted Wine Cellar,
	The Haunted Laundry Room, The Copperhead Club, A Mob of Zeppelin Protesters, Whitey's Grove, The Oasis, The Middle Chamber,
	The Orcish Frat House, The Hippy Camp, The Hatching Chamber,
	The Feeding Chamber, The Royal Guard Chamber, The Hole in the Sky, Hero's Field, The Degrassi Knoll Garage, The Old Landfill,
	The Laugh Floor, Infernal Rackets Backstage] contains place) {
		famChoice = lookupFamiliarDatafile("item");
	}
	if (place == $location[Inside the Palindome] && item_amount($item[Stunt Nuts]) == 0 && item_amount($item[Wet Stunt Nut Stew]) == 0) {
		famChoice = lookupFamiliarDatafile("item");
	}
	if (place == $location[The Red Zeppelin] && internalQuestStatus("questL11Ron") < 4)	{
		famChoice = lookupFamiliarDatafile("item");	//not useful for Ron Copperhead
	}
	if (place == auto_availableBrickRift()) {
		famChoice = lookupFamiliarDatafile("item"); // get more shadow bricks
	}
	if ($location[The Defiled Cranny] == place && auto_turbo() && item_amount($item[dieting pill]) + get_property("auto_dietpills").to_int() < 3)
	{
		famChoice = lookupFamiliarDatafile("item"); // get dieting pills faster if in turbo
	}

	// If we're down to 1 evilness left before the boss in the Nook, it doesn't matter if we get an Evil Eye or not.
	if ($location[The Defiled Nook] == place && get_property("cyrptNookEvilness").to_int() > 14)
	{
		famChoice = lookupFamiliarDatafile("item");
	}

	// only need +item in the pirates cove if we're faming the outfit (may be farming insults here or getting the key in LKS otherwise)
	if ($location[The Obligatory Pirate's Cove] == place && !possessOutfit("Swashbuckling Getup")) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// Only need +item in the F'c'le if we're getting the fledges (could still be getting the key in LKS)
	if ($location[The F'c'le] == place && internalQuestStatus("questM12Pirate") < 6) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// if we somehow end up in The Valley of Rof L'm Fao might as well try to get N 
	if ($location[The Valley of Rof L\'m Fao] == place && item_amount($item[lowercase N]) == 0 && item_amount($item[ND]) == 0 && item_amount($item[Wand of Nagamar]) == 0 && get_property("auto_wandOfNagamar").to_boolean()) {
		famChoice = lookupFamiliarDatafile("item");
	}
	// the D is only individually useful in paths that also visit The Valley of Rof L\'m Fao for N
	// this is only in Low Key Summer for now, but can be in other paths if they get support: Journeyman, Grey You
	if ($location[The Castle in the Clouds in the Sky (Basement)] == place && item_amount($item[heavy D]) == 0 && item_amount($item[ND]) == 0 && item_amount($item[Wand of Nagamar]) == 0 && get_property("auto_wandOfNagamar").to_boolean()) {
		boolean wantTheD = in_lowkeysummer() && (item_amount($item[lowercase N]) > 0 || $location[The Valley of Rof L\'m Fao].turns_spent < 11);	//!possessEquipment($item[Kekekey])
		if(wantTheD)
		{
			famChoice = lookupFamiliarDatafile("item");
		}
	}

	// The World's Biggest Jerk can send us here so only use +item if we're farming sonars.
	if ($location[The Batrat and Ratbat Burrow] == place && internalQuestStatus("questL04Bat") < 3 && auto_haveGreyGoose()) {
		auto_log_info("Bringing the Grey Goose to emit some drones at a bat to get Sonar.");
		famChoice = $familiar[Grey Goose];
	}
	else if ($location[The Batrat and Ratbat Burrow] == place && internalQuestStatus("questL04Bat") < 3) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// only need +item on the extreme slope if we're faming the outfit.
	if ($location[The eXtreme Slope] == place && !possessOutfit("eXtreme Cold-Weather Gear")) {
		famChoice = lookupFamiliarDatafile("item");
	}
	
	// only use +item in A-Boo Peak when adventuring (so we don't accidentally override resistance familiars when doing The Horror).
	if ($location[A-Boo Peak] == place && get_property("auto_aboopending").to_int() == 0) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// only need +item at Oil Peak if we need Bubblin' Crude (TODO: it might be useful in HC for food?).
	if ($location[Oil Peak] == place &&
	((get_property("twinPeakProgress").to_int() & 4) == 0 &&
		item_amount($item[Jar Of Oil]) < 1 && item_amount($item[Bubblin\' Crude]) < 12))  {
		famChoice = lookupFamiliarDatafile("item");
	}

	// If we have Grey Goose and we're farming bridge parts and Smut Orc Pervert is coming up, we should use the Goose to dupe the Keepsake box
	if ($location[The Smut Orc Logging Camp] == place && internalQuestStatus("questL09Topping") < 1 && is_integer(($location[The Smut Orc Logging Camp].turns_spent - 1)/20) && auto_haveGreyGoose())
	{
		auto_log_info("Bringing the Grey Goose to emit some drones at smut orc pervert to dupe a Box.");
		famChoice = $familiar[Grey Goose];
	}

	// The World's Biggest Jerk can also send us here so only use +item if we're farming bridge parts.
	if ($location[The Smut Orc Logging Camp] == place && internalQuestStatus("questL09Topping") < 1) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// Killing jar saves adventures unlocking the Pyramid.
	if ($location[The Haunted Library] == place && item_amount($item[killing jar]) < 1 && (get_property("gnasirProgress").to_int() & 4) == 0 && get_property("desertExploration").to_int() < 100) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// +item helps if we still need the book of matches
	if ($location[The Hidden Park] == place && get_property("hiddenTavernUnlock").to_int() != my_ascensions()) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// only need +item in the war camps if we are farming the outfit.
	if ($locations[Wartime Frat House, Wartime Hippy Camp] contains place) {
		if (!possessOutfit("Frat Warrior Fatigues") || !possessOutfit("War Hippy Fatigues")) {
			famChoice = lookupFamiliarDatafile("item");
		}
	}

	// want to ensure we get small gear. Only requires +100 item drop, fam essentially ensures this
	if ($locations[Fight in the Dirt, Fight in the Tall Grass, Fight in the Very Tall Grass] contains place) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// places where meat drop is required to help save adventures.
	if ($location[The Themthar Hills] == place) {
		famChoice = lookupFamiliarDatafile("meat");
	}
	if ($location[The Fungus Plains] == place) {
		famChoice = lookupFamiliarDatafile("meat");
	}
	
	// places where initiative is required to help save adventures.
	if ($location[The Defiled Alcove] == place && get_property("cyrptAlcoveEvilness").to_int() > 14)
	{
		famChoice = lookupFamiliarDatafile("init");
	}
	if($location[Vanya\'s Castle] == place)
	{
		famChoice = lookupFamiliarDatafile("init");
	}

	famChoice = auto_forceEagle(famChoice); // force Patriotic Eagle if we have a >0 combats until we can screech again

	//Gelatinous Cubeling drops items that save turns in the daily dungeon
	if(famChoice == $familiar[none] &&
	wantCubeling() &&
	lookupFamiliarDatafile("item") != $familiar[Gelatinous Cubeling]) // don't farm the drops if this is the best +item familiar we have. We will get them regardless.
	{
		famChoice = $familiar[Gelatinous Cubeling];
	}
		
	//grab spleen consumables early if you do not have enough such items to fill up your spleen. Extras will be handled by "drop" datafile
	//Should take around 10 combats to grab enough on day 1 and on subsequent days you should already have them from previous days.
	if(famChoice == $familiar[none])
	{
		int available_spleen_items_size = 4 * auto_spleenFamiliarAdvItemsPossessed();
		
		if(spleen_left() >= (4 + available_spleen_items_size) && haveSpleenFamiliar())
		{
			int spleenFamiliarsAvailable = 0;
			foreach fam in $familiars[Baby Sandworm, Rogue Program, Pair of Stomping Boots, Bloovian Groose, Unconscious Collective, Grim Brother, Golden Monkey]
			{
				if(canChangeToFamiliar(fam))
				{
					spleenFamiliarsAvailable++;
				}
			}
			
			if(spleenFamiliarsAvailable > 0)
			{
				int spleen_drops_need = (spleen_left() + 3)/4;
				int bound = (spleen_drops_need + spleenFamiliarsAvailable - 1) / spleenFamiliarsAvailable;
				foreach fam in $familiars[Baby Sandworm, Rogue Program, Pair of Stomping Boots, Bloovian Groose, Unconscious Collective, Grim Brother, Golden Monkey]
				{
					if((fam.drops_today < bound) && canChangeToFamiliar(fam))
					{
						famChoice = fam;
						break;
					}
				}
			}
		}
	}

	//[grimstone mask] for an [ornate dowsing rod] for the desert. if still needed
	if(famChoice == $familiar[none] &&
	canChangeToFamiliar($familiar[Grimstone Golem]) &&
	!possessEquipment($item[Ornate Dowsing Rod]) &&
	item_amount($item[Odd Silver Coin]) < 5 &&
	item_amount($item[Grimstone Mask]) == 0 &&
	$familiar[Grimstone Golem].drops_today < 1 &&
	considerGrimstoneGolem(false))
	{
		famChoice = $familiar[Grimstone Golem];
	}
	
	// places where meat drop is desirable due to high meat drop monsters.
	if ($locations[The Boss Bat's Lair, The Icy Peak, The Filthworm Queen's Chamber] contains place) {
		famChoice = lookupFamiliarDatafile("meat");
	}
	if (place == $location[Mist-Shrouded Peak] && place.turns_spent < 3) {
		famChoice = lookupFamiliarDatafile("meat");	//not useful for Groar
	}

	//if critically low on MP and meat. use restore familiar to avoid going bankrupt
	boolean poor = my_meat() < 1000;
	if(internalQuestStatus("questL11MacGuffin") < 2)
	{
		poor = my_meat() < 7000;
	}
	if(famChoice == $familiar[none] && 	my_maxmp() > 50 && 	my_mp()*5 < my_maxmp() && poor)
	{
		famChoice = lookupFamiliarDatafile("regen");
	}
	
	//select the best familiar that drops items directly. Will prioritize useful items and awesome+ food and drink and then other drops.
	if(famChoice == $familiar[none])
	{
		famChoice = lookupFamiliarDatafile("drop");
	}
	
	// Stats from combats makes runs go faster apparently.
	if (famChoice == $familiar[none] && (my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean())) {
		famChoice = lookupFamiliarDatafile("stat");
	}
	
	// fallback to regen if nothing else. At worst the player will have something like a Ghuol Whelp or Starfish.
	if (famChoice == $familiar[none]) {
		famChoice = lookupFamiliarDatafile("regen");
	}

	// in legacy of loathing, may only have 1 of the 2004 fams
	if (famChoice == $familiar[none]) {
		foreach fam in $familiars[Jill-O-Lantern, Hand Turkey, Crimbo Elf]
		{
			if(canChangeToFamiliar(fam))
			{
				famChoice = fam;
				break;
			}
		}
	}

	return handleFamiliar(famChoice);
}

boolean haveSpleenFamiliar()
{
	foreach fam in $familiars[Baby Sandworm, Rogue Program, Pair of Stomping Boots, Bloovian Groose, Unconscious Collective, Grim Brother, Golden Monkey]
	{
		if(auto_have_familiar(fam))
		{
			return true;
		}
	}
	return false;
}

boolean wantCubeling()
{
	//do we still want to use a gelatinous cubeling familiar specifically for it to drop the daily dungeon tools
	if (!canChangeToFamiliar($familiar[Gelatinous Cubeling]))
	{
		return false;	//can not use it so we do not want it.
	}
	if(get_property("cubelingProgress").to_int() > 11)
	{
		return false;	//cubeling already dropped tools in this ascension. It cannot drop more until you ascend again.
	}
	
	boolean need_lockpicks = item_amount($item[pick-o-matic lockpicks]) == 0 && item_amount($item[Platinum Yendorian Express Card]) == 0;
	boolean need_ring = !possessEquipment($item[Ring of Detect Boring Doors]);	//do not try for a second one if you already have one
	boolean need_pole = !auto_haveCCSC() && item_amount($item[eleven-foot pole]) == 0;
	return need_pole || need_ring || need_lockpicks;
}

void preAdvUpdateFamiliar(location place)
{
	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return;
	}
	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return;		//will just error in those paths
	}
	if(is100FamRun())
	{
		handleFamiliar(get_property("auto_100familiar").to_familiar());			//do not break 100 familiar runs
	}
	
	//familiar requirement to adventure in a zone, override everything else.
	if(place == $location[The Deep Machine Tunnels])
	{
		handleFamiliar($familiar[Machine Elf]);
	}
	// Can't take familiars with you to FantasyRealm
	if (place == $location[The Bandit Crossroads])
	{
		if(my_familiar() == $familiar[none]) return;		//avoid mafia error from trying to change none into none.
		use_familiar($familiar[none]);
		return;		//no familiar means no equipment, we are done.
	}
	
	//if familiar not set yet, first check stealing familiar
	if(!get_property("_auto_thisLoopHandleFamiliar").to_boolean() && canChangeToFamiliar($familiar[cat burglar]) && catBurglarHeistsLeft() > 0)
	{
		//Stealing with familiar. TODO add XO Skelton here too
		
		item[monster] heistDesires = catBurglarHeistDesires();
		boolean wannaHeist = false;
		foreach mon, it in heistDesires
		{
			foreach i, mmon in get_monsters(place)
			{
				if(mmon == mon)
				{
					auto_log_debug("Using cat burglar because we want to burgle a " + it + " from " + mon);
					wannaHeist = true;
				}
			}
		}
		if(wannaHeist)
		{
			handleFamiliar($familiar[cat burglar]);
		}
	}
	
	//if familiar not set choose a familiar using general logic
	if(!get_property("_auto_thisLoopHandleFamiliar").to_boolean())		//check that we didn't already set familiar target this loop
	{
		autoChooseFamiliar(place);
	}
	
	familiar famChoice = to_familiar(get_property("auto_familiarChoice"));
	if(famChoice == $familiar[none])
	{
		if(get_property("auto_familiarChoice") == "")
		{
			abort("void preAdvUpdateFamiliar failed because property auto_familiarChoice is empty for some reason");
		}
		abort("void preAdvUpdateFamiliar failed to convert auto_familiarChoice of [" + get_property("auto_familiarChoice") + "] into a $familiar");
	}
	
	if(famChoice != my_familiar() && canChangeToFamiliar(famChoice))
	{
		use_familiar(famChoice);
	}
	
	//familiar equipment overrides
	if(in_heavyrains())
	{
		if(famChoice != $familiar[Left-Hand Man])
		{
			autoEquip($slot[familiar], $item[miniature life preserver]);
		}
	}

	if (my_familiar() == $familiar[Reagnimated Gnome])
	{
		// This arena visit to obtain gnome familiar equips is turn free and can be done once a day.
		boolean visitArena = false;
		foreach it in $items[gnomish swimmer's ears, gnomish coal miner's lung, gnomish tennis elbow, gnomish housemaid's kgnee, gnomish athlete's foot]
		{
			if (available_amount(it) == 0)
			{
				visitArena = true;
				break;
			}
		}
		// only visit the cake-shaped arena if we need to pickup an equipment.
		if (!get_property("_auto_gnomeArenaVisited").to_boolean() && visitArena)
		{
			visit_url("arena.php");
			run_choice(-1);
			set_property("_auto_gnomeArenaVisited", "true");
		}
		autoEquip($slot[familiar], $item[gnomish housemaid\'s kgnee]);
	}

	if (my_familiar() == $familiar[Baby Bugged Bugbear])
	{
		if (!possessEquipment($item[Bugged beanie]))
		{
			// Once per day, if you don't have the Bugged Beanie equipped, in inventory or closet
			// you can get one for free by visiting the arena
			visit_url("arena.php");
		}
	}

	if(my_familiar() == $familiar[Trick-Or-Treating Tot])
	{
		if($locations[A-Boo Peak, The Haunted Kitchen] contains place)
		{
			if(equipped_item($slot[Familiar]) != $item[Li\'l Candy Corn Costume])
			{
				if(item_amount($item[Li\'l Candy Corn Costume]) > 0)
				{
					equip($slot[Familiar], $item[Li\'l Candy Corn Costume]);
				}
			}
		}
	}

	if (my_familiar() == $familiar[Jill-of-All-Trades] && possessEquipment($item[LED candle]))
	{
		// maximizer uses whatever mode LED candle is in, won't change it
		// so ensure in correct mode prior to maximizing
		auto_handleJillOfAllTrades();
		autoEquip($item[LED Candle]); // force maximizer to equip it when we have it.
	}
	
	if(auto_checkFamiliarMummery(my_familiar()))
	{
		mummifyFamiliar();
	}
}

boolean auto_needsGoodFamiliarEquipment() {
	if (possessEquipment($item[Astral pet sweater])) {
		return false;
	}
	if (auto_hasStillSuit()) {
		return false;
	}
	if (auto_haveCupidBow()) {
		return false;
	}
	return true;
}
