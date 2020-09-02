// This file should contain functions for adventuring which are not related to any of the council quests nor any "optional" quests.

boolean LX_bitchinMeatcar()
{
	if(isDesertAvailable())
	{
		return false;
	}
	if(item_amount($item[Bitchin\' Meatcar]) > 0)
	{
		return false;
	}
	
	//calculate meat costs of building your meatcar.
	//if player manually partially assembled it then it will work, just think it costs slightly more meat than it actually does
	int meatRequired = 0;
	if(knoll_available())
	{
		if(item_amount($item[Meat Stack]) == 0)
		{
			meatRequired += 100;
		}
		foreach it in $items[Spring, Sprocket, Cog, Empty Meat Tank, Tires, Sweet Rims]
		{
			if(item_amount(it) == 0)
			{
				meatRequired += npc_price(it);
			}
		}
	}
	if(!knoll_available())
	{
		//outside of knollsign you need to pay 70 meat for the meatpaste and buy [sweet rims]
		meatRequired = 70 + npc_price($item[Sweet Rims]);
	}
	
	if(creatable_amount($item[Bitchin\' Meatcar]) > 0)
	{
		return create(1, $item[Bitchin\' Meatcar]);
	}
	else if(my_meat() < meatRequired)
	{
		auto_log_info("I do not have enough meat to build a meatcar... doing something else", "red");
		return false;
	}
	
	if(item_amount($item[Gnollish Toolbox]) > 0)
	{
		use(1, $item[Gnollish Toolbox]);
		return true;
	}
	
	//if you reached this point then it means you need to spend adventures to acquire more parts
	auto_log_info("Farming for a Bitchin' Meatcar", "blue");
	
	//start untinker quest if possible to gain access to hostile dgrassi knoll
	if(get_property("questM01Untinker") == "unstarted")
	{
		visit_url("place.php?whichplace=forestvillage&preaction=screwquest&action=fv_untinker_quest");
	}
	
	//attempt to adventure in degrassi knoll garage, if failed attempt to unlock it via guild
	if(autoAdv(1, $location[The Degrassi Knoll Garage]))
	{
		return true;
	}
	else if(guild_store_available())
	{
		visit_url("guild.php?place=paco");
		return true;
	}
	
	//could not adventure in degrassi knoll garage and could not unlock it. you are probably too early in the run and need to come back to it later.
	return false;
}

boolean LX_unlockDesert()
{
	if(isDesertAvailable())
	{
		return false;
	}
	
	if(auto_my_path() == "Nuclear Autumn")
	{
		if(isAboutToPowerlevel())
		{
			auto_log_info("We ran out of things to do. Trying to prematurely unlock Desert", "blue");
		}
		else
		{
			auto_log_info("In Nuclear Autumn you get a free desert pass at level 11. skipping unlocking it for now", "blue");
			return false;
		}
	}
	
	//knollsign lets you buy the meatcar for less meat than a desert pass without spending any adv.
	if(inKnollSign())
	{
		return LX_bitchinMeatcar();
	}
	
	//if wealthy enough just buy the desert pass outright instead of spending adventures.
	if(my_meat() >= (npc_price($item[Desert Bus Pass]) + 1000) && isGeneralStoreAvailable())
	{
		auto_log_info("We're rich, let's take the bus instead of building a car.", "blue");
		buyUpTo(1, $item[Desert Bus Pass]);
		if(item_amount($item[Desert Bus Pass]) > 0)
		{
			return true;
		}
	}
	
	//plumbers should wait until they are rich enough to buy the desert pass. As they have few uses for meat.
	if(in_zelda() && !isAboutToPowerlevel())
	{
		auto_log_info("Plumbers have few uses for meat. Delaying desert unlock until we can buy a pass.", "blue");
		return false;
	}
	
	//spend adv to unlock the desert
	return LX_bitchinMeatcar();
}

boolean LX_desertAlternate()
{
	if(auto_my_path() == "Nuclear Autumn")
	{
		return LX_hippyBoatman();
	}
	if(get_property("lastDesertUnlock").to_int() == my_ascensions())
	{
		return false;
	}
	if(knoll_available())
	{
		return false;
	}
	if((my_meat() >= npc_price($item[Desert Bus Pass])) && isGeneralStoreAvailable())
	{
		buyUpTo(1, $item[Desert Bus Pass]);
		if(item_amount($item[Desert Bus Pass]) > 0)
		{
			return true;
		}
	}
	return false;
}

boolean LX_islandAccess()
{
	if(in_koe())
	{
		return false;
	}

	if (in_lowkeysummer()) {
		return LX_hippyBoatman();
	}

	boolean canDesert = (get_property("lastDesertUnlock").to_int() == my_ascensions());

	if((item_amount($item[Shore Inc. Ship Trip Scrip]) >= 3) && (item_amount($item[Dingy Dinghy]) == 0) && (my_meat() >= npc_price($item[dingy planks])) && isGeneralStoreAvailable())
	{
		cli_execute("make dinghy plans");
		buyUpTo(1, $item[dingy planks]);
		use(1, $item[dinghy plans]);
		return true;
	}

	if((item_amount($item[Dingy Dinghy]) > 0) || (get_property("lastIslandUnlock").to_int() == my_ascensions()))
	{
		if(get_property("lastIslandUnlock").to_int() == my_ascensions())
		{
			boolean reallyUnlocked = false;
			foreach it in $items[Dingy Dinghy, Skeletal Skiff, Yellow Submarine]
			{
				if(item_amount(it) > 0)
				{
					reallyUnlocked = true;
				}
			}
			if(get_property("peteMotorbikeGasTank") == "Extra-Buoyant Tank")
			{
				reallyUnlocked = true;
			}
			if(internalQuestStatus("questM19Hippy") >= 3)
			{
				reallyUnlocked = true;
			}
			if(!reallyUnlocked)
			{
				auto_log_warning("lastIslandUnlock is incorrect, you have no way to get to the Island. Unless you barrel smashed when that was allowed. Did you barrel smash? Well, correcting....", "red");
				set_property("lastIslandUnlock", my_ascensions() - 1);
				return true;
			}
		}
		return false;
	}

	if(!isDesertAvailable() || !isGeneralStoreAvailable())
	{
		return LX_desertAlternate();
	}

	if((my_adventures() <= 9) || (my_meat() <= 1900))
	{
		return false;
	}
	if(get_counters("Fortune Cookie", 0, 9) == "Fortune Cookie")
	{
		//Just check the Fortune Cookie counter not any others.
		return false;
	}

	auto_log_info("At the shore, la de da!", "blue");
	if(item_amount($item[Dinghy Plans]) > 0)
	{
		abort("Dude, we got Dinghy Plans... we should not be here....");
	}
	while(item_amount($item[Shore Inc. Ship Trip Scrip]) < 3 &&  item_amount($item[Dinghy Plans]) == 0)
	{
		if(!LX_doVacation()) break;		//tries to vacation and if fails it will break the loop
	}
	if(item_amount($item[Shore Inc. Ship Trip Scrip]) < 3)
	{
		auto_log_warning("Failed to get enough Shore Scrip for some raisin, continuing...", "red");
		return false;
	}

	if((my_meat() >= npc_price($item[dingy planks])) && (item_amount($item[Dinghy Plans]) == 0) && isGeneralStoreAvailable())
	{
		cli_execute("make dinghy plans");
		buyUpTo(1, $item[dingy planks]);
		use(1, $item[dinghy plans]);
		return true;
	}
	return false;
}

boolean startHippyBoatmanSubQuest()
{
	if(my_basestat(my_primestat()) >= 25 && get_property("questM19Hippy") == "unstarted")
	{
		string temp = visit_url("place.php?whichplace=woods&action=woods_smokesignals");
		temp = visit_url("choice.php?pwd=&whichchoice=798&option=1");
		temp = visit_url("choice.php?pwd=&whichchoice=798&option=2");
		temp = visit_url("woods.php");
		return true;
	}
	return false;
}

boolean LX_hippyBoatman() {
	if (get_property("lastIslandUnlock").to_int() >= my_ascensions()) {
		return false;
	}

	if (item_amount($item[junk junk]) > 0 ) {
		return false;
	}

	if (internalQuestStatus("questM19Hippy") > 3) {
		return false;
	}

	if (my_basestat(my_primestat()) < 25) {
		return false;
	}

	if (internalQuestStatus("questM19Hippy") < 0) {
		startHippyBoatmanSubQuest();

		if (internalQuestStatus("questM19Hippy") < 0) {
			abort("Failed to unlock The Old Landfill. Not sure what to do now...");
		}
		return true;
	}

	if (item_amount($item[Old Claw-Foot Bathtub]) > 0 && item_amount($item[Old Clothesline Pole]) > 0 && item_amount($item[Antique Cigar Sign]) > 0 && item_amount($item[Worse Homes and Gardens]) > 0) {
		create(1, $item[junk junk]);
		visit_url("place.php?whichplace=woods&action=woods_hippy");
		if (internalQuestStatus("questM19Hippy") > 3) {
			return true;
		}
		abort("Failed to create the junk junk or finish the quest for some reason!");
	}

	return autoAdv($location[The Old Landfill]);
}

void oldLandfillChoiceHandler(int choice) {
	if (choice == 794) { // Once More Unto the Junk
		if (item_amount($item[junk junk]) == 0) {
			if (item_amount($item[Old Claw-Foot Bathtub]) == 0) {
				run_choice(1); // go to The Bathroom of Ten Men (#795)
			} else if(item_amount($item[Old Clothesline Pole]) == 0) {
				run_choice(2); // go to The Den of Iquity (#796)
			} else if(item_amount($item[Antique Cigar Sign]) == 0) {
				run_choice(3); // go to Let's Workshop This a Little (#797)
			} else {
				run_choice(1); // go to The Bathroom of Ten Men (#795)
			}
		} else {
			// TODO: Add handling to get the eternal car battery
			// doesn't look like there's mafia tracking for it yet.
			if (item_amount($item[tangle of copper wire]) == 0) {
				run_choice(2); // go to The Den of Iquity (#796)
			} else if (item_amount($item[Junk-Bond]) == 0) {
				run_choice(3); // go to Let's Workshop This a Little (#797)
			} else {
				run_choice(1); // go to The Bathroom of Ten Men (#795)
			}
		}
	} else if (choice == 795) { // The Bathroom of Ten Men
		if (item_amount($item[Old Claw-Foot Bathtub]) == 0) {
			run_choice(1); // get old claw-foot bathtub
		} else {
			run_choice(2); // fight a random enemy from the zone
		}
	} else if (choice == 796) { // The Den of Iquity
		if(item_amount($item[Old Clothesline Pole]) == 0) {
			run_choice(2); // get old clothesline pole
		} else {
			run_choice(3); // get tangle of copper wire
		}
	} else if (choice == 797) { // Let's Workshop This a Little
		if(item_amount($item[Antique Cigar Sign]) == 0) {
			run_choice(3); // get antique cigar sign
		} else {
			run_choice(1); // get Junk-Bond
		}
	} else {
		abort("unhandled choice in oldLandfillChoiceHandler");
	}
}

boolean LX_lockPicking()
{
	if(!auto_have_skill($skill[Lock Picking]))
	{
		return false;
	}

	if(get_property("lockPicked").to_boolean())
	{
		return false;
	}

	if(towerKeyCount(false) >= 3)
	{
		return false;
	}

	if(my_mp() < mp_cost($skill[Lock Picking]))
	{
		return false;
	}

	// As of r20114, this choice does not work in choice adventure script
	if(item_amount($item[Boris\'s Key]) == 0)
	{
		set_property("choiceAdventure1414", 1);
	}
	else if(item_amount($item[Jarlsberg\'s Key]) == 0)
	{
		set_property("choiceAdventure1414", 2);
	}
	else if(item_amount($item[Sneaky Pete\'s Key]) == 0)
	{
		set_property("choiceAdventure1414", 3);
	}

	use_skill(1, $skill[Lock Picking]);
	run_turn();
	return get_property("lockPicked").to_boolean();
}

float estimateDailyDungeonAdvNeeded()
{
	//estimates the amount of adventures we expect to need to do the daily dungeon. the result is only an estimate and not exact.
	//uses your current tools rather than potential tools. so it does not account for the possibility of pulling something or getting a cubeling drop.
	
	float progress = get_property("_lastDailyDungeonRoom").to_float();
	float adv_needed = 15 - progress;
	if(progress < 5)
	{
		adv_needed = adv_needed - 2;
		if(possessEquipment($item[Ring of Detect Boring Doors]))
		{
			adv_needed = adv_needed - 4;
		}
	}
	else if(progress < 10)
	{
		adv_needed = adv_needed - 1;
		if(possessEquipment($item[Ring of Detect Boring Doors]))
		{
			adv_needed = adv_needed - 2;
		}
	}
	
	int random_NC_tool_count = 0;
	if(item_amount($item[Eleven-Foot Pole]) > 0)
	{
		random_NC_tool_count++;
	}
	if(item_amount($item[Platinum Yendorian Express Card]) > 0 ||
	item_amount($item[Pick-O-Matic Lockpicks]) > 0 ||
	(creatable_amount($item[Skeleton Key]) + item_amount($item[Skeleton Key]) > 2))
	{
		random_NC_tool_count++;
	}
	
	if(random_NC_tool_count > 0)
	{
		adv_needed = adv_needed / (1 + random_NC_tool_count);
	}
	
	return adv_needed;
}

boolean LX_fatLootToken()
{
	if(towerKeyCount(false) >= 3 && !get_property("auto_forceFatLootToken").to_boolean())
	{
		return false;	//have enough tokens
	}
	
	if(!canChangeToFamiliar($familiar[Gelatinous Cubeling]) && in_hardcore())
	{
		//if unable to get the daily dungeon tools then prefer to do fantasy realm over daily dungeon
		if(fantasyRealmToken()) return true;
	}
	if(LX_dailyDungeonToken()) return true;
	if(get_property("dailyDungeonDone").to_boolean() && my_daycount() > 1)
	{
		//wait until daily dungeon is done before considering doing fantasy realm
		if(fantasyRealmToken()) return true;
	}
	
	return false;
}

boolean LX_dailyDungeonToken()
{
	if(get_property("dailyDungeonDone").to_boolean())
	{
		return false;	// already done today
	}
	if(wantCubeling())
	{
		return false;	//can switch to cubeling so wait until we have all the tool drops before doing daily dungeon
	}
	
	if(can_interact())		//if you can not use cubeling then mallbuy missing tools in casual and postronin
	{
		buyUpTo(1, $item[Eleven-Foot Pole]);
		buyUpTo(1, $item[Pick-O-Matic Lockpicks]);
		if(!possessEquipment($item[Ring of Detect Boring Doors]))	//do not buy a second one if already equipped
		{
			buyUpTo(1, $item[Ring of Detect Boring Doors]);
		}
	}
	
	//if you can not use the cubeling then pull the missing tools if possible
	pullXWhenHaveY($item[Eleven-Foot Pole], 1, 0);
	if(!possessEquipment($item[Ring of Detect Boring Doors]))	//do not pull a second one if already equipped
	{
		pullXWhenHaveY($item[Ring of Detect Boring Doors], 1, 0);
	}
	if(item_amount($item[Pick-O-Matic Lockpicks]) == 0)
	{
		pullXWhenHaveY($item[Platinum Yendorian Express Card], 1, 0);
	}
	if(item_amount($item[Platinum Yendorian Express Card]) == 0)
	{
		pullXWhenHaveY($item[Pick-O-Matic Lockpicks], 1, 0);
	}
	
	//if you do not have an unlimited lockpick then handle skeleton keys and verify primary stat
	if(item_amount($item[Platinum Yendorian Express Card]) == 0 && item_amount($item[Pick-O-Matic Lockpicks]) == 0)
	{
		int skeleton_key_amt_needed = 2;
		if(contains_text(get_property("nsTowerDoorKeysUsed"), $item[Skeleton Key]))
		{
			skeleton_key_amt_needed--;
		}
		
		int skeleton_key_amt_to_create =  skeleton_key_amt_needed - item_amount($item[Skeleton Key]);
		skeleton_key_amt_to_create = min(creatable_amount($item[Skeleton Key]), skeleton_key_amt_to_create);
		if(skeleton_key_amt_to_create > 0)
		{
			create(skeleton_key_amt_to_create, $item[Skeleton Key]);
		}
		
		//make sure we have the means to handle choice adventure 692 [I Wanna Be a Door]
		if(item_amount($item[Skeleton Key]) < skeleton_key_amt_needed && my_basestat(my_primestat()) < 30)
		{
			//no lockpick, not enough skeleton key, and not enough primestat.
			//checking basestat because buffed can become lower based on equipment worn. and also if mainstat is under 30 and you got no lockpicks then you should probably delay daily dungeon
			return false;
		}
	}
	
	boolean has_pole = item_amount($item[Eleven-Foot Pole]) > 0;
	boolean has_picks = item_amount($item[Platinum Yendorian Express Card]) > 0 || item_amount($item[Pick-O-Matic Lockpicks]) > 0;
	
	//Ed will be doing daily dungeon if auto_forceFatLootToken == true
	if(!has_pole &&		//can take NC damage from traps
	!has_picks &&		//can take NC damage from doors
	edHarmfulNoncombatCheck(false))	//is ed and unable to handle dying from NC damage without wasting adventures
	{
		return false;
	}
	
	// make sure we have enough adventures. since partial completion means wasted adventures.
	int adv_budget = my_adventures() - auto_advToReserve();
	if(adv_budget < 1 + ceil(estimateDailyDungeonAdvNeeded()))
	{
		return false;	//not enough adv
	}
	
	auto_log_info("Doing the daily dungeon", "blue");
	
	if(get_property("_lastDailyDungeonRoom").to_int() == 4 || get_property("_lastDailyDungeonRoom").to_int() == 9)
	{
		autoEquip($slot[acc3], $item[Ring Of Detect Boring Doors]);
	}

	return autoAdv(1, $location[The Daily Dungeon]);
}

void dailyDungeonChoiceHandler(int choice, string[int] options)
{
	//noncombat choices handler for daily dungeon.
	
	switch (choice)
	{
		case 689: // The Final Reward (Daily Dungeon 15th room)
			run_choice(1);	// Get fat loot token
			break;
		case 690: // The First Chest Isn't the Deepest. (Daily Dungeon 5th room)
		case 691: // Second Chest (Daily Dungeon 10th room)
			if(options contains 2)
			{
				run_choice(2);	// skip 3 rooms using ring of Detect Boring Doors
			} 
			else
			{
				run_choice(3);	// skip 1 room
			}
			break;
		case 692: // I Wanna Be a Door (Daily Dungeon)
			if(options contains 3)
			{
				run_choice(3);	// use [Pick-O-Matic Lockpicks] to skip
			}
			else if(options contains 7)
			{
				run_choice(7);	// use [Platinum Yendorian Express Card] to skip
			}
			else if(item_amount($item[Skeleton Key]) > 1 ||
			(item_amount($item[Skeleton Key]) > 0 && contains_text(get_property("nsTowerDoorKeysUsed"), $item[Skeleton Key])))
			{
				run_choice(2);	// use [Skeleton Key] to skip
			}
			else if(my_primestat() == $stat[Muscle] && my_buffedstat($stat[Muscle]) >= 30)
			{
				run_choice(4);	// spend adv and not guarenteed to work
			}
			else if(my_primestat() == $stat[Mysticality] && my_buffedstat($stat[Mysticality]) >= 30)
			{
				run_choice(5);	// spend adv and not guarenteed to work
			}
			else if(my_primestat() == $stat[Moxie] && my_buffedstat($stat[Moxie]) >= 30)
			{
				run_choice(6);	// spend adv and not guarenteed to work
			}
			else abort("I made an error and tried to adventure in the daily dungeon when I have no means of handling [I Wanna Be a Door]");
			break;
		case 693: // It's Almost Certainly a Trap (Daily Dungeon)
			if(options contains 2)
			{
				run_choice(2);	// use eleven-foot pole to skip
			} 
			else
			{
				run_choice(1);	// take damage to progress
			}
			break;
		default:
			abort("unhandled choice in dailyDungeonChoiceHandler");
			break;

	}
}

boolean LX_dolphinKingMap()
{
	if(item_amount($item[Dolphin King\'s Map]) > 0)
	{
		if(possessEquipment($item[Snorkel]) || ((my_meat() >= npc_price($item[Snorkel])) && isArmoryAvailable()))
		{
			buyUpTo(1, $item[Snorkel]);
			item oldHat = equipped_item($slot[hat]);
			equip($item[Snorkel]);
			use(1, $item[Dolphin King\'s Map]);
			equip(oldHat);
			return true;
		}
	}
	return false;
}

boolean LX_meatMaid()
{
	if(auto_get_campground() contains $item[Meat Maid])
	{
		return false;
	}
	if (!knoll_available() || my_daycount() != 1 || get_property("questL07Cyrptic") != "finished")
	{
		return false;
	}

	if((item_amount($item[Smart Skull]) > 0) && (item_amount($item[Disembodied Brain]) > 0))
	{
		auto_log_info("Got a brain, trying to make and use a meat maid now.", "blue");
		cli_execute("make meat maid");
		use(1, $item[meat maid]);
		return true;
	}

	if(cloversAvailable() == 0)
	{
		return false;
	}
	if(my_meat() < 320)
	{
		return false;
	}
	auto_log_info("Well, we could make a Meat Maid and that seems raisinable.", "blue");

	if((item_amount($item[Brainy Skull]) == 0) && (item_amount($item[Disembodied Brain]) == 0))
	{
		cloverUsageInit();
		autoAdvBypass(58, $location[The VERY Unquiet Garves]);
		cloverUsageFinish();
		if(get_property("lastEncounter") == "Rolling the Bones")
		{
			auto_log_info("Got a brain, trying to make and use a meat maid now.", "blue");
			cli_execute("make " + $item[Meat Maid]);
			use(1, $item[Meat Maid]);
		}
		if(lastAdventureSpecialNC())
		{
			abort("May be stuck in an interrupting Non-Combat adventure, finish current adventure and resume");
		}
		return true;
	}
	return false;
}

boolean dependenceDayClovers()
{
	if(get_property("_fireworkUsed").to_boolean())
	{
		return false;	//only 1 firework per day allowed
	}
	if(holiday() != "Dependence Day")
	{
		return false;	//it is not dependence day today
	}
	if(isActuallyEd() && get_property("lastIslandUnlock").to_int() != my_ascensions())
	{
		return false;	//buying it before unlocking the island on day 1 makes you too poor to unlock it on day 1 and adds days to the run
	}
	
	auto_log_info("Today is Dependence Day and I want to use a [green rocket] for some clovers", "green");
	if(item_amount($item[green rocket]) == 0 && my_meat() < npc_price($item[green rocket]))
	{
		auto_log_info("I can't afford a [green rocket]. I will try again later");
		return false;
	}
	
	buyUpTo(1, $item[green rocket]);
	if(item_amount($item[green rocket]) > 0)
	{
		return use(1, $item[green rocket]);
	}
	return false;
}
