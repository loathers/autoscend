script "autoscend/auto_familiar.ash";

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

boolean pathAllowsFamiliar()
{
	if($classes[
	Ed, 
	Avatar of Boris,
	Avatar of Jarlsberg,
	Avatar of Sneaky Pete,
	Vampyre
	] contains my_class())
	{
		return false;
	}
	
	//path check for cases where the path bans familairs and does not use a unique class.
	//since pokefam converts your familiars into pokefam, they are not actually familiars in that path and cannot be used as familiars.
	if($strings[
	License to Adventure,
	Pocket Familiars
	] contains auto_my_path())
	{
		return false;
	}
	
	return true;
}

boolean auto_have_familiar(familiar fam)
{
	if(!pathAllowsFamiliar())
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
	
	if(!pathAllowsFamiliar())
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
	
	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return false;
	}
	
	// if you don't have a familiar, you can't change to it.
	if(!auto_have_familiar(target))
	{
		return false;
	}

	// You are allowed to change to a familiar if it is also the goal of the current 100% run.
	if(get_property("auto_100familiar").to_familiar() == target)
	{
		return true;
	}
	else if(!canChangeFamiliar())
	{
		// checks path limitations, as well as 100% runs for a diferent familiar than target
		return false;
	}
	
	// Don't allow switching to a target of none.
	if(target == $familiar[none])	
	{	
		return false;	
	}

	// if you reached this point, then auto_100familiar must not be set to anything, you are allowed to change familiar.
	return true;
}

