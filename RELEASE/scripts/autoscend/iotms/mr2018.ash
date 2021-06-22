#	This is meant for items that have a date of 2018.

boolean isjanuaryToteAvailable()
{
	return item_amount($item[January\'s Garbage Tote]) > 0 && auto_is_valid($item[January\'s Garbage Tote]);
}

int januaryToteTurnsLeft(item it)
{
	if(!isjanuaryToteAvailable()){
		return 0;
	}

	int score = 0;

	if(get_revision() < 18848)
	{
		switch(it)
		{
		case $item[Deceased Crimbo Tree]:		score = get_property("_garbageTreeCharge").to_int();		break;
		case $item[Broken Champagne Bottle]:	score = get_property("_garbageChampagneCharge").to_int();	break;
		case $item[Makeshift Garbage Shirt]:	score = get_property("_garbageShirtCharge").to_int();		break;
		}
		return score;
	}

	switch(it)
	{
	case $item[Deceased Crimbo Tree]:		score = get_property("garbageTreeCharge").to_int();			break;
	case $item[Broken Champagne Bottle]:	score = get_property("garbageChampagneCharge").to_int();	break;
	case $item[Makeshift Garbage Shirt]:	score = get_property("garbageShirtCharge").to_int();		break;
	}

	if(!get_property("_garbageItemChanged").to_boolean())
	{
		switch(it)
		{
		case $item[Deceased Crimbo Tree]:		score += 1000;		break;
		case $item[Broken Champagne Bottle]:	score += 11;		break;
		case $item[Makeshift Garbage Shirt]:	score += 37;		break;
		}
	}
	return score;
}

boolean januaryToteAcquire(item it)
{
	//a function to acquire january's garbage tote equipment. like basic acquire command, this also returns true if you already have the item on hand.
	
	if(!isjanuaryToteAvailable())
	{
		return false;
	}
	
	//in pre_adventure we routinely switch to wad of used tape. This allows us to avoid switching away from a desired item.
	//can't use adventure count in case of free fights.
	set_property("auto_januaryToteAcquireCalledThisTurn", true);
	
	//by default resetMaximize() will add a block for not equipping garbage tote items with charges to preserve the charges.
	//If we call januaryToteAcquire for an item we want to remove that block for that item.
	if($items[Deceased Crimbo Tree, Broken Champagne Bottle, Makeshift Garbage Shirt] contains it)
	{
		removeFromMaximize("-equip " + it);
	}
	
	//Special handling for if we already have the item on hand. We might want to replace it with itself
	//do not use possessEquipment nor equipmentAmount here, they have special handling for tote foldables that always counts number of january's garbage totes instead of the target item. Resulting in this if always being true.
	if(available_amount(it) > 0)
	{
		int leftover_charges = 0;
		if(get_property("_garbageItemChanged").to_boolean())
		{
			return true;		//item already swapped today eliminating leftover charges. don't replace an item with itself.
		}
		else
		{
			//since item was not changed yet, count leftover charges from yesterday.
			//If target item has no charges at all then pretend it has 1 leftover to not replace it with itself.
			switch(it)
			{
			case $item[Deceased Crimbo Tree]:		leftover_charges = get_property("garbageTreeCharge").to_int();			break;
			case $item[Broken Champagne Bottle]:	leftover_charges = get_property("garbageChampagneCharge").to_int();		break;
			case $item[Tinsel Tights]:				leftover_charges = 1;													break;
			case $item[Wad Of Used Tape]:			leftover_charges = 1;													break;
			case $item[Makeshift Garbage Shirt]:	leftover_charges = get_property("garbageShirtCharge").to_int();			break;
			}
		}
		if(leftover_charges > 0)
		{
			return true;		//preserve leftover charges by keeping current instance of the item.
		}
	}
	
	int choice = 0;
	switch(it)
	{
	case $item[Deceased Crimbo Tree]:			choice = 1;		break;
	case $item[Broken Champagne Bottle]:		choice = 2;		break;
	case $item[Tinsel Tights]:					choice = 3;		break;
	case $item[Wad Of Used Tape]:				choice = 4;		break;
	case $item[Makeshift Garbage Shirt]:		choice = 5;		break;
	case $item[Letter For Melvign The Gnome]:	choice = 7;		break;
	}

	if(choice == 2)
	{
		if((auto_my_path() == "Way of the Surprising Fist") || in_boris())
		{
			return false;
		}
	}

	if((choice == 5) && !hasTorso())
	{
		return false;
	}

	if(choice == 0)
	{
		return false;
	}

	if(choice == 7)
	{
		//can only get one letter per ascension
		if(get_property("questM22Shirt") != "unstarted" || item_amount($item[Letter For Melvign The Gnome]) > 0)
		{
			return false;
		}
		if(available_amount($item[Makeshift Garbage Shirt]) == 0)		//only rummage a new shirt if we don't already have one on hand.
		{
			visit_url("inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=9690", false);	//rummage in your garbage tote
			run_choice(5);																	//get garbage shirt
		}
		visit_url("inv_equip.php?pwd=&which=2&action=equip&whichitem=9699");		//url fail to equip shirt to get a letter
	}
	else
	{
		visit_url("inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=9690", false);	//rummage in your garbage tote
		run_choice(choice);																//get desired item
	}
	
	if(item_amount(it) > 0)
	{
		return true;
	}
	return false;
}

int auto_godLobsterFightsRemaining()
{
	return 3 - get_property("_godLobsterFights").to_int();
}

boolean godLobsterCombat()
{
	return godLobsterCombat($item[none]);
}

boolean godLobsterCombat(item it)
{
	return godLobsterCombat(it, 3);
}

boolean godLobsterCombat(item it, int goal)
{
	return godLobsterCombat(it, goal, "");
}

boolean godLobsterCombat(item it, int goal, string option)
{
	// it = equipment we want the God Lobster to wear
	// goal = option we want to select in the post-combat choice
	if(!canChangeToFamiliar($familiar[God Lobster]))
	{
		return false;
	}
	if((goal < 1) || (goal > 3))
	{
		return false;
	}
	if(get_property("_godLobsterFights").to_int() >= 3)
	{
		return false;
	}
	if((it != $item[none]) && (available_amount(it) == 0))
	{
		return false;
	}
	if((goal == 1) && (it == $item[God Lobster\'s Crown]))
	{
		return false;
	}

	if (!in_quantumTerrarium())
	{
		handleFamiliar($familiar[God Lobster]);
		use_familiar($familiar[God Lobster]);
	}

	if((equipped_item($slot[familiar]) != it) && (it != $item[none]))
	{
		equip($slot[familiar], it);
	}

	set_property("_auto_lobsterChoice", to_string(goal));
	return autoAdvBypass("main.php?fightgodlobster=1", option);
}

boolean fantasyRealmAvailable()
{
	if(!is_unrestricted($item[FantasyRealm membership packet]))
	{
		return false;
	}
	if((get_property("frAlways").to_boolean() || get_property("_frToday").to_boolean()))
	{
		return true;
	}
	return false;
}

boolean fantasyRealmToken()
{
	if(!is_unrestricted($item[FantasyRealm membership packet]))
	{
		return false;
	}

	if((get_property("frAlways").to_boolean() || get_property("_frToday").to_boolean()) && !possessEquipment($item[FantasyRealm G. E. M.]))
	{
		int option = 1;
		switch(my_primestat())
		{
		case $stat[Muscle]:			option = 1;		break;
		case $stat[Mysticality]:	option = 2;		break;
		case $stat[Moxie]:			option = 3;		break;
		}
		if((option == 1) && possessEquipment($item[FantasyRealm Warrior\'s Helm]))
		{
			option = 2;
		}
		if((option == 2) && possessEquipment($item[FantasyRealm Mage\'s Hat]))
		{
			option = 3;
		}
		if((option == 3) && possessEquipment($item[FantasyRealm Rogue\'s Mask]))
		{
			option = 1;
		}
		visit_url("place.php?whichplace=realm_fantasy&action=fr_initcenter", false);
		visit_url("choice.php?whichchoice=1280&pwd=&option=" + option);
	}

	if(!possessEquipment($item[FantasyRealm G. E. M.]))
	{
		return false;
	}

	if(contains_text(get_property("_frMonstersKilled"), "fantasy bandit"))
	{
		foreach idx, it in split_string(get_property("_frMonstersKilled"), ",")
		{
			if(contains_text(it, "fantasy bandit"))
			{
				int count = to_int(split_string(it, ":")[1]);
				if(count >= 5)
				{
					return false;
				}
			}
		}
	}

	// If we're not allowed to adventure without a familiar due to being in a 100% familiar run.
	if(is100FamRun())
	{
		return false;
	}

	if(possessEquipment($item[FantasyRealm G. E. M.]))
	{
		autoEquip($slot[acc3], $item[FantasyRealm G. E. M.]);
	}

	//This does not appear to check that we no longer need to adventure there...

	return autoAdv(1, $location[The Bandit Crossroads]);
}

boolean songboomSetting(string goal)
{
	int option = 6;

	if((goal == "eye of the giger") || (goal == "spooky") || (goal == "nightmare") || (goal == $item[Nightmare Fuel]) || (goal == "stats"))
	{
		option = 1;
	}
	else if((goal == "food vibrations") || (goal == "food") || (goal == "food drops") || (goal == $item[Special Seasoning]) || (goal == "spell damage") || (goal == "adventures") || (goal == "adv"))
	{
		option = 2;
	}
	else if((goal == "remainin\' alive") || (goal == "dr") || (goal == "damage reduction") || (goal == $item[Shielding Potion]) || (goal == "delevel"))
	{
		option = 3;
	}
	else if((goal == "these fists were made for punchin\'") || (goal == "weapon damage") || (goal == "prismatic damage") || (goal == $item[Punching Potion]) || (goal == "prismatic"))
	{
		option = 4;
	}
	else if((goal == "total eclipse of your meat") || (goal == "meat") || (goal == "meat drop") || (goal == $item[Gathered Meat-Clip]) || (goal == "base meat"))
	{
		option = 5;
	}
	else if((goal == "silence") || (goal == "none") || (goal == ""))
	{
		option = 6;
	}

	return songboomSetting(option);
}

boolean songboomSetting(int option)
{
	if(!auto_is_valid($item[SongBoom&trade; BoomBox]))
	{
		return false;
	}
	if(item_amount($item[SongBoom&trade; BoomBox]) == 0)
	{
		return false;
	}
	if(get_property("_boomBoxSongsLeft").to_int() == 0)
	{
		if(option != 6)
		{
			# Always allow turning off the song, if that is really something we want to do.
			return false;
		}
	}
	if((option < 0) || (option > 6))
	{
		return false;
	}

	string currentSong = get_property("boomBoxSong");
	if((option == 1) && (currentSong == "Eye of the Giger"))
	{
		return false;
	}
	else if((option == 2) && (currentSong == "Food Vibrations"))
	{
		return false;
	}
	else if((option == 3) && (currentSong == "Remainin\' Alive"))
	{
		return false;
	}
	else if((option == 4) && (currentSong == "These Fists Were Made for Punchin\'"))
	{
		return false;
	}
	else if((option == 5) && (currentSong == "Total Eclipse of Your Meat"))
	{
		return false;
	}
	else if((option == 6) && (currentSong == ""))
	{
		return false;
	}

	int boomsLeft = 0;
	string page = visit_url("inv_use.php?pwd=&which=3&whichitem=9919");
	matcher boomMatcher = create_matcher("You grab your boombox and select the soundtrack for your life,  which you can do <b>(?:-?)(\\d+)", page);
	if(boomMatcher.find())
	{
		boomsLeft = to_int(boomMatcher.group(1));
	}
	else
	{
		auto_log_warning("Could not find how many songs we have left...", "red");
		option = 6;
	}

	page = visit_url("choice.php?whichchoice=1312&option=" + option);
	if(contains_text(page, "don\'t want to break this thing"))
	{
		auto_log_warning("Unable to change BoomBoxen songen!", "red");
		return false;
	}
	if(option != 6)
	{
		boomsLeft--;
	}
	auto_log_info("Change successful to " + get_property("boomBoxSong") + "We have " + boomsLeft + " SongBoom BoomBoxen songens left!", "green");
	return true;
}

void auto_setSongboom()
{
	if(!auto_is_valid($item[SongBoom&trade; BoomBox]))
	{
		return;
	}
	if(item_amount($item[SongBoom&trade; BoomBox]) == 0)
	{
		return;
	}
	if(get_property("auto_beatenUpCount").to_int() > 5)
	{
		songboomSetting("dr");
	}
	else if (internalQuestStatus("questL12War") > 0 && internalQuestStatus("questL12War") < 2)
	{
		// Once we've started the war, we want to be able to micromanage songs
		// for Gremlins and Nuns. Don't break this for them.
	}
	else if (!isActuallyEd() && !auto_havePillKeeper() && internalQuestStatus("questL07Cyrptic") < 1 && get_property("_boomBoxFights").to_int() == 10 && get_property("_boomBoxSongsLeft").to_int() > 3)
	{
		songboomSetting("nightmare");
	}
	else
	{
		if((my_fullness() == 0) || (item_amount($item[Special Seasoning]) < 4))
		{
			songboomSetting("food");
		}
		else
		{
			if(in_glover() && my_meat() > 10000)
			{
				songboomSetting("dr");
			}
			else
			{
				songboomSetting("meat");
			}
		}
	}
}

int catBurglarHeistsLeft()
{
	if (!have_familiar($familiar[Cat Burglar]) || !auto_is_valid($familiar[Cat Burglar]))
	{
		return 0;
	}
	int banked_heists = get_property("catBurglarBankHeists").to_int();
	int charge = get_property("_catBurglarCharge").to_int();
	int heists_complete = get_property("_catBurglarHeistsComplete").to_int();
	int heists_left = banked_heists - heists_complete;
	charge /= 10;
	while (charge >= 1) {
		heists_left++;
		charge /= 2;
	}
	return heists_left;
}

boolean catBurglarHeist(item it)
{
	/* Costly to call (requires two familiar swaps and a page load, even on failure)
	 * so I recommend calling this only after we fight a monster.
	 * Note that the Cat Burglar needs to be the active familiar in combat to heist that monster.
	 */
	if (0 == catBurglarHeistsLeft()) return false;

	auto_log_info("Trying to heist a " + it, "blue");
	familiar backup_familiar = my_familiar();
	try
	{
		use_familiar($familiar[Cat Burglar]);

		string page = visit_url("main.php?heist=1");
		matcher button = create_matcher("name=\"(st:\\d+:"+to_int(it)+")\"", page);
		if(button.find())
		{
			string choice_name = button.group(1);
			string url = "choice.php?whichchoice=1320&option=1&"+choice_name+"="+to_string(it)+"&pwd=" + my_hash();
			page = visit_url(url);
			handleTracker($familiar[Cat Burglar], it, "auto_otherstuff");
			return true;
		}
		auto_log_warning("We don't seem to be able to heist a " + it + ". Maybe we didn't fight it with the Cat Burglar?", "red");
		return false;
	}
	finally {
		use_familiar(backup_familiar);
	}
}

item[monster] catBurglarHeistDesires()
{
	/* Note that this is called from auto_pre_adv.ash - WE WILL OVERRIDE FAMILIAR IN
	 * PREADVENTURE IF WE NEED THE BURGLE.
	 */
	item[monster] wannaHeists;

	if (!canChangeToFamiliar($familiar[XO Skeleton]) && get_property("sidequestOrchardCompleted") == "none") {
		// Can't hugpocket? 1 turn filthworms is still a thing you can do!
		if (have_effect($effect[Filthworm Larva Stench]) == 0 && item_amount($item[Filthworm Hatchling Scent Gland]) == 0) {
			wannaHeists[$monster[larval filthworm]] = $item[Filthworm Hatchling Scent Gland];
		}
		if (have_effect($effect[Filthworm Drone Stench]) == 0 && item_amount($item[Filthworm Drone Scent Gland]) == 0) {
			wannaHeists[$monster[filthworm drone]] = $item[Filthworm Drone Scent Gland];
		}
		if (have_effect($effect[Filthworm Guard Stench]) == 0 && item_amount($item[Filthworm Royal Guard Scent Gland]) == 0) {
			wannaHeists[$monster[filthworm royal guard]] = $item[Filthworm Royal Guard Scent Gland];
		}
	}

	item oreGoal = to_item(get_property("trapperOre"));
	if (oreGoal != $item[none] && item_amount(oreGoal) < 3 && internalQuestStatus("questL08Trapper") < 2 && in_hardcore())
	{
		wannaHeists[$monster[mountain man]] = oreGoal;
	}

	if((item_amount($item[killing jar]) == 0) && ((get_property("gnasirProgress").to_int() & 4) == 0) && in_hardcore())
		wannaHeists[$monster[banshee librarian]] = $item[killing jar];

	if((my_level() >= 11) && !possessEquipment($item[Mega Gem]) && in_hardcore() && (item_amount($item[wet stew]) == 0) && (item_amount($item[wet stunt nut stew]) == 0))
	{
		if(item_amount($item[bird rib]) == 0)
			wannaHeists[$monster[whitesnake]] = $item[bird rib];
		if(item_amount($item[lion oil]) == 0)
			wannaHeists[$monster[white lion]] = $item[lion oil];
	}

	int twinPeakProgress = get_property("twinPeakProgress").to_int();
	boolean needStench = ((twinPeakProgress & 1) == 0);
	boolean needFood = ((twinPeakProgress & 2) == 0);
	boolean needJar = ((twinPeakProgress & 4) == 0);
	boolean needInit = (needStench || needFood || needJar || (twinPeakProgress == 7));
	int neededTrimmers = -item_amount($item[rusty hedge trimmers]);
	if(needStench) neededTrimmers++;
	if(needFood) neededTrimmers++;
	if(needJar) neededTrimmers++;
	if(needInit) neededTrimmers++;
	if ((my_level() >= 8) && (catBurglarHeistsLeft() >= 2) && (neededTrimmers > 0))
	{
		wannaHeists[$monster[bearpig topiary animal]] = $item[rusty hedge trimmers];
		wannaHeists[$monster[elephant (meatcar?) topiary animal]] = $item[rusty hedge trimmers];
		wannaHeists[$monster[spider (duck?) topiary animal]] = $item[rusty hedge trimmers];
	}

	if(get_property("questL11Shen") == "finished" && internalQuestStatus("questL11Ron") == 1 && catBurglarHeistsLeft() >= 2)
	{
		wannaHeists[$monster[Blue Oyster cultist]] = $item[cigarette lighter];
	}

	// 18 is a totally arbitrary cutoff here, but it's probably fine.
	if($location[The Penultimate Fantasy Airship].turns_spent >= 18)
	{
		if (!possessEquipment($item[amulet of extreme plot significance]) && internalQuestStatus("questL10Garbage") < 8)
		{
			wannaHeists[$monster[Quiet Healer]] = $item[amulet of extreme plot significance];
		}
		if (!possessEquipment($item[Mohawk wig]) && internalQuestStatus("questL10Garbage") < 10)
		{
			wannaHeists[$monster[Burly Sidekick]] = $item[Mohawk wig];
		}
	}

	return wannaHeists;
}

boolean catBurglarHeist()
{
	if (catBurglarHeistsLeft() == 0) return false;

	// We can't know what's burgleable without checking the burgle noncombat,
	// and that's expensive to do repeatedly. So we burgle only if we want
	// to burgle the last monster. This is bad if you're about to leave a zone.
	item[monster] wannaHeists = catBurglarHeistDesires();

	if (wannaHeists contains last_monster())
	{
		catBurglarHeist(wannaHeists[last_monster()]);
	}
	// don't return true from this, isn't adventuring.
	return false;
}

boolean cheeseWarMachine(int stats, int it, int eff, int potion)
{
	if(!auto_is_valid($item[Bastille Battalion Control Rig]))
	{
		return false;
	}
	if(item_amount($item[Bastille Battalion Control Rig]) == 0)
	{
		return false;
	}
	if(get_property("_bastilleGames").to_int() != 0)
	{
		return false;
	}

	if(stats == 0)
	{
		switch(my_primestat())
		{
		case $stat[Muscle]:			stats = 2;			break;
		case $stat[Mysticality]:	stats = 1;			break;
		case $stat[Moxie]:			stats = 3;			break;
		}
	}
	if(it == 0)
	{
		switch(my_primestat())
		{
		case $stat[Muscle]:			it = 1;			break;
		case $stat[Mysticality]:	it = 2;			break;
		case $stat[Moxie]:			it = 3;			break;
		}
	}

	if(eff == 0)
	{
		switch(my_primestat())
		{
		case $stat[Muscle]:			eff = 1;			break;
		case $stat[Mysticality]:	eff = 2;			break;
		case $stat[Moxie]:			eff = 3;			break;
		}
	}

	if(potion == 0)
	{
		potion = 1 + random(3);
	}

	if((stats < 1) || (stats > 3))
	{
		return false;
	}
	if((it < 1) || (it > 3))
	{
		return false;
	}
	if((eff < 1) || (eff > 3))
	{
		return false;
	}
	if((potion < 1) || (potion > 3))
	{
		return false;
	}
	string page = visit_url("inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=9928", false);

	matcher first = create_matcher("/bbatt/barb(\\d).png", page);
	if(first.find())
	{
		int setting = first.group(1).to_int();
		while(setting != stats)
		{
			string temp = visit_url("choice.php?whichchoice=1313&option=1&pwd=" + my_hash(), false);
			setting++;
			if(setting > 3)
			{
				setting = 1;
			}
		}
	}

	matcher second = create_matcher("/bbatt/bridge(\\d).png", page);
	if(second.find())
	{
		int setting = second.group(1).to_int();
		while(setting != it)
		{
			string temp = visit_url("choice.php?whichchoice=1313&option=2&pwd=" + my_hash(), false);
			setting++;
			if(setting > 3)
			{
				setting = 1;
			}
		}
	}

	matcher third = create_matcher("/bbatt/holes(\\d).png", page);
	if(third.find())
	{
		int setting = third.group(1).to_int();
		while(setting != eff)
		{
			string temp = visit_url("choice.php?whichchoice=1313&option=3&pwd=" + my_hash(), false);
			setting++;
			if(setting > 3)
			{
				setting = 1;
			}
		}
	}

	matcher fourth = create_matcher("/bbatt/moat(\\d).png", page);
	if(fourth.find())
	{
		int setting = fourth.group(1).to_int();
		while(setting != potion)
		{
			string temp = visit_url("choice.php?whichchoice=1313&option=4&pwd=" + my_hash(), false);
			setting++;
			if(setting > 3)
			{
				setting = 1;
			}
		}
	}

	string temp = visit_url("choice.php?whichchoice=1313&option=5&pwd=" + my_hash(), false);

	for(int i=0; i<5; i++)
	{
		visit_url("choice.php?whichchoice=1314&option=3&pwd=" + my_hash());
		visit_url("choice.php?whichchoice=1319&option=3&pwd=" + my_hash());
		visit_url("choice.php?whichchoice=1314&option=3&pwd=" + my_hash());
		visit_url("choice.php?whichchoice=1319&option=3&pwd=" + my_hash());
		visit_url("choice.php?whichchoice=1315&option=3&pwd=" + my_hash());
		if(last_choice() == 1316)
		{
			break;
		}
	}

	visit_url("choice.php?whichchoice=1316&option=3&pwd=" + my_hash());
	return true;
}

int neverendingPartyRemainingFreeFights()
{
	//Returns how many free fights do you have remaining in neverending party?
	
	if(!neverendingPartyAvailable())
	{
		return 0;
	}
	//if path randomizes names then the free fights are not free
	if(auto_my_path() == "Disguises Delimit" || auto_my_path() == "One Crazy Random Summer")
	{
		return 0;
	}
	//daily pass users do not get free fights
	if(get_property("_neverendingPartyToday").to_boolean())
	{
		return 0;
	}
	//mafia counts how many times you fought there for free, not how many free fights remain.
	return 10 - get_property("_neverendingPartyFreeTurns").to_int();
}

boolean neverendingPartyAvailable()
{
	if (!get_property("neverendingPartyAlways").to_boolean() && !get_property("_neverendingPartyToday").to_boolean())
	{
		// check mafia properties which track access.
		return false;
	}
	if (!auto_is_valid($item[Neverending Party invitation envelope]))
	{
		return false;
	}
	if (get_property("_questPartyFair") == "finished")
	{
		// Can't adventure if the quest is complete for the day.
		return false;
	}
	if (get_property("auto_skipNEPOverride").to_boolean())
	{
		// if the user says don't use it, don't use it.
		return false;
	}
	return true;
}

boolean neverendingPartyCombat()
{
	if(!neverendingPartyAvailable())
	{
		return false;
	}

	fightClubSpa();
	//May need to actually have 1 adventure left.

	if (hasTorso() && januaryToteTurnsLeft($item[Makeshift Garbage Shirt]) > 0)
	{
		januaryToteAcquire($item[Makeshift Garbage Shirt]);
		autoEquip($slot[shirt], $item[Makeshift Garbage Shirt]);
	}

	return autoAdv($location[The Neverending Party]);
}

void neverendingPartyChoiceHandler(int choice)
{
	if (choice == 1322) // The Beginning of the Neverend
	{
		run_choice(2); // No, I'm just here to party (decline quest)
	}
	else if (choice == 1323) // All Done!
	{
		run_choice(1); // Take your leave (get quest reward)
	}
	else if (choice == 1324) // It Hasn't Ended, It's Just Paused
	{
		effect buff = $effect[none];
		switch (my_primestat())
		{
			case $stat[Muscle]:
				buff = $effect[Spiced Up];
				break;
			case $stat[Mysticality]:
				buff = $effect[Tomes of Opportunity];
				break;
			case $stat[Moxie]:
				buff = $effect[The Best Hair You've Ever Had];
				break;
		}
		if (buff != $effect[none] && have_effect(buff) < 9)
		{
			// Get the +mainstat% buff if we don't have enough turns of it to get us to the next scheduled NC.
			switch (my_primestat())
			{
				case $stat[Muscle]:
					run_choice(2); // Check out the kitchen (go to Gone Kitchin')
					break;
				case $stat[Mysticality]:
					run_choice(1); // Head upstairs (go to A Room With a View... Of a Bed)
					break;
				case $stat[Moxie]:
					run_choice(4); // Investigate the basement (go to Basement Urges)
					break;
				default:
					run_choice(5); // Pick a fight (fight a random monster from the zone)
					break;
			}
		}
		else if (isAboutToPowerlevel() || isActuallyEd())
		{
			// If we're powerlevelling (or farming Ka) grab the +ML buff if we don't have enough turns
			// of it to get us to the next scheduled NC. Otherwise take the combat.
			if (have_effect($effect[Citronella Armpits]) < 9)
			{
				run_choice(3); // Go to the back yard (go to Forward to the Back)
			}
			else
			{
				run_choice(5); // Pick a fight (fight a random monster from the zone)
			}
		} else {
			run_choice(5); // Pick a fight (fight a random monster from the zone)
		}
	}
	else if (choice == 1325) // A Room With a View... Of a Bed
	{
		if (my_primestat() == $stat[Mysticality])
		{
			run_choice(2); // Read the tomes (Get Tomes of Opportunity buff. 20 advs of +20% to all Mysticality Gains)
		}
		else
		{
			run_choice(1); // Take a quick nap (Full HP & MP restore)
		}
	}
	else if (choice == 1326) // Gone Kitchin'
	{
		if (my_primestat() == $stat[Muscle])
		{
			run_choice(2); // Check out the muscle spice (Get Spiced Up buff. 20 advs of +20% to all Muscle Gains)
		}
		else
		{
			run_choice(1); // Peruse the cookbooks (get some myst substats)
		}
	}
	else if (choice == 1327) // Forward to the Back
	{
		run_choice(2); // Rub the candle wax under your arms (Get Citronella Armpits buff. 50 advs of +30 to Monster Level)
	}
	else if (choice == 1328) // Basement Urges
	{
		if (my_primestat() == $stat[Moxie])
		{
			run_choice(2); // Use the hair gel (Get The Best Hair You've Ever Had buff. 20 advs of +20% to all Moxie Gains)
		}
		else
		{
			run_choice(1); // Use the workout equipment (get some muscle substats)
		}
	}
	else
	{
		abort("unhandled choice in mushroomGardenChoiceHandler");
	}
}

string auto_latteDropName(location l)
{
	switch(l)
	{
		case $location[The Mouldering Mansion]: return "ancient";
		case $location[The Overgrown Lot]: return "basil";
		case $location[Whitey's Grove]: return "belgian";
		case $location[The Bugbear Pen]: return "bug-thistle";
		case $location[Madness Bakery]: return "butternut";
		case $location[The Black Forest]: return "cajun";
		case $location[The Haunted Billiards Room]: return "chalk";
		case $location[The Dire Warren]: return "carrot";
		case $location[Barrrney's Barrr]: return "carrrdamom";
		case $location[The Haunted Kitchen]: return "chili";
		case $location[The Sleazy Back Alley]: return "cloves";
		case $location[The Haunted Boiler Room]: return "coal";
		case $location[The Icy Peak]: return "cocoa";
		case $location[Battlefield (No Uniform)]: return "diet";
		case $location[Itznotyerzitz Mine]: return "dwarf";
		case $location[The Feeding Chamber]: return "filth";
		case $location[The Road to the White Citadel]: return "flour";
		case $location[The Fungal Nethers]: return "fungus";
		case $location[The Hidden Park]: return "grass";
		case $location[Cobb's Knob Barracks]: return "greasy";
		case $location[The Daily Dungeon]: return "healing";
		case $location[The Dark Neck of the Woods]: return "hellion";
		case $location[Wartime Frat House (Hippy Disguise)]: return "greek";
		case $location[The Old Rubee Mine]: return "grobold";
		case $location[The Bat Hole Entrance]: return "guarna";
		case $location[1st Floor, Shiawase-Mitsuhama Building]: return "gunpowder";
		case $location[Hobopolis Town Square]: return "hobo";
		case $location[The Haunted Library]: return "ink";
		case $location[Wartime Hippy Camp (Frat Disguise)]: return "kombucha";
		case $location[The Defiled Niche]: return "lihc";
		case $location[The Arid, Extra-Dry Desert]: return "lizard";
		case $location[Cobb's Knob Laboratory]: return "mega";
		case $location[The Unquiet Garves]: return "mold";
		case $location[The Briniest Deepests]: return "msg";
		case $location[The Haunted Pantry]: return "noodles";
		case $location[The Ice Hole]: return "norwhal";
		case $location[The Old Landfill]: return "oil";
		case $location[The Haunted Gallery]: return "paint";
		case $location[The Stately Pleasure Dome]: return "paradise";
		case $location[The Spooky Forest]: return "rawhide";
		case $location[The Brinier Deepers]: return "rock";
		case $location[The Briny Deeps]: return "salt";
		case $location[Noob Cave]: return "sandalwood";
		case $location[Cobb's Knob Kitchens]: return "sausage";
		case $location[The Hole in the Sky]: return "space";
		case $location[The Copperhead Club]: return "squash";
		case $location[The Caliginous Abyss]: return "squamous";
		case $location[The VERY Unquiet Garves]: return "teeth";
		case $location[The Middle Chamber]: return "venom";
		case $location[The Dark Elbow of the Woods]: return "vitamins";
		case $location[The Dark Heart of the Woods]: return "wing";
		default: return "";
	}
}

boolean auto_latteDropAvailable(location l)
{
	// obviously no latte drops are available if you don't HAVE a latte
	if(available_amount($item[latte lovers member's mug]) == 0)
		return false;
	string latteDrop = auto_latteDropName(l);
	if(latteDrop == "")
		return false;
	return !get_property("latteUnlocks").contains_text(latteDrop);
}

boolean auto_latteDropWanted(location l)
{
	return auto_latteDropAvailable(l) && !($locations[Noob Cave, The Haunted Boiler Room, The Arid\, Extra-Dry Desert] contains l);
}

string auto_latteTranslate(string ingredient)
{
	switch(ingredient.to_lower_case())
	{
		case "combat": return "wing";
		case "noncombat": case "noncom": return "ink";
		case "famxp": return "vitamins";
		case "exp":
			switch(my_primestat())
			{
				case $stat[Muscle]: return "vanilla";
				case $stat[Mysticality]: return "pumpkin";
				case $stat[Moxie]: return "cinnamon";
			}
			break;
		case "fam": case "weight": case "famweight": return "rawhide";
		case "prismatic": case "prism": case "pris": return "paint";
		case "meat": return "cajun";
		case "item": return "carrot";
	}
	return ingredient.to_lower_case();
}

boolean auto_latteRefill(string want1, string want2, string want3, boolean force)
{
	if(available_amount($item[latte lovers member's mug]) == 0)
		return false;

	if(get_property("_latteRefillsUsed").to_int() >= 3)
		return false;

	// don't want to waste banishes
	if(!get_property("_latteBanishUsed").to_boolean() && !force)
		return false;

	boolean [string] unlocked;
	string [int] unlocked_array = get_property("latteUnlocks").split_string(",");
	foreach i,s in unlocked_array
	{
		unlocked[s] = true;
	}

	want1 = auto_latteTranslate(want1);
	want2 = auto_latteTranslate(want2);
	want3 = auto_latteTranslate(want3);

	string [int] wants;
	if(want1 != "")
	{
		if(!unlocked[want1])
			return false;
		wants[wants.count()] = want1;
	}
	if(want2 != "")
	{
		if(!unlocked[want2])
			return false;
		wants[wants.count()] = want2;
	}
	if(want3 != "")
	{
		if(!unlocked[want3])
			return false;
		wants[wants.count()] = want3;
	}

	boolean haveWant(string want)
	{
		want = auto_latteTranslate(want);
		foreach i,s in wants
		{
			if(s == want)
				return true;
		}
		return false;
	}

	boolean tryAddWant(string want)
	{
		if(wants.count() >= 3 || haveWant(want))
			return false;
		want = auto_latteTranslate(want);
		if(!unlocked[want])
			return false;

		wants[wants.count()] = want;
		return true;
	}

	if(my_class() == $class[Vampyre])
		tryAddWant("healing");

	if(!haveWant("combat"))
		tryAddWant("noncombat");

	tryAddWant("item");
	tryAddWant("meat");

	if(my_familiar() != $familiar[none])
		tryAddWant("famweight");

	tryAddWant("exp");
	tryAddWant("grass");

	if(my_familiar() != $familiar[none])
		tryAddWant("famxp");

	// just to make sure we have at least 3 ingredients
	foreach want in $strings[pumpkin, cinnamon, vanilla]
		tryAddWant(want);

	if(wants.count() < 3)
		abort("Something went terribly wrong while trying to refill latte. Yikes!");

	cli_execute("latte refill " + wants[0] + " " + wants[1] + " " + wants[2]);
	return true;
}

boolean auto_latteRefill(string want1, string want2, string want3)
{
	return auto_latteRefill(want1, want2, want3, false);
}

boolean auto_latteRefill(string want1, string want2, boolean force)
{
	return auto_latteRefill(want1, want2, "", force);
}

boolean auto_latteRefill(string want1, string want2)
{
	return auto_latteRefill(want1, want2, false);
}

boolean auto_latteRefill(string want1, boolean force)
{
	return auto_latteRefill(want1, "", force);
}

boolean auto_latteRefill(string want1)
{
	return auto_latteRefill(want1, false);
}

boolean auto_latteRefill()
{
	return auto_latteRefill("");
}

boolean auto_haveVotingBooth() {
	// is_unrestricted instead of auto_is_valid as the enchatments are usable in g lover.
	return ((get_property("_voteToday").to_boolean() || get_property("voteAlways").to_boolean()) && is_unrestricted($item[voter registration form]));
}

boolean auto_voteSetup()
{
	return auto_voteSetup(0,0,0);
}

boolean auto_voteSetup(int candidate)
{
	return auto_voteSetup(candidate,0,0);
}

boolean auto_voteSetup(int candidate, int first, int second)
{
	if((candidate < 0) || (candidate > 2))
	{
		return false;
	}
	if((first < 0) || (first > 4))
	{
		return false;
	}
	if((second < 0) || (second > 4))
	{
		return false;
	}
	if(first == second && first != 0)
	{
		return false;
	}
	if(!auto_haveVotingBooth())
	{
		return false;
	}
	if(get_property("_voteModifier") != "")
	{
		return false;
	}
	if(possessEquipment($item[&quot;I voted!&quot; sticker]))
	{
		return false;
	}

	if(svn_info("Ezandora-Voting-Booth-trunk-Release").last_changed_rev > 0)
	{
		cli_execute("VotingBooth.ash");
		return true;
	}

	if(candidate == 0)
	{
		candidate = 1 + random(2);
	}
	while((first == 0) || (first == second))
	{
		first = 1 + random(4);
	}
	while((second == 0) || (first == second))
	{
		second = 1 + random(4);
	}

	//When using random, should we check for negative initiatives?

	string temp = visit_url("place.php?whichplace=town_right&action=townright_vote", false);
	temp = visit_url("choice.php?whichchoice=1331&pwd=&option=1&g=" + candidate + "&local[]=" + first + "&local[]=" + second);
	return true;
}

boolean auto_voteMonster()
{
	return auto_voteMonster(false);
}

boolean auto_voteMonster(boolean freeMon)
{
	return auto_voteMonster(freeMon, $location[none], "");
}

boolean auto_voteMonster(boolean freeMon, location loc)
{
	return auto_voteMonster(freeMon, loc, "");
}

boolean auto_voteMonster(boolean freeMon, location loc, string option)
{
	if(!auto_haveVotingBooth())
	{
		return false;
	}
	if(get_property("_voteModifier") == "")
	{
		return false;
	}

	//Some things override this, like a semi-rare?

	if(get_property("lastVoteMonsterTurn").to_int() >= total_turns_played())
	{
		return false;
	}
	if((total_turns_played() % 11) != 1)
	{
		return false;
	}
	// is_unrestricted instead of auto_is_valid as the monsters can be encountered in g-lover
	if(!possessEquipment($item[&quot;I voted!&quot; sticker]) || !is_unrestricted($item[&quot;I voted!&quot; sticker]))
	{
		return false;
	}

	if(freeMon && (get_property("_voteFreeFights").to_int() >= 3))
	{
		return false;
	}

	if(loc == $location[none])
	{
		return true;
	}

	if(!have_equipped($item[&quot;I voted!&quot; sticker]))
	{
		if(item_amount($item[&quot;I voted!&quot; sticker]) == 0)
		{
			return false;
		}
		autoEquip($slot[acc3], $item[&quot;I voted!&quot; sticker]);
	}
	return autoAdv(1, loc, option);
}

boolean fightClubNap()
{
	if(!is_unrestricted($item[Boxing Day care package]))
	{
		return false;
	}
	if(!get_property("daycareOpen").to_boolean())
	{
		return false;
	}
	if(get_property("_daycareNap").to_boolean())
	{
		return false;
	}

	string page = visit_url("place.php?whichplace=town_wrong&action=townwrong_boxingdaycare", false);
	page = visit_url("choice.php?pwd=&whichchoice=1334&option=1");

	if(!get_property("_daycareNap").to_boolean())
	{
		abort("fightClubtracking failed");
	}


	//Do I need to leave as well, I think I do...
	page = visit_url("choice.php?pwd=&whichchoice=1334&option=4");


	return true;
}

boolean fightClubSpa()
{
	int option = 4;
	stat st = my_primestat();
	if (in_zelda())
	{
		// We deal 250% of our Moxie, so if our Muscle is too high we... die.
		st = $stat[moxie];
	}
	switch(st)
	{
	case $stat[Muscle]:			option = 1;		break;
	case $stat[Mysticality]:	option = 3;		break;
	case $stat[Moxie]:			option = 2;		break;
	}
	return fightClubSpa(option);
}

boolean fightClubSpa(effect eff)
{
	int option = 0;

	switch(eff)
	{
	case $effect[Muddled]:					option = 1;		break;
	case $effect[Ten out of Ten]:			option = 2;		break;
	case $effect[Uncucumbered]:				option = 3;		break;
	case $effect[Flagrantly Fragrant]:		option = 4;		break;
	}

	if(option == 0)
	{
		return false;
	}
	return fightClubSpa(option);
}

boolean fightClubSpa(int option)
{
	if(!is_unrestricted($item[Boxing Day care package]))
	{
		return false;
	}
	if(!get_property("daycareOpen").to_boolean())
	{
		return false;
	}
	if(get_property("_daycareSpa").to_boolean())
	{
		return false;
	}
	if(option == 0)
	{
		option = 1 + random(4);
	}
	if((option < 1) || (option > 4))
	{
		return false;
	}

	string page = visit_url("place.php?whichplace=town_wrong&action=townwrong_boxingdaycare", false);
	page = visit_url("choice.php?pwd=&whichchoice=1334&option=2");
	page = visit_url("choice.php?pwd=&whichchoice=1335&option=" + option);

	if(!get_property("_daycareSpa").to_boolean())
	{
		abort("fightClubtracking failed");
	}

	//Do I need to leave as well, I think I do...
	page = visit_url("choice.php?pwd=&whichchoice=1334&option=4");


	return true;
}

boolean fightClubStats()
{
	if(!is_unrestricted($item[Boxing Day care package]))
	{
		return false;
	}
	if(!get_property("daycareOpen").to_boolean())
	{
		return false;
	}
	if(get_property("_daycareGymScavenges").to_int() > 0)
	{
		return false;
	}

	string page = visit_url("place.php?whichplace=town_wrong&action=townwrong_boxingdaycare", false);
	// Enter the Boxing Daycare
	page = visit_url("choice.php?pwd=&whichchoice=1334&option=3");
	// Scavenge for gym equipment
	page = visit_url("choice.php?pwd=&whichchoice=1336&option=2");

	if(get_property("_daycareGymScavenges").to_int() != 1)
	{
		// Seems like we can't trust KoLmafia to set this for us
		// abort("fightClubtracking failed");
		set_property("_daycareGymScavenges", 1);
	}

	//Do I need to leave as well, I think I do...
	page = visit_url("choice.php?pwd=&whichchoice=1334&option=4");

	return true;
}

boolean isTallGrassAvailable(){
	static item tallGrass = $item[Packet Of Tall Grass Seeds];
	return auto_is_valid(tallGrass) && auto_get_campground() contains tallGrass;
}

int pokeFertilizerAmountAvailable(){
	static item fertilizer = $item[Pok&eacute;-Gro fertilizer];
	if(!auto_is_valid(fertilizer)){
		return 0;
	}
	return item_amount(fertilizer);
}

boolean isPokeFertilizerAvailable(){
	return isTallGrassAvailable() && pokeFertilizerAmountAvailable() > 0;
}

boolean haveAnyPokeFamiliarEquipment(){
	static boolean[item] poke_fam_equipment = $items[amulet coin, luck incense, muscle band, razor fang, shell bell, smoke ball];
	foreach i, _ in poke_fam_equipment{
		if(equipmentAmount(i) > 0){
			auto_log_debug("Found Tall Grass familiar equipment: " + i);
			return true;
		}
	}
	return false;
}

boolean pokeFertilizeAndHarvest(){
	if(!isPokeFertilizerAvailable()){
		return false;
	}

	auto_log_debug("sew and reap.");
	return use(1, $item[Pok&eacute;-Gro fertilizer]) && cli_execute("garden pick");
}
