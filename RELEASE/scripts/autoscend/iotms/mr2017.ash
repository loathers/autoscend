#	This is meant for items that have a date of 2017.

// This should probably only be called directly from community_service.ash.
boolean auto_hasMummingTrunk()
{
	if(!pathHasFamiliar()  || item_amount($item[Mumming Trunk]) == 0 || !auto_is_valid($item[Mumming Trunk]))
	{
		return false;
	}
	return true;
}

boolean auto_checkFamiliarMummery(familiar fam)
{
	if (contains_text(get_property("_mummeryMods"), fam.to_string()))
	{
		return false;
	}
	return true;
}

boolean mummifyFamiliar(familiar fam, string bonus)
{
	if (!canChangeToFamiliar(fam) || !auto_hasMummingTrunk() || !auto_checkFamiliarMummery(fam))
	{
		return false;
	}

	bonus = to_lower_case(bonus);
	// I don't want to alter CS behaviour so I'm leaving a couple things in that are otherwise irrelevant.
	familiar last = my_familiar();
	int goal = 0;
	
	switch (bonus)
	{
		case "1":
		case "meat":
			goal = 1;
			break;
		case "2":
		case "mp":
		case "mp regen":
		case "mpregen":
			goal = 2;
			break;
		case "3":
		case "mus":
		case "muscle":
			goal = 3;
			break;
		case "4":
		case "item":
			goal = 4;
			break;
		case "5":
		case "mysticality":
		case "myst":
			goal = 5;
			break;
		case "6":
		case "hp":
		case "hp regen":
		case "hpregen":
			goal = 6;
			break;
		case "7":
		case "mox":
		case "moxie":
			goal = 7;
			break;
		default:
			return false;
	}
	
	if(contains_text(get_property("_mummeryUses"), goal) || goal < 1 || goal >= 8)
	{
		return false;
	}

	// CS will use this.
	if (canChangeFamiliar())
	{
		use_familiar(fam);
	}

	cli_execute("mummery " + goal);
	
	// CS will use this.
	if(my_familiar() != last && canChangeFamiliar())
	{
		use_familiar(last);
	}
	
	return true;
}

// Will provide the appropriate bonus to an arbitrary familiar.
boolean mummifyFamiliar(familiar fam)
{
	if (!auto_hasMummingTrunk() || !auto_checkFamiliarMummery(fam))
	{
		return false;
	}

	string targetBonus = "";

	switch (my_familiar())
	{
		case lookupFamiliarDatafile("meat"):
			targetBonus = "meat";
			break;
		case lookupFamiliarDatafile("item"):
			targetBonus = "item";
			break;
		case lookupFamiliarDatafile("gremlins"):
			targetBonus = "hp";
			break;
		case lookupFamiliarDatafile("regen"):
			targetBonus = "mp";
			break;
		case lookupFamiliarDatafile("stat"):
			targetBonus = my_primestat().to_string();
			break;
	}
	return mummifyFamiliar(fam, targetBonus);
}

boolean mummifyFamiliar()
{
	auto_hasMummingTrunk();
	if (in_community())
	{
		return false;
	}
	
	return mummifyFamiliar(my_familiar());
}

boolean pantogramPants()
{
	return pantogramPants(my_primestat(), $element[cold], 1, 2, 1);
}

boolean pantogramPants(stat st, element el, int hpmp, int meatItemStats, int misc)
{
	if(!auto_is_valid($item[Portable Pantogram]))
	{
		return false;
	}
	if(item_amount($item[Portable Pantogram]) == 0)
	{
		return false;
	}
	if(possessEquipment($item[Pantogram Pants]))
	{
		return false;
	}
	int m = 0;
	switch(st)
	{
	case $stat[Muscle]:				m=1;		break;
	case $stat[Mysticality]:		m=2;		break;
	case $stat[Moxie]:				m=3;		break;
	}

	int e = 0;
	switch(el)
	{
	case $element[hot]:				e=1;		break;
	case $element[cold]:			e=2;		break;
	case $element[spooky]:			e=3;		break;
	case $element[sleaze]:			e=4;		break;
	case $element[stench]:			e=5;		break;
	}

	if((hpmp < 1) || (hpmp > 9))
	{
		auto_log_warning("Invalid BottomLeft specifier for pANts. Failing pANts.", "red");
		return false;
	}
	if((meatItemStats < 1) || (meatItemStats > 12))
	{
		auto_log_warning("Invalid BottomRight specifier for pANts. Failing pANts.", "red");
		return false;
	}
	if((misc < 1) || (misc > 11))
	{
		auto_log_warning("Invalid BottomMiddle specifier for pANts. Failing pANts.", "red");
		return false;
	}

	int itemId;
	int itemQty;
	switch(hpmp)
	{
	case 1:		itemId = -1;	itemQty = 0;	break;
	case 2:		itemId = -2;	itemQty = 0;	break;
	case 3:		itemId = 464;	itemQty = 1;	break;
	case 4:		itemId = 830;	itemQty = 1;	break;
	case 5:		itemId = 2438;	itemQty = 1;	break;
	case 6:		itemId = 1658;	itemQty = 1;	break;
	case 7:		itemId = 5789;	itemQty = 1;	break;
	case 8:		itemId = 8455;	itemQty = 1;	break;
	case 9:		itemId = 705;	itemQty = 1;	break;
	}

	if(item_amount(to_item(itemId)) < itemQty)
	{
		auto_log_warning("Do not have enough: " + to_item(itemId) + " for pANts.", "red");
		return false;
	}
	string s1 = itemId + "," + itemQty;


	switch(meatItemStats)
	{
	case 1:		itemId = -1;	itemQty = 0;	break;
	case 2:		itemId = -2;	itemQty = 0;	break;
	case 3:		itemId = 173;	itemQty = 1;	break;
	case 4:		itemId = 706;	itemQty = 1;	break;
	case 5:		itemId = 80;	itemQty = 1;	break;
	case 6:		itemId = 7338;	itemQty = 1;	break;
	case 7:		itemId = 747;	itemQty = 3;	break;
	case 8:		itemId = 559;	itemQty = 3;	break;
	case 9:		itemId = 27;	itemQty = 3;	break;
	case 10:	itemId = 7327;	itemQty = 5;	break;
	case 11:	itemId = 7324;	itemQty = 5;	break;
	case 12:	itemId = 7330;	itemQty = 5;	break;
	}

	if(item_amount(to_item(itemId)) < itemQty)
	{
		auto_log_warning("Do not have enough: " + to_item(itemId) + " for pANts.", "red");
		return false;
	}
	string s2 = itemId + "," + itemQty;



	switch(misc)
	{
	case 1:		itemId = -1;	itemQty = 0;	break;
	case 2:		itemId = -2;	itemQty = 0;	break;
	case 3:		itemId = 70;	itemQty = 1;	break;
	case 4:		itemId = 704;	itemQty = 1;	break;
	case 5:		itemId = 865;	itemQty = 11;	break;
	case 6:		itemId = 6851;	itemQty = 1;	break;
	case 7:		itemId = 3495;	itemQty = 11;	break;
	case 8:		itemId = 9008;	itemQty = 1;	break;
	case 9:		itemId = 1907;	itemQty = 15;	break;
	case 10:	itemId = 14;	itemQty = 99;	break;
	case 11:	itemId = 24;	itemQty = 1;	break;
	}

	if(item_amount(to_item(itemId)) < itemQty)
	{
		auto_log_warning("Do not have enough: " + to_item(itemId) + " for pANts.", "red");
		return false;
	}
	string s3 = itemId + "," + itemQty;


	if((m < 1) || (m > 3))
	{
		auto_log_warning("Invalid stat specifier for pANts. Failing pANts.", "red");
		return false;
	}
	if((e < 1) || (e > 5))
	{
		auto_log_warning("Invalid elemental specifier for pANts. Failing pANts.", "red");
		return false;
	}

	string page = visit_url("inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=" + to_int($item[Portable Pantogram]));

#<tr><td style="color: white;" align=center bgcolor=blue><b>Results:</b></td></tr><tr><td style="padding: 5px; border: 1px solid blue;"><center><table><tr><td><span class='guts'>Something went awry.</span></td></tr>

	page = visit_url("choice.php?pwd=&whichchoice=1270&option=1&m=" + m + "&e=" + e + "&s1=" + s1 + "&s2=" + s2 + "&s3=" + s3);
	return true;

}

boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem)
{
	return loveTunnelAcquire(enforcer, statItem, engineer, loveEffect, equivocator, giftItem, "");
}

boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem, string option)
{
	if(get_property("_loveTunnelUsed").to_boolean())
	{
		return false;
	}
	if((loveEffect < 0) || (loveEffect > 4))
	{
		return false;
	}
	if((giftItem < 0) || (giftItem > 7))
	{
		return false;
	}
	if((giftItem == 6) && !have_familiar($familiar[Space Jellyfish]))
	{
		return false;
	}
	if((loveEffect == 2) && !pathHasFamiliar())
	{
		loveEffect = 3;
	}
	if(isActuallyEd() && ((my_mp() < 20) || (my_turncount() < 10)))
	{
		return false;
	}

	string temp = visit_url("place.php?whichplace=town_wrong");
	if(!(contains_text(temp, "townwrong_tunnel")))
	{
		return false;
	}

	backupSetting("choiceAdventure1222", "1"); // The Tunnel of L.O.V.E.

	if(enforcer)
	{
		backupSetting("choiceAdventure1223", "1"); // L.O.V. Entrance - Fight Enforcer
	}
	else
	{
		backupSetting("choiceAdventure1223", "2"); // L.O.V. Entrance - Skip Enforcer
	}

	int statValue = 4;
	if(statItem == $stat[none])
	{
		if(in_darkGyffte() && possessEquipment($item[Vampyric Cloake]))
		{
			statItem = $stat[Muscle];
		}
		else
		{
			statItem = my_primestat();
		}
	}
	switch(statItem)
	{
	case $stat[Muscle]:			statValue = 1;		break;
	case $stat[Mysticality]:	statValue = 2;		break;
	case $stat[Moxie]:			statValue = 3;		break;
	}

	if(!have_skill($skill[Torso Awareness]) && !have_skill($skill[Best Dressed]) && (statValue == 1))
	{
		if(!(possessEquipment($item[Protonic Accelerator Pack]) || possessEquipment($item[Vampyric Cloake])) && auto_is_valid($item[LOV Epaulettes]))
		{
			statValue = 2;
		}
		else
		{
			statValue = 3;
		}
	}

	if(!auto_is_valid($item[LOV Epaulettes]) && (statValue == 2))  // if myst and in G-Lover
	{
		statValue = 3; // Resistance and Meat seems better than ML
	}

	backupSetting("choiceAdventure1224", to_string(statValue)); // L.O.V. Equipment Room
	#1		Cardigan,			LOV Eardigan	Shirt - 25% Muscle Stats, 8-12HP Regen, +25ML, End of Day
	#2		Epaulettes,			LOV Epaulettes	Back  - 25% Myst Stats, 4-6MP Regen, -3MPCombatSkills, End of Day
	#3		Earrings			LOV Earrings	Acc   - 25% Moxie Stats, +3 PrismRes, +50% Meat, End of Day
	#4		Nothing

	if(engineer)
	{
		backupSetting("choiceAdventure1225", "1"); // L.O.V. Engine Room - Fight Engineer
	}
	else
	{
		backupSetting("choiceAdventure1225", "2"); // L.O.V. Engine Room - Skip Engineer
	}

	if(in_glover())
	{
		loveEffect = 3; // Item drops seems better than familiar weight
	}

	backupSetting("choiceAdventure1226", to_string(loveEffect)); // L.O.V. Emergency Room
	#1	Lovebotamy					+10 stats per fight
	#2	Open Heart Surgery			+10 familiar weight (50 adventures)
	#3	Wandering Eye Surgery		+50% item drops (50 adventures)
	#4	Nothing

	if(equivocator)
	{
		backupSetting("choiceAdventure1227", "1"); // L.O.V. Elbow Room - Fight Equivocator
	}
	else
	{
		backupSetting("choiceAdventure1227", "2"); // L.O.V. Elbow Room - Skip Equivocator
	}

	if(in_glover())
	{
		giftItem = 1; // Only item G-Lover can use
	}

	backupSetting("choiceAdventure1228", to_string(giftItem));
	#1		Boomerang			LOV Enamorang (combat item) stagger, consumed (15 turn later copy?)
	#2		Toy Dart Gun		LOV Emotionizer (usable self/others)
	#3		Chocolate			LOV Extraterrestrial Chocolate (+3/2/1 advs, independent chocolate?)
	#4		Flowers				LOV Echinacea Bouquet (Spleen). (stats + small hp/mp, 1 toxicity)
	#5		Plush Elephant		LOV Elephant (Shield, DR+10)
	#6		Toast? Only with Space Jellyfish?
	#7		Nothing

	boolean retval = autoAdv($location[The Tunnel of L.O.V.E.]);

	if(item_amount($item[LOV Extraterrestrial Chocolate]) > 0)
	{
		use(1, $item[LOV Extraterrestrial Chocolate]);
	}
	return retval;
}

