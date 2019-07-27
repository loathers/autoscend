script "sl_mr2018.ash"

#	This is meant for items that have a date of 2018.

int januaryToteTurnsLeft(item it)
{
	if(item_amount($item[January\'s Garbage Tote]) == 0)
	{
		return 0;
	}
	if(!is_unrestricted($item[January\'s Garbage Tote]))
	{
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
	if(possessEquipment(it))
	{
		int score = 1;
		switch(it)
		{
		case $item[Deceased Crimbo Tree]:		score = get_property("garbageTreeCharge").to_int();			break;
		case $item[Broken Champagne Bottle]:	score = get_property("garbageChampagneCharge").to_int();	break;
		case $item[Makeshift Garbage Shirt]:	score = get_property("garbageShirtCharge").to_int();		break;
		}
		if(score == 0)
		{
			if(get_property("_garbageItemChanged").to_boolean())
			{
				score = 1;
			}
		}
		if(score > 0)
		{
			return false;
		}
	}
	if(item_amount($item[January\'s Garbage Tote]) == 0)
	{
		return false;
	}
	if(!is_unrestricted($item[January\'s Garbage Tote]))
	{
		return false;
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
		if((sl_my_path() == "Way of the Surprising Fist") || (my_class() == $class[Avatar Of Boris]))
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
		if(get_property("questM22Shirt") != "unstarted")
		{
			return false;
		}
		if(hasTorso())
		{
			return false;
		}
		if(item_amount($item[Letter For Melvign The Gnome]) > 0)
		{
			return false;
		}
		choice = 5;
	}

	string temp = visit_url("inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=9690", false);
	temp = visit_url("choice.php?pwd=&whichchoice=1275&option=" + choice);

	return true;
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
	if(!have_familiar($familiar[God Lobster]))
	{
		return false;
	}
	if(!is_unrestricted($familiar[God Lobster]))
	{
		return false;
	}
	if(is100FamiliarRun($familiar[God Lobster]))
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

	familiar last = my_familiar();
	item lastGear = equipped_item($slot[familiar]);

	handleFamiliar($familiar[God Lobster]);
	use_familiar($familiar[God Lobster]);

	if((equipped_item($slot[familiar]) != it) && (it != $item[none]))
	{
		equip($slot[familiar], it);
	}

	set_property("sl_disableAdventureHandling", true);

	string temp = visit_url("main.php?fightgodlobster=1");
	if(contains_text(temp, "You can't challenge your God Lobster anymore"))
	{
		set_property("_godLobsterFights", 3);
	}
	else
	{
		slAdv(1, $location[Noob Cave], option);
		temp = visit_url("main.php");

		string search = "I'd like part of your regalia.";
		if(goal == 2)
		{
			search = "I'd like a blessing.";
		}
		else if(goal == 3)
		{
			search = "I'd like some experience.";
		}

		int choice = 0;
		foreach idx, str in available_choice_options()
		{
			if(contains_text(str,search))
			{
				choice = idx;
			}
		}
		backupSetting("choiceAdventure1310", choice);
		temp = visit_url("choice.php?pwd=&whichchoice=1310&option=" + choice, true);
		restoreSetting("choiceAdventure1310");
	}

	set_property("sl_disableAdventureHandling", false);
	if(my_familiar() != last)
	{
		use_familiar(last);
	}
	if(equipped_item($slot[familiar]) != lastGear)
	{
		equip($slot[familiar], lastGear);
	}

	cli_execute("postsool");

	# r18906 seems to lose track of the astral pet sweater. Ugh.
	cli_execute("refresh all");
	if(equipped_item($slot[familiar]) != lastGear)
	{
		abort("Mafia lost track of our familiar equipment. Ugh...");
	}
	return true;
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

	// If we're not allowed to adventure without a familiar
	if(is100familiarRun() && sl_have_familiar($familiar[Mosquito]))
	{
		return false;
	}
	set_property("sl_familiarChoice", "none");
	use_familiar($familiar[none]);

	if(possessEquipment($item[FantasyRealm G. E. M.]))
	{
		slEquip($slot[acc3], $item[FantasyRealm G. E. M.]);
	}

	//This does not appear to check that we no longer need to adventure there...

	slAdv(1, $location[The Bandit Crossroads]);
	return true;
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
	if(!is_unrestricted($item[SongBoom&trade; BoomBox]))
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
		print("Could not find how many songs we have left...", "red");
		option = 6;
	}

	page = visit_url("choice.php?whichchoice=1312&option=" + option);
	if(contains_text(page, "don\'t want to break this thing"))
	{
		print("Unable to change BoomBoxen songen!", "red");
		return false;
	}
	if(option != 6)
	{
		boomsLeft--;
	}
	print("Change successful to " + get_property("boomBoxSong") + "We have " + boomsLeft + " SongBoom BoomBoxen songens left!", "green");
	return true;
}

int catBurglarHeistsLeft()
{
	if (!have_familiar($familiar[Cat Burglar]) || !sl_is_valid($familiar[Cat Burglar]))
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

	print("Trying to heist a " + it, "blue");
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
			return true;
		}
		print("We don't seem to be able to heist a " + it + ". Maybe we didn't fight it with the Cat Burglar?", "red");
		return false;
	}
	finally {
		use_familiar(backup_familiar);
	}
}

boolean cheeseWarMachine(int stats, int it, int eff, int potion)
{
	if(!is_unrestricted($item[Bastille Battalion Control Rig]))
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

boolean neverendingPartyPowerlevel()
{
	return neverendingPartyCombat(my_primestat(), false, "", true);
}

boolean neverendingPartyCombat()
{
	return neverendingPartyCombat(my_primestat());
}

boolean neverendingPartyCombat(stat st)
{
	return neverendingPartyCombat(st, false);
}

boolean neverendingPartyCombat(effect ef)
{
	return neverendingPartyCombat(ef, false);
}

boolean neverendingPartyCombat(stat st, boolean hardmode)
{
	return neverendingPartyCombat(st, hardmode, "", false);
}

boolean neverendingPartyCombat(effect ef, boolean hardmode)
{
	return neverendingPartyCombat(ef, hardmode, "", false);
}

boolean neverendingPartyCombat(stat st, boolean hardmode, string option, boolean powerlevelling)
{
	switch(st)
	{
	case $stat[Muscle]:			return neverendingPartyCombat($effect[Spiced Up], hardmode, option, powerlevelling);
	case $stat[Mysticality]:	return neverendingPartyCombat($effect[Tomes of Opportunity], hardmode, option, powerlevelling);
	case $stat[Moxie]:			return neverendingPartyCombat($effect[The Best Hair You\'ve Ever Had], hardmode, option, powerlevelling);
	}
	return neverendingPartyCombat($effect[none], hardmode, option, powerlevelling);
}

boolean neverendingPartyAvailable()
{
	if(!get_property("neverendingPartyAlways").to_boolean() && !get_property("_neverendingPartyToday").to_boolean())
	{
		return false;
	}
	if(get_property("_neverendingPartyFreeTurns").to_int() >= 10)
	{
		if(get_property("_neverendingNotEarly").to_boolean())
		{
			return false;
		}
		string page = visit_url("place.php?whichplace=town_wrong", false);
		if(!contains_text(page, "The Neverending Party (Early)"))
		{
			set_property("_neverendingNotEarly", true);
			return false;
		}
	}
	if(get_property("_neverendingPartyOver").to_boolean())
	{
		return false;
	}
	if(!is_unrestricted($item[Neverending Party invitation envelope]))
	{
		return false;
	}
	if(inebriety_left() < 0)
	{
		return false;
	}
	if(get_property("sl_skipNEPOverride").to_boolean())
	{
		print("NEP access disabled. This can be turned on in the Relay by setting sl_skipNEPOverride = false", "red");
		return false;
	}

	return true;

}


boolean neverendingPartyCombat(effect eff, boolean hardmode, string option, boolean powerlevelling)
{
	if(!get_property("neverendingPartyAlways").to_boolean() && !get_property("_neverendingPartyToday").to_boolean())
	{
		return false;
	}
	if((get_property("_neverendingPartyFreeTurns").to_int() >= 10) && !powerlevelling)
	{
		if(get_property("_neverendingNotEarly").to_boolean())
		{
			return false;
		}
		string page = visit_url("place.php?whichplace=town_wrong", false);
		if(!contains_text(page, "The Neverending Party (Early)"))
		{
			set_property("_neverendingNotEarly", true);
			return false;
		}
	}
	if(get_property("_neverendingPartyOver").to_boolean())
	{
		return false;
	}
	if(!is_unrestricted($item[Neverending Party invitation envelope]))
	{
		return false;
	}
	if(inebriety_left() < 0)
	{
		return false;
	}
	if(hardmode)
	{
		if(!possessEquipment($item[PARTY HARD T-shirt]) || !hasTorso())
		{
			return false;
		}
	}
	if(!hardmode && possessEquipment($item[PARTY HARD T-shirt]))
	{
		return false;
	}
	fightClubSpa();
	//May need to actually have 1 adventure left.

	backupSetting("choiceAdventure1322", 2);

	switch(eff)
	{
	case $effect[Spiced Up]:
		backupSetting("choiceAdventure1324", 2);
		backupSetting("choiceAdventure1326", 2);
		break;
	case $effect[Tomes of Opportunity]:
		backupSetting("choiceAdventure1324", 1);
		backupSetting("choiceAdventure1325", 2);
		break;
	case $effect[Citronella Armpits]:
		backupSetting("choiceAdventure1324", 3);
		backupSetting("choiceAdventure1327", 2);
		break;
	case $effect[The Best Hair You\'ve Ever Had]:
		backupSetting("choiceAdventure1324", 4);
		backupSetting("choiceAdventure1328", 2);
		break;
	case $effect[none]:
		backupSetting("choiceAdventure1324", 5);
		break;
	default:
		return false;
	}

	item shirt = equipped_item($slot[shirt]);
	if(hardmode)
	{
		slEquip($slot[shirt], $item[PARTY HARD T-shirt]);
	}
	else if (januaryToteTurnsLeft($item[Makeshift Garbage Shirt]) > 0)
	{
		januaryToteAcquire($item[Makeshift Garbage Shirt]);
		slEquip($slot[shirt], $item[Makeshift Garbage Shirt]);
	}

	boolean retval;

	if(get_property("choiceAdventure1324").to_int() == 5)
	{
		string[int] pages;
		pages[0] = "choice.php?pwd&whichchoice=1324&option=" + get_property("choiceAdventure1324");
		retval = slAdvBypass(0, pages, $location[The Neverending Party], option);
	}
	else
	{
		retval = slAdv(1, $location[The Neverending Party], option);
	}

	if(retval)
	{
		loopHandlerDelayAll();
	}

	restoreSetting("choiceAdventure1322");
	restoreSetting("choiceAdventure1324");
	restoreSetting("choiceAdventure1325");
	restoreSetting("choiceAdventure1326");
	restoreSetting("choiceAdventure1327");
	restoreSetting("choiceAdventure1328");

	if(shirt != $item[none] && !useMaximizeToEquip())
	{
		equip($slot[shirt], shirt);
	}

	if(get_property("lastEncounter") == "Party\'s Over")
	{
		set_property("_neverendingPartyOver", true);
		return false;
	}
	if(get_property("lastEncounter") == "All Done!")
	{
		set_property("_neverendingPartyOver", true);
		return false;
	}
	return retval;
}

string sl_latteDropName(location l)
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

boolean sl_latteDropAvailable(location l)
{
	// obviously no latte drops are available if you don't HAVE a latte
	if(available_amount($item[latte lovers member's mug]) == 0)
		return false;
	string latteDrop = sl_latteDropName(l);
	if(latteDrop == "")
		return false;
	return !get_property("latteUnlocks").contains_text(latteDrop);
}

boolean sl_latteDropWanted(location l)
{
	return sl_latteDropAvailable(l) && !($locations[Noob Cave, The Haunted Boiler Room, The Arid\, Extra-Dry Desert] contains l);
}

string sl_latteTranslate(string ingredient)
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

boolean sl_latteRefill(string want1, string want2, string want3, boolean force)
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

	want1 = sl_latteTranslate(want1);
	want2 = sl_latteTranslate(want2);
	want3 = sl_latteTranslate(want3);

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
		want = sl_latteTranslate(want);
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
		want = sl_latteTranslate(want);
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

boolean sl_latteRefill(string want1, string want2, string want3)
{
	return sl_latteRefill(want1, want2, want3, false);
}

boolean sl_latteRefill(string want1, string want2, boolean force)
{
	return sl_latteRefill(want1, want2, "", force);
}

boolean sl_latteRefill(string want1, string want2)
{
	return sl_latteRefill(want1, want2, false);
}

boolean sl_latteRefill(string want1, boolean force)
{
	return sl_latteRefill(want1, "", force);
}

boolean sl_latteRefill(string want1)
{
	return sl_latteRefill(want1, false);
}

boolean sl_latteRefill()
{
	return sl_latteRefill("");
}

boolean sl_voteSetup()
{
	return sl_voteSetup(0,0,0);
}

boolean sl_voteSetup(int candidate)
{
	return sl_voteSetup(candidate,0,0);
}

boolean sl_voteSetup(int candidate, int first, int second)
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
	if(!get_property("_voteToday").to_boolean() && !get_property("voteAlways").to_boolean())
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

boolean sl_voteMonster()
{
	return sl_voteMonster(false);
}

boolean sl_voteMonster(boolean freeMon)
{
	return sl_voteMonster(freeMon, $location[none], "");
}

boolean sl_voteMonster(boolean freeMon, location loc)
{
	return sl_voteMonster(freeMon, loc, "");
}

boolean sl_voteMonster(boolean freeMon, location loc, string option)
{
	if(!get_property("_voteToday").to_boolean() && !get_property("voteAlways").to_boolean())
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
	if(!possessEquipment($item[&quot;I voted!&quot; sticker]))
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
		slEquip($slot[acc3], $item[&quot;I voted!&quot; sticker]);
	}
	return slAdv(1, loc, option);
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
	switch(my_primestat())
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