familiar lookupFamiliarDatafile(string type)
{
	//This function looks through /data/autoscend_familiars.txt for the matching "type" in order and selects the first match whose conditions are met. Said conditions typically include path exclusions and a check to see if that familiar dropped something today.
	//we do not want a fallback here. if no matching familiar is found then do nothing here, a familiar will be automatically set in pre adventure
	
	auto_log_debug("lookupFamiliarDatafile is checking for type [" + type + "]");
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
				auto_log_error("lookupFamiliarDatafile failed to convert string [" + name + "] to familiar", "red");
				auto_log_error(type + "; " + i + "; " + conds, "red");
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
	if(!pathAllowsFamiliar())
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

	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return false;	//familiar changing temporarily disabled.
	}
	if(!pathAllowsFamiliar())
	{
		return false;
	}
	if(is100FamRun() && get_property("auto_100familiar").to_familiar() != fam)
	{
		return false;	//do not break a 100% familiar run
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
	if(!pathAllowsFamiliar())
	{
		return false;		//will just error in those paths
	}
	familiar familiar_target_100 = get_property("auto_100familiar").to_familiar();
	if(familiar_target_100 != $familiar[none])
	{
		return handleFamiliar(familiar_target_100);		//do not break 100 familiar runs
	}
	
	//High priority checks that are too complicated for the datafile
	familiar famChoice = $familiar[none];

	// Blackbird/Crow cut turns in the Black Forest but we only need to equip them
	// if we don't have them in inventory.
	if ($location[The Black Forest] == place) {
		if (auto_my_path() != "Bees Hate You") {
			if (item_amount($item[Reassembled Blackbird]) == 0 && canChangeToFamiliar($familiar[Reassembled Blackbird])) {
				famChoice = $familiar[Reassembled Blackbird];
			}
		} else {
			if (item_amount($item[Reconstituted Crow]) == 0 && canChangeToFamiliar($familiar[Reconstituted Crow])) {
				famChoice = $familiar[Reconstituted Crow];
			}
		}
	}

	// Gremlins have special familiar handling.
	if ($locations[Next to that Barrel with Something Burning in it, Out By that Rusted-Out Car, Over Where the Old Tires Are, Near an Abandoned Refrigerator] contains place) {
		famChoice = lookupFamiliarDatafile("gremlins");
	}

	// places where item drop is required to help save adventures.
	if ($locations[The Typical Tavern Cellar, The Beanbat Chamber, Cobb's Knob Harem, The Defiled Nook, The Goatlet, Itznotyerzitz Mine,
	Twin Peak, The Penultimate Fantasy Airship, The Hidden Temple, The Hidden Hospital, The Hidden Bowling Alley, The Haunted Wine Cellar,
	The Haunted Laundry Room, The Copperhead Club, A Mob of Zeppelin Protesters, The Red Zeppelin, Whitey's Grove, The Oasis, The Middle Chamber,
	Frat House, Hippy Camp, The Battlefield (Frat Uniform), The Battlefield (Hippy Uniform), The Hatching Chamber,
	The Feeding Chamber, The Royal Guard Chamber, The Hole in the Sky, 8-Bit Realm, The Degrassi Knoll Garage, The Old Landfill,
	The Laugh Floor, Infernal Rackets Backstage] contains place) {
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

	// The World's Biggest Jerk can send us here so only use +item if we're farming sonars.
	if ($location[The Batrat and Ratbat Burrow] == place && internalQuestStatus("questL04Bat") < 3) {
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

	// The World's Biggest Jerk can also send us here so only use +item if we're farming bridge parts.
	if ($location[The Smut Orc Logging Camp] == place && internalQuestStatus("questL09Topping") < 1) {
		famChoice = lookupFamiliarDatafile("item");
	}

	// Killing jar saves adventures unlocking the Pyramid.
	if ($location[The Haunted Library] == place && item_amount($item[killing jar]) < 1 && (get_property("gnasirProgress").to_int() & 4) == 0 && get_property("desertExploration") < 100) {
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

	// places where meat drop is required to help save adventures.
	if ($location[The Themthar Hills] == place) {
		famChoice = lookupFamiliarDatafile("meat");
	}
	
	// places where initiative is required to help save adventures.
	if ($location[The Defiled Alcove] == place) {
		famChoice = lookupFamiliarDatafile("init");
	}

	//Gelatinous Cubeling drops items that save turns in the daily dungeon
	if(famChoice == $familiar[none] &&
	canChangeToFamiliar($familiar[Gelatinous Cubeling]) &&
	get_property("auto_useCubeling").to_boolean() &&
	get_property("auto_cubeItems").to_boolean()
	&& lookupFamiliarDatafile("item") != $familiar[Gelatinous Cubeling]) // don't farm the drops if this is the best +item familiar we have. We will get them regardless.
	{
		famChoice = $familiar[Gelatinous Cubeling];
	}
		
	//grab spleen consumables early if you do not have enough such items to fill up your spleen. Extras will be handled by "drop" datafile
	//Should take around 10 combats to grab enough on day 1 and on subsequent days you should already have them from previous days.
	if(famChoice == $familiar[none])
	{
		int available_spleen_items_size = 0;
		foreach it in $items[Agua De Vida, Grim Fairy Tale, Groose Grease, Powdered Gold, Unconscious Collective Dream Jar]
		{
			if (auto_is_valid(it))
			{
				available_spleen_items_size += 4 * item_amount(it);
			}
		}
		foreach it in $items[beastly paste, bug paste, cosmic paste, oily paste, demonic paste, gooey paste, elemental paste, Crimbo paste, fishy paste, goblin paste, hippy paste, hobo paste, indescribably horrible paste, greasy paste, Mer-kin paste, orc paste, penguin paste, pirate paste, chlorophyll paste, slimy paste, ectoplasmic paste, strange paste]
		{
			//count pastes from fairy-worn boots. excepting excessively expensive pastes.
			if (auto_is_valid(it) && auto_mall_price(it) < 10000 + auto_mall_price($item[gooey paste]))
			{
				available_spleen_items_size += 4 * item_amount(it);
			}
		}
		
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

			int spleen_drops_need = (spleen_left() + 3)/4;
			int bound = (spleen_drops_need + spleenFamiliarsAvailable - 1) / spleenFamiliarsAvailable;
			
			if(spleenFamiliarsAvailable > 0) foreach fam in $familiars[Baby Sandworm, Rogue Program, Pair of Stomping Boots, Bloovian Groose, Unconscious Collective, Grim Brother, Golden Monkey]
			{

				if((fam.drops_today < bound) && canChangeToFamiliar(fam))
				{
					famChoice = fam;
					break;
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
	
	//[Angry Jung Man] drops [psychoanalytic jar]. we want 1 to save adventures on getting [digital key]
	if(famChoice == $familiar[none] &&
	canChangeToFamiliar($familiar[Angry Jung Man]) &&
	!possessEquipment($item[Powerful Glove]) &&		//powerful glove is a better way to get digital key
	$familiar[Angry Jung Man].drops_today < 1)
	{
		famChoice = $familiar[Angry Jung Man];
	}
	
	// places where meat drop is desirable due to high meat drop monsters.
	if ($locations[The Boss Bat's Lair, Mist-Shrouded Peak, The Icy Peak, The Filthworm Queen's Chamber] contains place) {
		famChoice = lookupFamiliarDatafile("meat");
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