boolean kgbWasteClicks()
{
	if(!possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(!auto_is_valid($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(get_property("_kgbClicksUsed").to_int() >= 22)
	{
		return false;
	}

	auto_log_info("kgbWasteClicks() will now use up remaining KGB clicks");
	int clicked = 0;
	while(kgbDiscovery() && (clicked < 10))
	{
		clicked++;
	}

	# Yes, this will not be pleasant if we matched our number and each page click changes the buttons.
	while((get_property("_kgbClicksUsed").to_int() < 22) && (clicked < 9))
	{
		int start = clicked;
		foreach ef in $effects[Items Are Forever, A View To Some Meat, Light!, The Spy Who Loved XP, Initiative And Let Die, The Living Hitpoints, License To Punch, Goldentongue, Thunderspell]
		{
			if(contains_text(get_property("auto_kgbTracker"), ":" + to_int(ef)))
			{
				kgbTryEffect(ef);
				clicked++;
				if($effects[Items Are Forever, A View To Some Meat] contains ef)
				{
					if(have_effect(ef) < 150)
					{
						break;
					}
				}
				if(ef == $effect[Light!])
				{
					break;
				}
			}
		}
		if(start == clicked)
		{
			auto_log_warning("kgbWasteClicks() was unable to spend your remaining KGB clicks on buffs for some reason. Please spend them manually");
			break;		//prevent infinite loop
		}
	}

	return (clicked > 0);
}

string kgbKnownEffects()
{
	if(get_property("auto_kgbTracker") == "")
	{
		set_property("auto_kgbTracker", my_ascensions() + ":0:0:0:0:0:0:0:0:0:0:0:0");
	}
	string[int] tracker = split_string(get_property("auto_kgbTracker"), ":");
	if((count(tracker) < 13) || (tracker[0] != my_ascensions()))
	{
		set_property("auto_kgbTracker", my_ascensions() + ":0:0:0:0:0:0:0:0:0:0:0:0");
	}
	tracker = split_string(get_property("auto_kgbTracker"), ":");

	string retval;

	for(int i=1; i<13; i++)
	{
		int tabNum = (i+1) / 2;
		int lowHigh = (i+1) % 2;
		effect ef = to_effect(tracker[i]);
		string efname = ef;
		if(ef == $effect[Light!])
		{
			efname = "Random";
		}

		retval += "Tab: " + tabNum + " Height: " + lowHigh + " with effect: " + efname + "<br>";

	}
	return retval;
}

boolean kgbTryEffect(effect ef)
{
	if(!possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(!is_unrestricted($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(get_property("_kgbClicksUsed").to_int() >= 22)
	{
		return false;
	}

	if(get_property("auto_kgbTracker") == "")
	{
		set_property("auto_kgbTracker", my_ascensions() + ":0:0:0:0:0:0:0:0:0:0:0:0");
	}
	string[int] tracker = split_string(get_property("auto_kgbTracker"), ":");
	if((count(tracker) < 13) || (tracker[0] != my_ascensions()))
	{
		set_property("auto_kgbTracker", my_ascensions() + ":0:0:0:0:0:0:0:0:0:0:0:0");
	}
	tracker = split_string(get_property("auto_kgbTracker"), ":");

	for(int i=1; i<13; i++)
	{
		if(to_effect(tracker[i]) == ef)
		{
			int button = (i+1) / 2;
			string page = visit_url("place.php?whichplace=kgb&action=kgb_tab" + button,  false);
			return true;
		}
	}
	return true;
}

boolean kgbDiscovery()
{
	if(!possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(!is_unrestricted($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(get_property("_kgbClicksUsed").to_int() >= 22)
	{
		return false;
	}

	if(get_property("auto_kgbTracker") == "")
	{
		set_property("auto_kgbTracker", my_ascensions() + ":0:0:0:0:0:0:0:0:0:0:0:0");
	}
	string[int] tracker = split_string(get_property("auto_kgbTracker"), ":");
	if((count(tracker) < 13) || (tracker[0] != my_ascensions()))
	{
		set_property("auto_kgbTracker", my_ascensions() + ":0:0:0:0:0:0:0:0:0:0:0:0");
	}
	tracker = split_string(get_property("auto_kgbTracker"), ":");

	string page = visit_url("place.php?whichplace=kgb", false);
	matcher tabCount = create_matcher("kgb_tab(\\d)(?:.*?)otherimages/kgb/tab(\\d+).gif", page);
	while(tabCount.find())
	{
		int id = to_int(tabCount.group(1));
		int height = to_int(tabCount.group(2));
		int index = ((id - 1) * 2) + height;
		if(tracker[index].to_int() == 0)
		{
			auto_log_info("We do not know " + id + " of height: " + height, "green");
			int[12] curEff;
			for(int i=2296; i<=2306; i++)
			{
				curEff[i-2296] = have_effect(to_effect(i));
			}
			string page = visit_url("place.php?whichplace=kgb&action=kgb_tab" + id,  false);
			for(int i=2296; i<=2306; i++)
			{
				if(have_effect(to_effect(i)) != curEff[i-2296])
				{
					if(have_effect(to_effect(i)) == (curEff[i-2296] + 100))
					{
						auto_log_info("It contains random!", "green");
						tracker[index] = 1;
					}
					else
					{
						auto_log_info("It contains " + to_effect(i) + "!", "green");
						tracker[index] = i;
					}
				}
			}
			string newTracker = my_ascensions();
			for(int i=1; i<13; i++)
			{
				newTracker += ":" + tracker[i];
			}
			set_property("auto_kgbTracker", newTracker);
			return true;
		}
	}
	return false;
}

int kgb_tabCount(string page)
{
	int count = 0;
	matcher tabCount = create_matcher("kgb_tab(\\d)(?:.*?)otherimages/kgb/tab(\\d+).gif", page);
	while(tabCount.find())
	{
		count++;
	}
	return count;
}

int kgb_tabHeight(string page)
{
	int height = 0;

	boolean printTabs = false;
	matcher ring_matcher = create_matcher("lightrings(\\d+)", page);
	if(ring_matcher.find())
	{
		int image = to_int(ring_matcher.group(1));
		auto_log_info("Found rings of value " + image, "blue");
		printTabs = true;
	}

	matcher tabCount = create_matcher("kgb_tab(\\d)(?:.*?)otherimages/kgb/tab(\\d+).gif", page);
	while(tabCount.find())
	{
		height += to_int(tabCount.group(2));
		if(printTabs)
		{
			int id = to_int(tabCount.group(1));
			int height = to_int(tabCount.group(2));
			auto_log_info("Tab " + id + " with height of " + height, "green");
		}
	}

	return height;
}

boolean kgbSetup()
{
	if(!possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(!auto_is_valid($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}

	if(get_property("_auto_kgbSetup").to_boolean())
	{
		return false;
	}

	if(my_daycount() != 1)
	{
		return false;
	}

	set_property("_auto_kgbSetup", true);

	string page = visit_url("place.php?whichplace=kgb");
	if(contains_text(page, "kgb_drawer") || contains_text(page, "kgb_crank") || contains_text(page, "kgb_button"))
	{
		return false;
	}

	if(!contains_text(page, "kgb_button"))
	{
		kgbDial(1, -1, 6);
		kgbDial(2, -1, 6);
		kgbDial(3, -1, 6);
		kgbDial(4, -1, 6);
		kgbDial(5, -1, 6);
		kgbDial(6, -1, 6);
		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 1, false);
		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 2, false);
		page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
		page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 2, false);
		//Crank extruded.
		if(!contains_text(page, "kgb_crank"))
		{
			abort("Failed to unlock kgb_crank");
		}
		page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
		for(int i=0; i<11; i++)
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_crank", false);
		}
		if(!contains_text(page, "..........."))
		{
			abort("11 cranks failed");
		}
		page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);

		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 1, false);
		page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 1, false);
		if(!contains_text(page, "kgb_dispenser"))
		{
			abort("Failed to unlock kgb_dispenser");
		}
		//Martini Hose extruded.

		page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
		kgbDial(1, -1, 3);
		kgbDial(2, -1, 3);
		kgbDial(3, -1, 3);
		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 1, false);
		if(!contains_text(page, "kgb_drawer2"))
		{
			abort("Failed to unlock kgb_drawer2");
		}
		page = visit_url("place.php?whichplace=kgb&action=kgb_drawer2", false);

		kgbDial(4, -1, 2);
		kgbDial(5, -1, 2);
		kgbDial(6, -1, 2);
		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 2, false);
		if(!contains_text(page, "kgb_drawer1"))
		{
			abort("Failed to unlock kgb_drawer1");
		}
		page = visit_url("place.php?whichplace=kgb&action=kgb_drawer1", false);


		kgbDial(1, -1, 7);
		kgbDial(2, -1, 9);
		kgbDial(3, -1, 8);
		kgbDial(4, -1, 8);
		kgbDial(5, -1, 9);
		kgbDial(6, -1, 7);
		page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + 1, false);
	}
	if(!contains_text(page, "kgb_button"))
	{
		abort("Failed to unlock kgb_button");
	}

	int button = -1;
	page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
	for(int i=1; i<=6; i++)
	{
		auto_log_info("Hitting tab modification button: " + i, "blue");
		page = visit_url("place.php?whichplace=kgb&action=kgb_button" + i, false);

		int count = kgb_tabCount(page);
		int height = kgb_tabHeight(page);

		if(count >= 3)
		{
			button = i;
			i--;
		}

		if(height >= 11)
		{
			break;
		}
	}
	set_property("auto_kgbAscension", my_ascensions());
	set_property("auto_kgbButton100", button);

	if(!kgb_getMartini(page))
	{
		auto_log_warning("Failed to get martini", "red");
	}

	return true;

}

boolean kgb_getMartini()
{
	return kgb_getMartini("", false);
}

boolean kgb_getMartini(string page)
{
	return kgb_getMartini(page, false);
}

boolean kgb_getMartini(string page, boolean dontCare)
{
	if(!possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(!auto_is_valid($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(get_property("_kgbDispenserUses").to_int() >= 3)
	{
		return false;
	}

	if(!get_property("_auto_kgbSetup").to_boolean())
	{
		kgbSetup();
	}

	if(get_property("auto_kgbAscension").to_int() != my_ascensions())
	{
		if(!dontCare)
		{
			auto_log_info("We did not initialize the briefcase this ascension, we can not care", "red");
			dontCare = true;
		}
	}

	if(page == "")
	{
		page = visit_url("place.php?whichplace=kgb");
	}

	if(!get_property("_kgbDailyStuff").to_boolean())
	{
		boolean flipped = false;
		if(contains_text(page, "handledown"))
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
			flipped = true;
		}
		for(int i=0; i<11; i++)
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_crank", false);
			if(contains_text(page, "Nothing seems to happen"))
			{
				break;
			}
		}
		if(!contains_text(page, "..........."))
		{
			auto_log_warning("Cranking did not work, uh oh!", "red");
		}
		else
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
			page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
			auto_log_info("Crank power!!", "green");
		}

		if(flipped)
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
		}

		if(!get_property("_kgbRightDrawerUsed").to_boolean())
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_drawer1", false);
		}
		if(!get_property("_kgbLeftDrawerUsed").to_boolean())
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_drawer2", false);
		}
		if(!get_property("_kgbOpened").to_boolean())
		{
			page = visit_url("place.php?whichplace=kgb&action=kgb_daily", false);
		}
		set_property("_kgbDailyStuff", true);
	}
	if(get_property("_kgbDispenserUses").to_int() >= 3)
	{
		return false;
	}

	int button = get_property("auto_kgbButton100").to_int();

	while((get_property("_kgbDispenserUses").to_int() < 3) && (get_property("_kgbClicksUsed").to_int() < 22))
	{
		int served = get_property("_kgbDispenserUses").to_int();
		int have = item_amount($item[Splendid Martini]);
		page = visit_url("place.php?whichplace=kgb&action=kgb_dispenser", false);
		if(contains_text(page, "Nothing happens."))
		{
			set_property("_kgbDispenserUses", 3);
			auto_log_warning("The martini dispenser is empty, weird.", "red");
			return true;
		}
		if((kgb_tabHeight(page) < 11) && !dontCare)
		{
			auto_log_info("Did we accidentally solve a puzzle? Gonna assume so...", "green");
			auto_log_info("Hitting tab modification button: " + button, "blue");
			int oldClicks = get_property("_kgbClicksUsed").to_int();
			page = visit_url("place.php?whichplace=kgb&action=kgb_button" + button, false);
			int newClicks = get_property("_kgbClicksUsed").to_int();
			if(newClicks == oldClicks)
			{
				auto_log_info("_kgbClicksUsed appears to not be tracking, please let the spies in.", "red");
				set_property("_kgbClicksUSed", newClicks + 1);
			}
			if(kgb_tabHeight(page) < 11)
			{
				if(button == 0)
				{
					abort("Can not seem to recover situation regarding splendid martinis");
				}
				auto_log_info("Trying to restore tabs", "green");
				continue;
			}
		}
		if((have == item_amount($item[Splendid Martini])) && !dontCare)
		{
			abort("Failed to get a splendid martini and we cared about it");
		}
		set_property("_kgbDispenserUses", served + 1);
	}
	return true;
}

boolean kgbDial(int dial, int curVal, int target)
{
	if(!possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(!auto_is_valid($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}

	if(curVal == target)
	{
		return true;
	}

	while(curVal != target)
	{
		string page = visit_url("place.php?whichplace=kgb&action=kgb_dial" + dial, false);
		int[int] dials;
		matcher dial_matcher = create_matcher("title=\"Weird Character (.)", page);
		int count = 1;
		while(dial_matcher.find())
		{
			string temp = dial_matcher.group(1);
			if(temp == "a")
			{
				dials[count] = 10;
			}
			else
			{
				dials[count] = to_int(dial_matcher.group(1));
			}
			count++;
		}
		curVal = dials[dial];
		auto_log_info("Clicking " + dial + " and now: " + curVal, "blue");
	}
	return true;
}


boolean solveKGBMastermind()
{
	if(!possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}
	if(!auto_is_valid($item[Kremlin\'s Greatest Briefcase]))
	{
		return false;
	}

	string page = visit_url("place.php?whichplace=kgb");
	if(contains_text(page, "A pair of antennae"))
	{
		return false;
	}
	if(contains_text(page, "kgb_daily"))
	{
		return false;
	}
	if(contains_text(get_property("_auto_kgbScoresLeft"), "3 0"))
	{
		if(contains_text(get_property("_auto_kgbScoresRight"), "3 0"))
		{
			return false;
		}
	}

	if(contains_text(page, "kgb_handledown"))
	{
		string temp = visit_url("place.php?whichplace=kgb&action=kgb_handledown");
	}
	if(!contains_text(page, "kgb_handleup"))
	{
		abort("KGB Handle borken!!");
	}

	string guessString = "";
	int clicks = 0;
	while(!contains_text(page, "A pair of antennae"))
	{
		int[int] dials;
		int count = 0;
		matcher dial_matcher = create_matcher("title=\"Weird Character (.)", page);
		while(dial_matcher.find())
		{
			string temp = dial_matcher.group(1);
			if(temp == "a")
			{
				dials[count] = 10;
			}
			else
			{
				dials[count] = to_int(dial_matcher.group(1));
			}
			count++;
		}

		auto_log_info("Left side: " + dials[0] + " " + dials[1] + " " + dials[2], "green");
		auto_log_info("Right side: " + dials[3] + " " + dials[4] + " " + dials[5], "green");

		int[int] guess;
		if(guessString == "")
		{
			guess[1] = 0;
			guess[2] = 1;
			guess[3] = 2;
		}
		else
		{
			string[int] digits = split_string(guessString, " ");
			guess[1] = to_int(digits[count(digits)-3]);
			guess[2] = to_int(digits[count(digits)-2]);
			guess[3] = to_int(digits[count(digits)-1]);
		}

		string prop = "_auto_kgbScoresLeft";
		int dialOffset = 0;
		string action = "1";

		if(contains_text(get_property("_auto_kgbScoresLeft"), "3 0"))
		{
			prop = "_auto_kgbScoresRight";
			dialOffset = 3;
			string action = "2";
		}

		//Which one are we doing, if ScoresLeft has 3 0, we are done with it.
		auto_log_info("About to guess: " + guess[1] + ", " + guess[2] + ", " + guess[3], "green");
		for(int i=1; i<=3; i++)
		{
			kgbDial(dialOffset+i, dials[dialOffset + i], guess[i]);
		}

		//Verify the dials are correct before pushing anything!
		int[int] vDials;
		int vCount = 0;
		matcher vDial_matcher = create_matcher("title=\"Weird Character (.)", page);
		while(vDial_matcher.find())
		{
			string temp = vDial_matcher.group(1);
			if(temp == "a")
			{
				vDials[vCount] = 10;
			}
			else
			{
				vDials[vCount] = to_int(vDial_matcher.group(1));
			}
			vCount++;
		}

		if((vDials[dialOffset+1] != guess[1]) || (vDials[dialOffset+2] != guess[2]) || (vDials[dialOffset+3] != guess[3]))
		{
			abort("Dials not set correctly");
		}

		string page = visit_url("place.php?whichplace=kgb&action=kgb_actuator" + action, false);
		if(contains_text(page, "Nothing happens"))
		{
			auto_log_warning("Out of clicks. Derp.", "red");
			return false;
		}
		int correct = 0;
		int blink = 0;
		matcher light_match = create_matcher("kgb_mastermind(\\d)(?:.*?)A light (.*?)\"", page);
		while(light_match.find())
		{
			int bulb = to_int(light_match.group(1));
			string status = light_match.group(2);
			auto_log_info("Light " + bulb + ": " + status, "blue");
			if(status == "(on)")
			{
				correct++;
			}
			if(status == "(blinking)")
			{
				blink++;
			}
		}
		auto_log_info("Correct: " + correct + " Blinking: " + blink, "blue");

		clicks++;

		if(get_property(prop) == "")
		{
			set_property(prop, correct + " " + blink);
		}
		else
		{
			set_property(prop, get_property(prop) + " " + correct + " " + blink);
		}

		guessString = visit_url("http://cheesellc.com/kol/kgb.php?data=" + url_encode(get_property(prop)), false);
		auto_log_info("Subresult: " + guessString, "green");

		if(contains_text(guessString, "3 0"))
		{
			guessString = "";
		}
	}
	auto_log_info("Clicks used: " + clicks, "red");

	return contains_text(page, "A pair of antennae");
}




boolean getSpaceJelly()
{
	if(!canChangeToFamiliar($familiar[Space Jellyfish]))
	{
		return false;
	}
	if(get_property("_seaJellyHarvested").to_boolean())
	{
		return false;
	}
	if(!have_familiar($familiar[Space Jellyfish]))
	{
		return false;
	}
	if(my_level() < 11)
	{
		return false;
	}
	if(my_path() != $path[Standard])
	{
		if(!inAftercore())
		{
			return false;
		}
	}

	if(internalQuestStatus("questS01OldGuy") < 0)
	{
		string temp = visit_url("oldman.php");
		temp = visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");
	}
	familiar old = my_familiar();
	use_familiar($familiar[Space Jellyfish]);
	string temp = visit_url("place.php?whichplace=thesea");
	temp = visit_url("place.php?whichplace=thesea&action=thesea_left2");
	temp = visit_url("choice.php?pwd=&whichchoice=1219&option=1");
	use_familiar(old);
	return true;
}

boolean haveAsdonBuff()
{
	foreach eff in $effects[Driving Intimidatingly, Driving Obnoxiously, Driving Observantly, Driving Quickly, Driving Recklessly, Driving Safely, Driving Stealthily, Driving Wastefully, Driving Waterproofly]
	{
		if(have_effect(eff) != 0)
		{
			return true;
		}
	}
	return false;
}

boolean asdonBuff(string goal)
{
	if((goal == $effect[Driving Obnoxiously]) || (goal == "combat") || (goal == "+combat"))
	{
		return asdonBuff($effect[Driving Obnoxiously]);
	}
	if((goal == $effect[Driving Stealthily]) || (goal == "noncombat") || (goal == "-combat") || (goal == "non-combat"))
	{
		return asdonBuff($effect[Driving Stealthily]);
	}
	if((goal == $effect[Driving Wastefully]) || (goal == "oil"))
	{
		return asdonBuff($effect[Driving Wastefully]);
	}
	if((goal == $effect[Driving Safely]) || (goal == "resistance") || (goal == "absorb") || (goal == "res"))
	{
		return asdonBuff($effect[Driving Safely]);
	}
	if((goal == $effect[Driving Recklessly]) || (goal == "ml"))
	{
		return asdonBuff($effect[Driving Recklessly]);
	}
	if((goal == $effect[Driving Intimidatingly]) || (goal == "-ml"))
	{
		return asdonBuff($effect[Driving Intimidatingly]);
	}
	if((goal == $effect[Driving Quickly]) || (goal == "init"))
	{
		return asdonBuff($effect[Driving Quickly]);
	}
	if((goal == $effect[Driving Observantly]) || (goal == "drops") || (goal == "meat") || (goal == "item") || (goal == "items") || (goal == "booze"))
	{
		return asdonBuff($effect[Driving Observantly]);
	}
	if((goal == $effect[Driving Waterproofly]) || (goal == "sea") || (goal == "breathe") || (goal == "dive") || (goal == "diver") || (goal == "underwater"))
	{
		return asdonBuff($effect[Driving Waterproofly]);
	}
	return false;
}

boolean canAsdonBuff(effect goal)
{
	if(!(auto_get_campground() contains $item[Asdon Martin Keyfob]))
	{
		return false;
	}
	if(!is_unrestricted($item[Asdon Martin Keyfob]))
	{
		return false;
	}
	if(!($effects[Driving Intimidatingly, Driving Obnoxiously, Driving Observantly, Driving Quickly, Driving Recklessly, Driving Safely, Driving Stealthily, Driving Wastefully, Driving Waterproofly] contains goal))
	{
		return false;
	}
	if(get_fuel() < 37)
	{
		return false;
	}
	if(($effect[Driving Wastefully] == goal) && (get_property("oilPeakProgress").to_float() == 0.0))
	{
		return false;
	}
	if(have_effect(goal) > 0)
	{
		return false;
	}
	return true;
}

boolean asdonBuff(effect goal)
{
	if(!canAsdonBuff(goal))
	{
		return false;
	}

	boolean needShrug = false;
	foreach eff in $effects[Driving Intimidatingly, Driving Obnoxiously, Driving Observantly, Driving Quickly, Driving Recklessly, Driving Safely, Driving Stealthily, Driving Wastefully, Driving Waterproofly]
	{
		if((have_effect(eff) > 0) && (eff != goal))
		{
			needShrug = true;
		}
	}

	if(needShrug)
	{
		string temp = visit_url("campground.php?pwd=&preaction=undrive");
	}

	int effectNum = -1;
	switch(goal)
	{
	case $effect[Driving Intimidatingly]:	effectNum = 6;	break;
	case $effect[Driving Obnoxiously]:		effectNum = 0;	break;
	case $effect[Driving Observantly]:		effectNum = 7;	break;
	case $effect[Driving Quickly]:			effectNum = 5;	break;
	case $effect[Driving Recklessly]:		effectNum = 4;	break;
	case $effect[Driving Safely]:			effectNum = 3;	break;
	case $effect[Driving Stealthily]:		effectNum = 1;	break;
	case $effect[Driving Wastefully]:		effectNum = 2;	break;
	case $effect[Driving Waterproofly]:		effectNum = 8;	break;
	}
	string temp = visit_url("campground.php?pwd=&preaction=drive&whichdrive=" + effectNum);

	return true;
}

boolean asdonAutoFeed()
{
	return asdonAutoFeed(-1);
}

boolean asdonAutoFeed(int goal)
{
	if(my_class() == $class[Ed the Undying])
	{
		return false;
	}
	if(!(auto_get_campground() contains $item[Asdon Martin Keyfob]))
	{
		return false;
	}
	if(!is_unrestricted($item[Asdon Martin Keyfob]))
	{
		return false;
	}
	if(get_fuel() > 137)
	{
		return false;
	}
	if(inAftercore())
	{
		return false;
	}

	if(goal == -1)
	{
		goal = 137;
		if(get_property("_missileLauncherUsed").to_boolean())
		{
			goal = 87;
		}
	}

	boolean didOnce = false;
	foreach it in $items[
		A Little Sump\'m Sump\'m,
		ancient frozen dinner,
		antique packet of ketchup,
		Backwoods Screwdriver,
		Bag Of GORP,
		Ballroom Blintz,
		Bean Burrito,
		Bilge Wine,
		Bottle Of Laundry Sherry,
		bowl of cottage cheese,
		Black Forest Ham,
		Cactus Fruit,
		CSA Scoutmaster\'s &quot;water&quot;,
		Enchanted Bean Burrito,
		Giant Heirloom Grape Tomato,
		Gin And Tonic,
		Haggis-Wrapped Haggis-Stuffed Haggis,
		ice-cold Willer,
		Insanely Spicy Bean Burrito,
		Insanely Spicy Enchanted Bean Burrito,
		Insanely Spicy Jumping Bean Burrito,
		Jumping Bean Burrito,
		Jungle Floor Wax,
		Loaf of Soda Bread,
		Margarita,
		McLeod\'s Hard Haggis-Ade,
		Mimosette,
		Mornington Crescent Roll,
		Open Sauce,
		Pink Pony,
		Roll In The Hay,
		Screwdriver,
		Slap And Tickle,
		Slip \'N\' Slide,
		Snifter Of Thoroughly Aged Brandy,
		Spicy Bean Burrito,
		Spicy Enchanted Bean Burrito,
		Spicy Jumping Bean Burrito,
		Stolen Sushi,
		Strawberry Daiquiri,
		Tequila Sunrise,
		Tequila Sunset,
		Typical Tavern swill,
		Vodka And Tonic,
		Water Purification Pills,
		Zmobie]
	{
		if(item_amount(it) > 0)
		{
			int toFeed = min(10, item_amount(it));
			if(get_property("auto_ashtonLimit") != "")
			{
				int limit = get_property("auto_ashtonLimit").to_int();
				toFeed = max(0, toFeed - limit);
			}
			asdonFeed(it, toFeed);
			didOnce = true;
		}
		if(get_fuel() > goal)
		{
			break;
		}
	}

	int meat_cutoff = max(3500, 2000 + meatReserve());
	boolean can_buy_dough = npc_price($item[wad of dough]) > 0;
	boolean can_buy_flower = npc_price($item[all-purpose flower]) > 0 && auto_is_valid($item[all-purpose flower]);
	
	//Dough prices: Madeline's Baking Supply is 40. other stores 50. flower ~50 meat per dough in batches of ~40.
	//only use flower if direct buying of dough is not available.
	if(get_fuel() < goal && my_meat() > meat_cutoff && isGeneralStoreAvailable() && !in_koe() && can_buy_flower && !can_buy_dough)
	{
		int want = (goal + 5 - get_fuel()) / 6;
		want = min(3 + ((my_meat() - meat_cutoff) / 1000), want);
		if(want > 0)
		{
			//flower drops 35 to 45 wads of dough per use. safeguard against inf loop. assume worst drop to let it run enough times.
			int loop_count = ceil(want/35);
			for i from 1 to loop_count
			{
				if(my_meat() > meat_cutoff && item_amount($item[wad of dough]) < want)
				{
					use(1, $item[all-purpose flower]);	//mafia will automatically buy it first
				}
			}
			want = min(want, item_amount($item[wad of dough]));
			create(want, $item[Loaf of Soda Bread]);
			asdonFeed($item[Loaf of Soda Bread], want);
			didOnce = true;
		}
	}

	if(get_fuel() < goal && my_meat() > meat_cutoff && can_buy_dough && isGeneralStoreAvailable() && !in_koe())
	{
		int can_buy = (my_meat() - meat_cutoff) / npc_price($item[wad of dough]);
		int want = (goal + 5 - get_fuel()) / 6;
		want = min(want, can_buy);
		if(want > 0)
		{
			create(want, $item[Loaf of Soda Bread]);
			asdonFeed($item[Loaf of Soda Bread], want);
			didOnce = true;
		}
	}

	if(didOnce)
	{
		cli_execute("refresh inv");
	}

	return get_fuel() >= goal;
}

boolean asdonFeed(item it, int qty)
{
	if(!(auto_get_campground() contains $item[Asdon Martin Keyfob]))
	{
		return false;
	}
	if(!is_unrestricted($item[Asdon Martin Keyfob]))
	{
		return false;
	}
	if((qty < 1) || (item_amount(it) < qty))
	{
		return false;
	}

	int oldFuel = get_fuel();
	string temp = visit_url("campground.php?pwd=&action=fuelconvertor&qty=" + qty + "&iid=" + to_int(it));
	int newFuel = get_fuel();

	auto_log_info("Compressed " + qty + " " + it + " into sheep, I mean fuel: " + oldFuel + " --> " + newFuel, "green");
	return true;
}

boolean asdonFeed(item it)
{
	return asdonFeed(it, 1);
}

boolean asdonCanMissile()
{
	return (auto_get_campground() contains $item[Asdon Martin Keyfob]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Missile Launcher])) && !get_property("_missileLauncherUsed").to_boolean();
}

boolean isHorseryAvailable() {
	return (get_property("horseryAvailable").to_boolean() && auto_is_valid($item[Horsery contract]));
}

int horseCost()
{
	if(get_property("_horseryRented").to_int() > 0)
	{
		return 500;
	}
	return 0;
}

string horseNormalize(string horseText)
{
	switch(horseText)
	{
		case "normal horse":
		case "normal":
		case "regen":
		case "init":
			return "normal";
		case "dark horse":
		case "dark":
		case "meat":
		case "-combat":
		case "noncombat":
		case "non-combat":
			return "dark";
		case "crazy horse":
		case "crazy":
		case "hookah":
		case "random":
			return "crazy";
		case "pale horse":
		case "pale":
		case "res":
		case "resistance":
		case "spooky":
		case "damage":
			return "pale";
		case "return":
		case "":
			return "return";
	}

	if (contains_text(horseText, "normal horse"))
	{
		return "normal";
	} else if (contains_text(horseText, "dark horse"))
	{
		return "dark";
	} else if (contains_text(horseText, "crazy horse"))
	{
		return "crazy";
	} else if (contains_text(horseText, "pale horse"))
	{
		return "pale";
	}

	auto_log_warning("Unknown Horsery horse type: '" + horseText + "'. Should be '', 'normal', 'dark', 'crazy', or 'pale'.", "red");
	return "";
}

boolean getHorse(string type)
{
	if(!get_property("horseryAvailable").to_boolean())
	{
		return false;
	}
	type = to_lower_case(type);
	if((my_meat() < horseCost()) && (type != "return"))
	{
		return false;
	}

	int choice = -1;
	if((horseNormalize(type) == "normal") || (get_property("auto_beatenUpCount").to_int() >= 20))
	{
		if(get_property("_horsery") == "normal horse")
		{
			return false;
		}
		choice = 1;
		set_property("auto_desiredHorse", "normal");

	}
	else if(horseNormalize(type) == "dark")
	{
		if(get_property("_horsery") == "dark horse")
		{
			return false;
		}
		choice = 2;
		set_property("auto_desiredHorse", "dark");
	}
	else if(horseNormalize(type) == "crazy")
	{
		if(contains_text(get_property("_horsery"), "crazy horse"))
		{
			return false;
		}
		choice = 3;
		set_property("auto_desiredHorse", "crazy");
	}
	else if(horseNormalize(type) == "pale")
	{
		if(contains_text(get_property("_horsery"), "pale horse"))
		{
			return false;
		}
		choice = 4;
		set_property("auto_desiredHorse", "pale");
	}
	else if(horseNormalize(type) == "return")
	{
		if(get_property("_horsery") == "")
		{
			return false;
		}
		choice = 5;
		set_property("_horsery", "");
		set_property("auto_desiredHorse", "return");
	}

	if(choice == -1)
	{
		return false;
	}
	string temp = visit_url("place.php?whichplace=town_right&action=town_horsery");
	temp = visit_url("choice.php?pwd=&whichchoice=1266&option=" + choice);
	if(choice <= 4)
	{
		set_property("_horseryRented", get_property("_horseryRented").to_int() + 1);
	}
	return true;
}

void horseDefault()
{
	if (isHorseryAvailable()) {
		set_property("auto_desiredHorse", "");
	}
}

void horseMaintain()
{
	if (isHorseryAvailable()) {
		set_property("auto_desiredHorse", horseNormalize(get_property("_horsery")));
	}
}

void horseNone()
{
	if (isHorseryAvailable()) {
		set_property("auto_desiredHorse", "return");
	}
}

void horseNormal()
{
	if (isHorseryAvailable()) {
		set_property("auto_desiredHorse", "normal");
	}
}

void horseDark()
{
	if (isHorseryAvailable()) {
		set_property("auto_desiredHorse", "dark");
	}
}

void horseCrazy()
{
	if (isHorseryAvailable()) {
		set_property("auto_desiredHorse", "crazy");
	}
}

void horsePale()
{
	if (isHorseryAvailable()) {
		set_property("auto_desiredHorse", "pale");
	}
}

boolean horsePreAdventure()
{
	if (!isHorseryAvailable()) { return false; }

	string desiredHorse = get_property("auto_desiredHorse");
	if (desiredHorse == "")
	{
		return false;
	}

	if (desiredHorse != "normal"
	    && desiredHorse != "dark"
	    && desiredHorse != "crazy"
	    && desiredHorse != "pale"
	    && desiredHorse != "return")
	{
		auto_log_warning("auto_desiredHorse was set to bad value: '" + desiredHorse + "'. Should be '', 'normal', 'dark', 'crazy', or 'pale'.", "red");
		set_property("auto_desiredHorse", "");
		return false;
	}
	return getHorse(desiredHorse);
}

boolean auto_haveGenieBottle()
{
	return (item_amount($item[Genie Bottle]) > 0 && auto_is_valid($item[Genie Bottle]));
}

boolean auto_shouldUseWishes()
{
	return get_property("auto_useWishes").to_boolean();
}

int auto_wishesAvailable()
{
	int retval = 0;
	if (auto_shouldUseWishes())
	{
		if(item_amount($item[Genie Bottle]) > 0 && auto_is_valid($item[Genie Bottle]))
		{
			retval += 3 - get_property("_genieWishesUsed").to_int();
		}
		if(auto_is_valid($item[pocket wish]))
		{
			retval += item_amount($item[pocket wish]);
		}
	}
	return retval;
}

boolean makeGenieWish(string wish)
{
	int starting_wishes = auto_wishesAvailable();
	if (starting_wishes < 1)
	{
		return false;
	}

	int wish_provider = 0;
	if(auto_is_valid($item[Genie Bottle]) && item_amount($item[Genie Bottle]) > 0 && get_property("_genieWishesUsed").to_int() < 3)
	{
		wish_provider = $item[genie bottle].to_int();
	}
	else if(item_amount($item[pocket wish]) > 0 && auto_is_valid($item[pocket wish]))
	{
		wish_provider = $item[pocket wish].to_int();
	}
	if(wish_provider == 0)
	{
		auto_log_warning("auto_wishesAvailable() thinks I have remaining wishes but makeGenieWish(string wish) was unable to find a valid source for them. wishing failed", "red");
		return false;
	}

	string page = visit_url("inv_use.php?pwd=" + my_hash() + "&which=3&whichitem="+wish_provider, false);
	page = visit_url("choice.php?pwd=&whichchoice=1267&option=1&wish=" + wish);

	if (auto_wishesAvailable() == starting_wishes)
	{
		auto_log_warning("Wish: '" + wish + "' failed", "red");
		return false;
	}

	handleTracker(to_item(wish_provider), wish, "auto_wishes");
	return true;
}

boolean makeGenieWish(effect eff)
{
	if(have_effect(eff) > 0)
	{
		return false;
	}
	if(my_adventures() == 0)
	{
		return false;
	}
	if(!glover_usable(eff))		//check if we are in glover and if the effect works in glover. as you can get nonfunctional effects
	{
		return false;
	}

	return makeGenieWish("to be " + eff) || have_effect(eff) > 0;
}

boolean canGenieCombat()
{
	boolean haveBottle = item_amount($item[Genie Bottle]) > 0;
	boolean bottleWishesLeft = get_property("_genieWishesUsed").to_int() < 3;
	boolean canUseBottle = haveBottle && bottleWishesLeft && auto_is_valid($item[Genie Bottle]);
	boolean havePocket = item_amount($item[pocket wish]) > 0;
	boolean canUsePocket = havePocket && auto_is_valid($item[pocket wish]);
	if(!canUseBottle && !canUsePocket)
	{
		return false;
	}
	if(get_property("_genieFightsUsed").to_int() >= 3)
	{
		return false;  // max 3 fights per day
	}
	if(my_adventures() == 0)
	{
		return false;  // cannot fight if no adv remaining
	}
	return true;
}

boolean makeGenieCombat(monster mon, string option)
{
	if(!canGenieCombat())
	{
		return false;
	}

	auto_log_info("Using genie to summon " + mon.name, "blue");
	string wish = "to fight a " + mon;
	string[int] pages;
	int wish_provider = $item[genie bottle].to_int();
	if (item_amount($item[pocket wish]) > 0)
	{
		wish_provider = $item[pocket wish].to_int();
	}
	pages[0] = "inv_use.php?pwd=" + my_hash() + "&which=3&whichitem="+wish_provider;		//false
	pages[1] = "choice.php?pwd=" + my_hash() + "&whichchoice=1267&option=1&wish=" + wish;
	pages[2] = "main.php";

	autoAdvBypass(5, pages, $location[Noob Cave], option);

	if(get_property("lastEncounter") != mon && get_property("lastEncounter") != "Using the Force")
	{
		auto_log_warning("Wish: '" + wish + "' failed", "red");
		return false;
	}
	handleTracker(mon, to_item(wish_provider), "auto_copies");
	handleTracker(to_item(wish_provider), wish, "auto_wishes");
	return true;
}

boolean makeGenieCombat(monster mon)
{
	return makeGenieCombat(mon, "");
}


boolean makeGeniePocket()
{
	if(item_amount($item[Genie Bottle]) == 0)
	{
		return false;
	}
	if(get_property("_genieWishesUsed").to_int() >= 3)
	{
		return false;
	}

	int count = item_amount($item[Pocket Wish]);

	string wish = "for more wishes";
	string page = visit_url("inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=9529", false);
	page = visit_url("choice.php?pwd=" + my_hash() + "&whichchoice=1267&option=1&wish=" + wish);

	if(count == item_amount($item[Pocket Wish]))
	{
		return false;
	}

	handleTracker($item[Genie Bottle], "for more wishes", "auto_wishes");
	return true;
}

boolean spacegateVaccineAvailable()
{
	if(in_koe()) return false;

	if(!get_property("spacegateAlways").to_boolean() || get_property("_spacegateToday").to_boolean())
	{
		return false;
	}
	if(!is_unrestricted($item[Spacegate access badge]))
	{
		return false;
	}
	if(get_property("_spacegateVaccine").to_boolean())
	{
		return false;
	}
	return true;
}

boolean spacegateVaccineAvailable(effect ef)
{
	if(!spacegateVaccineAvailable()) return false;
	switch (ef)
	{
	case $effect[Rainbow Vaccine]:
		return get_property("spacegateVaccine1").to_boolean();
	case $effect[Broad-Spectrum Vaccine]:
		return get_property("spacegateVaccine2").to_boolean();
	case $effect[Emotional Vaccine]:
		return get_property("spacegateVaccine3").to_boolean();
	}
	abort("autoscend: bad effect passed to spacegateVaccineAvailable:" + ef);
	return false;
}

boolean spacegateVaccine(effect ef)
{
	if(!spacegateVaccineAvailable(ef)) return false;
	if (have_effect(ef) > 0) return false;

	int i = 0;
	switch (ef)
	{
	case $effect[Rainbow Vaccine]:
		i = 1; break;
	case $effect[Broad-Spectrum Vaccine]:
		i = 2; break;
	case $effect[Emotional Vaccine]:
		i = 3; break;
	}
	cli_execute("spacegate vaccine " + i);
	return true;
}

boolean auto_hasMeteorLore()
{
	return have_skill($skill[Meteor Lore]) &&
		auto_is_valid($item[Pocket Meteor Guide]) &&
		auto_is_valid($skill[Meteor Lore]);
}

int auto_meteorShowersUsed(){
	return get_property("_meteorShowerUses").to_int();
}

int auto_meteorShowersAvailable(){
	if(!auto_hasMeteorLore()){
		return 0;
	}

	return 5 - auto_meteorShowersUsed();
}

int auto_macroMeteoritesUsed(){
	return get_property("_macrometeoriteUses").to_int();
}

int auto_macrometeoritesAvailable(){
	if(!auto_hasMeteorLore()){
		return 0;
	}

	return 10 - auto_macroMeteoritesUsed();
}

int auto_meteoriteAdesUsed(){
	return get_property("_meteoriteAdesUsed").to_int();
}
