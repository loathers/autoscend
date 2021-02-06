record desert_buff_record
{
	item offhand;
	item fam_equip;
	familiar fam;
	int progress;
};

desert_buff_record desertBuffs()
{
    desert_buff_record dbr;

    dbr.progress = 1;

	boolean possessUnrestricted(item it)
	{
		return possessEquipment(it) && is_unrestricted(it);
	}

	boolean compassValid = possessUnrestricted($item[UV-resistant compass]);
	boolean lhmValid = canChangeToFamiliar($familiar[Left-Hand Man]);
	boolean meloValid = canChangeToFamiliar($familiar[Melodramedary]);
	boolean odrValid = possessUnrestricted($item[Ornate Dowsing Rod]);

	dbr.fam = $familiar[none];
	dbr.fam_equip = $item[none];
	dbr.offhand = $item[none];

	// If we can't use the Ornate dowsing rod
	if (!odrValid)
	{
		// And we can use the compass
		if (compassValid)
		{
			// And we have the Left-Hand man but not the Melodramedary
			// Free up our offhand for something useful
			if (lhmValid && !meloValid)
			{
				dbr.fam = $familiar[Left-Hand Man];
				dbr.fam_equip = $item[UV-resistant compass];
				dbr.progress += 1;
			}
			// Otherwise hold the compass
			else
			{
				dbr.offhand = $item[UV-resistant compass];
				dbr.progress += 1;
			}
		}

		// If we have the Melodramedary use it!
		if (meloValid)
		{
			dbr.fam = $familiar[Melodramedary];
			dbr.progress += 1;
		}
	}
	// Otherwise
	else
	{
		// If we have it and a Left-Hand man is our best familiar choice
		// but we have no compass free up our offhand
		if (!compassValid && lhmValid && !meloValid)
		{
			dbr.fam = $familiar[Left-Hand Man];
			dbr.fam_equip = $item[Ornate Dowsing Rod];
			dbr.progress += 2;
		}
		// Otherwise we can just hold it
		else
		{
			dbr.offhand = $item[Ornate Dowsing Rod];
			dbr.progress += 2;
		}

		// Melodramedary is better here though
		if (meloValid)
		{
			dbr.fam = $familiar[Melodramedary];
			dbr.progress += 1;
		}
		// Otherwise we can give the compass to the Left-Hand man if possible
		else if (compassValid && lhmValid)
		{
			dbr.fam = $familiar[Left-Hand Man];
			dbr.fam_equip = $item[UV-resistant compass];
			dbr.progress += 1;
		}
	}

	// There are some other familiars we might choose if nothing affects progress
	if (dbr.fam == $familiar[none])
	{
		if(get_property("_hipsterAdv").to_int() < 7 && canChangeToFamiliar($familiar[Artistic Goth Kid]))
		{
			dbr.fam = $familiar[Artistic Goth Kid];
		}
		else if(get_property("_hipsterAdv").to_int() < 7 && canChangeToFamiliar($familiar[Mini-Hipster]))
		{
			dbr.fam = $familiar[Mini-Hipster];
		}
	}

    return dbr;
}

int shenItemsReturned()
{
	int progress = internalQuestStatus("questL11Shen");
	if (progress < 3) return 0;
	if (progress < 5) return 1;
	else if (progress < 7) return 2;
	else return 3;
}

boolean[location] shenSnakeLocations(int day, int n_items_returned)
{
	// Returns the locations in which we will find snakes for Shen, on a particular day.
	// From https://kol.coldfront.net/thekolwiki/index.php/Shen_Copperhead,_Nightclub_Owner

	boolean[location] union(boolean[location] one, boolean[location] two, boolean[location] three)
	{
		boolean[location] ret;
		switch (n_items_returned)
		{
		case 0:
		foreach z, _ in one { ret[z] = true; }
		case 1:
		foreach z, _ in two { ret[z] = true; }
		case 2:
		foreach z, _ in three { ret[z] = true; }
		case 3:
		}
		return ret;
	}
	boolean[location] batsnake  = $locations[The Batrat and Ratbat Burrow];
	boolean[location] frozen    = $locations[Lair of the Ninja Snowmen];
	boolean[location] burning   = $locations[The Castle in the Clouds in the Sky (Top Floor)];
	boolean[location] ten_heads = $locations[The Hole in the Sky];
	boolean[location] frattle   = $locations[The Smut Orc Logging Camp];
	boolean[location] snakleton = $locations[The Unquiet Garves, The VERY Unquiet Garves];

	if (in_koe())
	{
		return union(ten_heads, frattle, frozen);
	}

	switch (day) {
	case 1: return union(batsnake, frozen, burning);
	case 2: return union(frattle, snakleton, ten_heads);
	case 3: return union(frozen, batsnake, snakleton);
	case 4: return union(frattle, batsnake, snakleton);
	case 5: return union(burning, batsnake, ten_heads);
	case 6: return union(burning, batsnake, ten_heads);
	case 7: return union(frattle, snakleton, ten_heads);
	case 8: return union(snakleton, burning, frattle);
	case 9: return union(snakleton, frattle, ten_heads);
	case 10: return union(ten_heads, batsnake, burning);
	case 11: return union(frozen, batsnake, burning);
	}
	boolean[location] empty;
	return empty;
}

boolean[location] shenZonesToAvoidBecauseMaybeSnake()
{
	if (!allowSoftblockShen())
	{
		boolean[location] empty;
		return empty;
	}
	if (get_property("shenInitiationDay").to_int() > 0)
	{
		int day = get_property("shenInitiationDay").to_int();
		int items_returned = shenItemsReturned();
		return shenSnakeLocations(day, items_returned);
	}
	else
	{
		// Assume we're going to start Shen today, tomorrow, or two days from now.
		boolean[location] zones_to_avoid;
		if (my_level() < 11)
		{

			for (int day=0; day<3; day++)
			{
				foreach z, _ in shenSnakeLocations(day+my_daycount(), 0)
				{
					zones_to_avoid[z] = true;
				}

			}
		}
		else
		{
			// if we're already level 11, well either be starting ASAP
			// or leaving it until day 2 if we're on day 1
			foreach z, _ in shenSnakeLocations(max(2, my_daycount()), 0)
			{
				zones_to_avoid[z] = true;
			}
		}
		return zones_to_avoid;
	}
}

boolean shenShouldDelayZone(location loc)
{
	return shenZonesToAvoidBecauseMaybeSnake() contains loc;
}

int[location] getShenZonesTurnsSpent()
{
	int[location] delayValues;
	if (get_property("auto_shenZonesTurnsSpent") != "")
	{
		string[int] zones = split_string(get_property("auto_shenZonesTurnsSpent"), ";");
		foreach _, zone in zones
		{
			location loc = zone.substring(0, zone.index_of(":")).to_location();
			int turns_spent = zone.substring(zone.index_of(":") + 1).to_int();
			delayValues[loc] = turns_spent;
		}
	}
	return delayValues;
}

boolean LX_unlockHiddenTemple() {
	// replaces L2_treeCoin(),  L2_spookyMap(),  L2_spookyFertilizer() & L2_spookySapling()

	if (auto_my_path() == "G-Lover") {
		// Spooky Temple map ain't nuthin' but a 'G' Thang.
		return false;
	}

	if (hidden_temple_unlocked()) {
		return false;
	}
	if (item_amount($item[Spooky Sapling]) == 0 && my_meat() < 100) {
		return false;
	}
	if (canBurnDelay($location[The Spooky Forest]))
	{
		// Arboreal Respite choice adventure has a delay of 5 adventures.
		return false;
	}
	auto_log_info("Attempting to make the Hidden Temple less hidden.", "blue");
	pullXWhenHaveY($item[Spooky-Gro Fertilizer], 1, 0);
	if (autoAdv($location[The Spooky Forest])) {
		if (item_amount($item[Spooky Temple map]) > 0 && item_amount($item[Spooky-Gro Fertilizer]) > 0 && item_amount($item[Spooky Sapling]) > 0) {
			use(1, $item[Spooky Temple Map]);
		}
		return true;
	}
	return false;
}

boolean hasSpookyravenLibraryKey()
{
	return ((item_amount($item[1764]) > 0) || (item_amount($item[7302]) > 0));
}

boolean hasILoveMeVolI()
{
	return ((item_amount($item[2258]) > 0) || (item_amount($item[7262]) > 0));
}

boolean useILoveMeVolI()
{
	if(item_amount($item[2258]) > 0)
	{
		return use(1, $item[2258]);
	}
	else if(item_amount($item[7262]) > 0)
	{
		return use(1, $item[7262]);
	}
	return false;
}

boolean LX_unlockHauntedBilliardsRoom(boolean forceDelay) {
	// forceDelay will force the check for 9 hot res & 9 stench res to be used regardless of what
	// auto_delayHauntedKitchen is set to.
	if (internalQuestStatus("questM20Necklace") != 0) {
		return false;
	}

	if (get_property("manorDrawerCount").to_int() >= 24) {
		cli_execute("refresh inv");
	}

	if (item_amount($item[Spookyraven billiards room key]) > 0) {
		return false;
	}
	
	boolean delayKitchen = get_property("auto_delayHauntedKitchen").to_boolean() || forceDelay;
	if (isAboutToPowerlevel()) {
		// if we're at the point where we need to level up to get more quests other than this, we might as well just do this instead
		delayKitchen = false;
	}
	if (delayKitchen) {
		int [element] resGoals;
		resGoals[$element[hot]] = 9;
		resGoals[$element[stench]] = 9;
		// check to see if we can acquire sufficient hot and stench res for the kitchen
		int [element] resPossible = provideResistances(resGoals, true, true);
		delayKitchen = (resPossible[$element[hot]] < 9 || resPossible[$element[stench]] < 9);
	}

	if (delayKitchen && isActuallyEd()) {
		// If we already have all the elemental wards as ed we're probably not going to get any better, so might as well get it over with
		delayKitchen = !have_skill($skill[Even More Elemental Wards]);
	}

	if (!delayKitchen) {
		int [element] resGoal;
		resGoal[$element[hot]] = 9;
		resGoal[$element[stench]] = 9;
		int [element] resPossible = provideResistances(resGoal, true, false);
		auto_log_info("Looking for the Billards Room key (Hot/Stench:" + resPossible[$element[hot]] + "/" + resPossible[$element[stench]] + "): Progress " + get_property("manorDrawerCount") + "/24", "blue");
		if (autoAdv($location[The Haunted Kitchen])) {
			return true;
		}
	}
	return false;
}

boolean LX_unlockHauntedBilliardsRoom() {
	return LX_unlockHauntedBilliardsRoom(false);
}

boolean LX_unlockHauntedLibrary()
{
	//Adventure in the haunted billiards room to get the key to the haunted library
	if (internalQuestStatus("questM20Necklace") < 1 || internalQuestStatus("questM20Necklace") > 2)
	{
		return false;
	}
	if (item_amount($item[Spookyraven billiards room key]) < 1 || hasSpookyravenLibraryKey())
	{
		return false;
	}
	
	//equipment handling
	int expectPool = speculative_pool_skill();
	item staffOfFats = $item[2268];		//regular staff of fats. +5 pool +2 training
	item EdStaffOfFats = $item[7964];	//ed path version of staff of fats. +5 pool
	item EdStaffOfEd = $item[7961];		//ed path version of staff of ed. +5 pool
	
	if(in_boris())
	{
		auto_log_info("Boris cannot equip a pool cue.", "blue");
	}
	else if(in_tcrs())
	{
		auto_log_info("During this Crazy Summer Pool Cues are used differently.", "blue");
	}
	else if(expectPool > 17)
	{
		auto_log_info("I don't need to equip a cue to beat this ghostie.", "blue");
	}
	else
	{
		if(possessEquipment(staffOfFats))
		{
			autoEquip(staffOfFats);		//+5 pool skill & +2 training gains.
			expectPool += 5;
		}
		else if(possessEquipment(EdStaffOfEd) && expectPool + 5 > 13)
		{
			autoEquip(EdStaffOfEd);		//+5 pool skill
			expectPool += 5;
		}
		else if(possessEquipment(EdStaffOfFats) && expectPool + 5 > 13)
		{
			autoEquip(EdStaffOfFats);	//+5 pool skill
			expectPool += 5;
		}
		else if(possessEquipment($item[Pool Cue]) && expectPool + 3 > 13)
		{
			autoEquip($item[Pool Cue]);	//+3 pool skill
			expectPool += 3;
		}
	}
	
	//inebrity handling. do not care if: auto succeed or can't drink or ran out of things to do.
	if(expectPool < 18 && can_drink() && !isAboutToPowerlevel())
	{
		//paths with inebrity limit under 11 should wait until they are at max to do this
		if(my_inebriety() < inebriety_limit() && inebriety_limit() < 11)
		{
			auto_log_info("I will come back when I had more to drink.", "green");
			resetMaximize();	//cancel equipping pool cue
			return false;
		}
		if(my_inebriety() < 8)
		{
			auto_log_info("I will come back when I had more to drink.", "green");
			resetMaximize();	//cancel equipping pool cue
			return false;
		}
		if(my_inebriety() > 11)
		{
			int penalty = 2 * (10 - my_inebriety());
			auto_log_info("I overshot my inebrity goal for the [Haunted Billiards Room] which gives me a penalty of " + penalty + "pool skill. I will come back tomorrow or if I run out of things to do.", "green");
			resetMaximize();	//cancel equipping pool cue
			return false;
		}
	}
	
	//+3 pool skill & +1 training gains. speculative_pool_skill() already assumed we would use it if we can.
	buffMaintain($effect[Chalky Hand], 0, 1, 1);

	if (internalQuestStatus("questM20Necklace") == 2)
	{
		// only force after we get the pool cue NC.
		auto_forceNextNoncombat();
	}
	auto_log_info("It's billiards time!", "blue");
	return autoAdv($location[The Haunted Billiards Room]);
}

boolean LX_unlockManorSecondFloor() {
	if (internalQuestStatus("questM20Necklace") < 3 || internalQuestStatus("questM20Necklace") > 4) {
		return false;
	}

	if (!hasSpookyravenLibraryKey()) {
		return false;
	}

	//finish quest
	if (item_amount($item[Lady Spookyraven\'s Necklace]) > 0) {
		auto_log_info("Giving Lady Spookyraven her necklace.", "blue");
		visit_url("place.php?whichplace=manor1&action=manor1_ladys");
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		return true;
	}
	
	if(my_turncount() == get_property("_LAR_skipNC163").to_int())
	{
		auto_log_info("In LAR path NC163 is forced to reoccur if we skip it. Go do something else.");
		return false;
	}

	auto_log_info("Well, we need writing desks", "blue");
	auto_log_info("Going to the library!", "blue");
	if (canSniff($monster[Writing Desk], $location[The Haunted Library]) && auto_mapTheMonsters())
	{
		auto_log_info("Attemping to use Map the Monsters to olfact a writing desk.");
	}
	return autoAdv($location[The Haunted Library]);
}

boolean LX_spookyravenManorFirstFloor() {
	if (get_property("lastSecondFloorUnlock").to_int() >= my_ascensions()) {
		return false;
	}

	if (LX_unlockManorSecondFloor() || LX_unlockHauntedLibrary() || LX_unlockHauntedBilliardsRoom()) {
		return true;
	}
	return false;
}

boolean LX_danceWithLadySpookyraven() {
	if (internalQuestStatus("questM21Dance") < 2 || internalQuestStatus("questM21Dance") > 3) {
		return false;
	}

	if (item_amount($item[Lady Spookyraven\'s Powder Puff]) == 1 && item_amount($item[Lady Spookyraven\'s Dancing Shoes]) == 1 && item_amount($item[Lady Spookyraven\'s Finest Gown]) == 1) {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
	}

	auto_log_info("Finished Spookyraven, just dancing with the lady.", "blue");
	if (autoAdv($location[The Haunted Ballroom])) {
		if (in_lowkeysummer()) {
			// need to open the Haunted Nursery for the music box key.
			visit_url("place.php?whichplace=manor3&action=manor3_ladys");
		}
		return true;
	}
	return false;
}

boolean LX_getLadySpookyravensFinestGown() {
	if (internalQuestStatus("questM21Dance") != 1) {
		return false;
	}
	// Elegant animated nightstand has a delay of 6(?) adventures.
	// TODO: add a check for delay burning?
	// Might not be worth it since we need to fight ornate nightstands for the spectacles and camera
	if (item_amount($item[Lady Spookyraven\'s Finest Gown]) > 0) {
		// got the Bedroom item but we might still need items for other parts
		// of the macguffin quest if we got unlucky
		boolean needSpectacles = (item_amount($item[Lord Spookyraven\'s Spectacles]) == 0 && internalQuestStatus("questL11Manor") < 2);
		boolean needCamera = (item_amount($item[disposable instant camera]) == 0 && internalQuestStatus("questL11Palindome") < 1);
		if (in_boris() || auto_my_path() == "Way of the Surprising Fist" || (auto_my_path() == "Nuclear Autumn" && in_hardcore())) {
			needSpectacles = false;
		}

		if(!needSpectacles && !needCamera) {
			return false;
		}
	}

	auto_log_info("Spookyraven: Bedroom, rummaging through nightstands looking for naughty meatbag trinkets.", "blue");
	if (autoAdv($location[The Haunted Bedroom])) {
		return true;
	}
	return false;
}

boolean LX_getLadySpookyravensDancingShoes() {
	if (internalQuestStatus("questM21Dance") != 1) {
		return false;
	}

	if (item_amount($item[Lady Spookyraven\'s Dancing Shoes]) > 0) {
		return false;
	}

	if (canBurnDelay($location[The Haunted Gallery]))
	{
		// Louvre It or Leave It choice adventure has a delay of 5 adventures.
		return false;
	}

	backupSetting("louvreDesiredGoal", "7"); // lets just let mafia automate this for us.
	auto_log_info("Spookyraven: Gallery", "blue");

	auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);

	if (autoAdv($location[The Haunted Gallery])) {
		return true;
	}
	return false;
}

boolean LX_getLadySpookyravensPowderPuff() {
	if (internalQuestStatus("questM21Dance") != 1) {
		return false;
	}
		
	if (item_amount($item[Lady Spookyraven\'s Powder Puff]) > 0) {
		return false;
	}

	if (canBurnDelay($location[The Haunted Bathroom]))
	{
		// Never Gonna Make You Up choice adventure has a delay of 5 adventures.
		return false;
	}

	auto_log_info("Spookyraven: Bathroom", "blue");

	auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);

	if (!zone_delay($location[The Haunted Bathroom])._boolean) {
		auto_forceNextNoncombat();
	}
	if (autoAdv($location[The Haunted Bathroom])) {
		return true;
	}
	return false;
}

boolean LX_spookyravenManorSecondFloor()
{
	if (get_property("lastSecondFloorUnlock").to_int() < my_ascensions()) {
		return false;
	}
	if (LX_danceWithLadySpookyraven() || LX_getLadySpookyravensFinestGown() || LX_getLadySpookyravensDancingShoes() || LX_getLadySpookyravensPowderPuff()) {
		return true;
	}
	return false;
}

boolean L11_blackMarket()
{
	if (internalQuestStatus("questL11Black") < 0 || internalQuestStatus("questL11Black") > 1 || black_market_available())
	{
		return false;
	}
	if ((possessEquipment($item[Blackberry Galoshes]) && !auto_can_equip($item[Blackberry Galoshes])) && !isAboutToPowerlevel())
	{
		return false;
	}

	if($location[The Black Forest].turns_spent > 12)
	{
		auto_log_warning("We have spent a bit many adventures in The Black Forest... manually checking", "red");
		visit_url("place.php?whichplace=woods");
		visit_url("woods.php");
		if($location[The Black Forest].turns_spent > 30)
		{
			abort("We have spent too many turns in The Black Forest and haven't found The Black Market. Something is wrong. (try \"refresh quests\" on the cli)");
		}
	}

	auto_log_info("Must find the Black Market: " + get_property("blackForestProgress"), "blue");
	if (internalQuestStatus("questL11Black") == 0 && item_amount($item[black map]) == 0)
	{
		council();
		if (!possessEquipment($item[Blackberry Galoshes]) && auto_can_equip($item[Blackberry Galoshes]))
		{
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
		}
	}

	if(item_amount($item[beehive]) > 0)
	{
		set_property("auto_getBeehive", false);
	}

	autoEquip($slot[acc3], $item[Blackberry Galoshes]);

	//If we want the Beehive, and don\'t have enough adventures, this is dangerous.
	if (get_property("auto_getBeehive").to_boolean() && my_adventures() < 3) {
		return false;
	}
	boolean advSpent = autoAdv($location[The Black Forest]);
	//For people with autoCraft set to false for some reason
	if(item_amount($item[Reassembled Blackbird]) == 0 && creatable_amount($item[Reassembled Blackbird]) > 0)
	{
		create(1, $item[Reassembled Blackbird]);
	}
	if (advSpent) {
		return true;
	}
	return false;
}

boolean L11_getBeehive()
{
	if (!black_market_available() || !get_property("auto_getBeehive").to_boolean())
	{
		return false;
	}
	if((internalQuestStatus("questL13Final") >= 7) || (item_amount($item[Beehive]) > 0))
	{
		auto_log_info("Nevermind, wall of skin already defeated (or we already have a beehiven). We do not need a beehive. Bloop.", "blue");
		set_property("auto_getBeehive", false);
		return false;
	}

	auto_log_info("Must find a beehive!", "blue");

	auto_forceNextNoncombat();
	boolean advSpent = autoAdv($location[The Black Forest]);
	if(item_amount($item[beehive]) > 0)
	{
		set_property("auto_getBeehive", false);
	}
	return advSpent;
}

boolean L11_forgedDocuments()
{
	if (internalQuestStatus("questL11Black") < 0 || internalQuestStatus("questL11Black") > 2 || !black_market_available())
	{
		return false;
	}
	if (item_amount($item[Forged Identification Documents]) > 0)
	{
		return false;
	}
	if (my_meat() < npc_price($item[Forged Identification Documents]))
	{
		if(isAboutToPowerlevel())
		{
			abort("Could not afford to buy Forged Identification Documents, can not steal identities!");
		}
		return false;
	}

	auto_log_info("Getting the McMuffin Book", "blue");
	if(auto_my_path() == "Way of the Surprising Fist")
	{
		// TODO: move this to WotSF path file if one is ever created.
		string[int] pages;
		pages[0] = "shop.php?whichshop=blackmarket";
		pages[1] = "shop.php?whichshop=blackmarket&action=fightbmguy";
		return autoAdvBypass(0, pages, $location[Noob Cave], "");
	}
	buyUpTo(1, $item[Forged Identification Documents]);
	if(item_amount($item[Forged Identification Documents]) > 0)
	{
		return true;
	}
	auto_log_warning("Could not buy Forged Identification Documents, can't get booze now!", "red");
	return false;
}

boolean L11_mcmuffinDiary()
{
	if (internalQuestStatus("questL11MacGuffin") != 1 || internalQuestStatus("questL11Black") < 2)
	{
		return false;
	}
	if (in_koe() && item_amount($item[Forged Identification Documents]) > 0)
	{
		council(); // Shore doesn't exist in Exploathing so we acquire diary from the council
	}
	if(item_amount($item[Your Father\'s Macguffin Diary]) > 0)
	{
		use(item_amount($item[Your Father\'s Macguffin Diary]), $item[Your Father\'s Macguffin Diary]);
		return true;
	}
	if(item_amount($item[Copy of a Jerk Adventurer\'s Father\'s Diary]) > 0)
	{
		use(item_amount($item[Copy of a Jerk Adventurer\'s Father\'s Diary]), $item[Copy of a Jerk Adventurer\'s Father\'s Diary]);
		return true;
	}
	if (my_adventures() < 4 || my_meat() < 500 || item_amount($item[Forged Identification Documents]) == 0)
	{
		if(isAboutToPowerlevel())
		{
			abort("Could not vacation at the shore to find your fathers diary!");
		}
		return false;
	}

	auto_log_info("Getting the McMuffin Diary", "blue");
	LX_doVacation();
	foreach diary in $items[Your Father\'s Macguffin Diary, Copy of a Jerk Adventurer\'s Father\'s Diary]
	{
		if(item_amount(diary) > 0)
		{
			use(item_amount(diary), diary);
			return true;
		}
	}
	return false;
}

void auto_visit_gnasir()
{
	//Visits gnasir, can change based on path
	if (in_koe())
	{
		visit_url("place.php?whichplace=exploathing_beach&action=expl_gnasir");
	}
	else
	{
		visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
	}
}

boolean L11_getUVCompass()
{
	//acquire a [UV-resistant compass] if needed
	if(possessEquipment($item[Ornate Dowsing Rod]) && auto_can_equip($item[Ornate Dowsing Rod]))
	{
		return false;		//already have a dowsing rod. we do not need a compass.
	}
	if(!auto_can_equip($item[UV-resistant compass]))
	{
		return false;
	}
	if(possessEquipment($item[UV-resistant compass]))
	{
		return false;		//already have compass
	}
	if(in_koe())
	{
		return false;		//impossible to get compass in this path. [The Shore, Inc] is unavailable
	}

	pullXWhenHaveY($item[Shore Inc. Ship Trip Scrip], 1, 0);
	if(item_amount($item[Shore Inc. Ship Trip Scrip]) == 0)
	{
		return LX_doVacation();
	}
	
	if(create(1, $item[UV-Resistant Compass]))
	{
		return true;
	}
	else
	{
		cli_execute("refresh inv");
		if(possessEquipment($item[UV-resistant compass]))
		{
			return true;
		}
		else abort("I have the Scrip for it but am failing to buy [UV-resistant compass] for some reason. buy it manually and run me again");
	}

	return false;
}

boolean L11_aridDesert()
{
	if(internalQuestStatus("questL11Desert") != 0)
	{
		return false;
	}

	// Fix broken desert tracking. pocket familiars failing as of r19010. plumber as of r20019
	if(in_zelda() || in_pokefam())
	{
		visit_url("place.php?whichplace=desertbeach", false);
	}
	if(get_property("desertExploration").to_int() >= 100)
	{
		return false;		//done exploring
	}
	
	if(LX_ornateDowsingRod(true)) return true;		//spend adv trying to get [Ornate Dowsing Rod]. doing_desert_now = true.
	if(L11_getUVCompass()) return true;				//spend adv trying to get [UV-resistant compass]

	desert_buff_record dbr = desertBuffs();

	int progress = dbr.progress;

	if(get_property("bondDesert").to_boolean())
	{
		progress += 2;
	}
	if(get_property("peteMotorbikeHeadlight") == "Blacklight Bulb")	//TODO verify spelling on this string
	{
		progress += 2;
	}

	if((have_effect($effect[Ultrahydrated]) > 0) || (get_property("desertExploration").to_int() == 0))
	{
		auto_log_info("Searching for the pyramid", "blue");
		if(auto_my_path() == "Heavy Rains")
		{
			autoEquip($item[Thor\'s Pliers]);
		}

		if(possessEquipment($item[reinforced beaded headband]) && possessEquipment($item[bullet-proof corduroys]) && possessEquipment($item[round purple sunglasses]))
		{
			foreach it in $items[Beer Helmet, Distressed Denim Pants, Bejeweled Pledge Pin]
			{
				take_closet(closet_amount(it), it);
			}
		}

		buyUpTo(1, $item[hair spray]);
		buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);
		if(my_primestat() == $stat[Muscle])
		{
			buyUpTo(1, $item[Ben-Gal&trade; Balm]);
			buffMaintain($effect[Go Get \'Em, Tiger!], 0, 1, 1);
			buyUpTo(1, $item[Blood of the Wereseal]);
			buffMaintain($effect[Temporary Lycanthropy], 0, 1, 1);
		}

		if(my_mp() > 30 && my_hp() < (my_maxhp()*0.5))
		{
			acquireHP();
		}

		if((in_hardcore() || (pulls_remaining() == 0)) && (item_amount($item[Worm-Riding Hooks]) > 0) && (get_property("desertExploration").to_int() <= (100 - (5 * progress))) && ((get_property("gnasirProgress").to_int() & 16) != 16) && (item_amount($item[Stone Rose]) == 0))
		{
			if(item_amount($item[Drum Machine]) > 0)
			{
				auto_log_info("Found the drums, now we use them!", "blue");
				use(1, $item[Drum Machine]);
			}
			else
			{
				auto_log_info("Off to find the drums!", "blue");
				autoAdv(1, $location[The Oasis]);
			}
			return true;
		}

		if(((get_property("gnasirProgress").to_int() & 1) != 1))
		{
			int expectedOasisTurns = 8 - $location[The Oasis].turns_spent;
			int equivProgress = expectedOasisTurns * progress;
			int need = 100 - get_property("desertExploration").to_int();
			auto_log_info("expectedOasis: " + expectedOasisTurns, "brown");
			auto_log_info("equivProgress: " + equivProgress, "brown");
			auto_log_info("need: " + need, "brown");
			if((need <= 15) && (15 >= equivProgress) && (item_amount($item[Stone Rose]) == 0))
			{
				auto_log_info("It seems raisinable to hunt a Stone Rose. Beep", "blue");
				autoAdv(1, $location[The Oasis]);
				return true;
			}
		}

		if (dbr.fam != $familiar[none])
		{
			handleFamiliar(dbr.fam);
		}
		if (dbr.offhand != $item[none])
		{
			autoEquip($slot[off-hand], dbr.offhand);
		}
		if (dbr.fam_equip != $item[none])
		{
			autoEquip($slot[familiar], dbr.fam_equip);
		}
		set_property("choiceAdventure805", 1);
		int need = 100 - get_property("desertExploration").to_int();
		auto_log_info("Need for desert: " + need, "blue");
		auto_log_info("Worm riding: " + item_amount($item[Worm-Riding Manual Page]), "blue");

		if(!get_property("auto_gnasirUnlocked").to_boolean() && ($location[The Arid\, Extra-Dry Desert].turns_spent > 10) && (get_property("desertExploration").to_int() > 10))
		{
			auto_log_info("Did not appear to notice that Gnasir unlocked, assuming so at this point.", "green");
			set_property("auto_gnasirUnlocked", true);
		}

		if(get_property("auto_gnasirUnlocked").to_boolean() && (item_amount($item[Stone Rose]) > 0) && ((get_property("gnasirProgress").to_int() & 1) != 1))
		{
			auto_log_info("Returning the stone rose", "blue");
			auto_visit_gnasir();
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			visit_url("choice.php?whichchoice=805&option=2&pwd=");
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
			{
				cli_execute("refresh inv");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					abort("Returned stone rose but did not return stone rose.");
				}
				else
				{
					if((get_property("gnasirProgress").to_int() & 1) != 1)
					{
						auto_log_warning("Mafia did not track gnasir Stone Rose (0x1). Fixing.", "red");
						set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 1);
					}
				}
			}
			use(1, $item[desert sightseeing pamphlet]);
			return true;
		}

		if(get_property("auto_gnasirUnlocked").to_boolean() && ((get_property("gnasirProgress").to_int() & 2) != 2))
		{
			boolean canBuyPaint = true;
			if((auto_my_path() == "Way of the Surprising Fist") || (auto_my_path() == "Nuclear Autumn"))
			{
				canBuyPaint = false;
			}

			if((item_amount($item[Can of Black Paint]) > 0) || ((my_meat() >= npc_price($item[Can of Black Paint])) && canBuyPaint))
			{
				buyUpTo(1, $item[Can of Black Paint]);
				auto_log_info("Returning the Can of Black Paint", "blue");
				auto_visit_gnasir();
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				visit_url("choice.php?whichchoice=805&option=2&pwd=");
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					cli_execute("refresh inv");
					if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
					{
						if(item_amount($item[Can Of Black Paint]) == 0)
						{
							auto_log_warning("Mafia did not track gnasir Can of Black Paint (0x2). Fixing.", "red");
							set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 2);
							return true;
						}
						else
						{
							abort("Returned can of black paint but did not return can of black paint.");
						}
					}
					else
					{
						if((get_property("gnasirProgress").to_int() & 2) != 2)
						{
							auto_log_warning("Mafia did not track gnasir Can of Black Paint (0x2). Fixing.", "red");
							set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 2);
						}
					}
				}
				use(1, $item[desert sightseeing pamphlet]);
				return true;
			}
		}

		if(get_property("auto_gnasirUnlocked").to_boolean() && (item_amount($item[Killing Jar]) > 0) && ((get_property("gnasirProgress").to_int() & 4) != 4))
		{
			auto_log_info("Returning the killing jar", "blue");
			auto_visit_gnasir();
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			visit_url("choice.php?whichchoice=805&option=2&pwd=");
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
			{
				cli_execute("refresh inv");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					abort("Returned killing jar but did not return killing jar.");
				}
				else
				{
					if((get_property("gnasirProgress").to_int() & 4) != 4)
					{
						auto_log_warning("Mafia did not track gnasir Killing Jar (0x4). Fixing.", "red");
						set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 4);
					}
				}
			}
			use(1, $item[desert sightseeing pamphlet]);
			return true;
		}

		if((item_amount($item[Worm-Riding Manual Page]) >= 15) && ((get_property("gnasirProgress").to_int() & 8) != 8))
		{
			auto_log_info("Returning the worm-riding manual pages", "blue");
			auto_visit_gnasir();
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			visit_url("choice.php?whichchoice=805&option=2&pwd=");
			visit_url("choice.php?whichchoice=805&option=1&pwd=");
			if(item_amount($item[Worm-Riding Hooks]) == 0)
			{
				auto_log_critical("We messed up in the Desert, get the Worm-Riding Hooks and use them please.");
				abort("We messed up in the Desert, get the Worm-Riding Hooks and use them please.");
			}
			if(item_amount($item[Worm-Riding Manual Page]) >= 15)
			{
				auto_log_warning("Mafia doesn't realize that we've returned the worm-riding manual pages... fixing", "red");
				cli_execute("refresh all");
				if((get_property("gnasirProgress").to_int() & 8) != 8)
				{
					auto_log_warning("Mafia did not track gnasir Worm-Riding Manual Pages (0x8). Fixing.", "red");
					set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 8);
				}
			}
			return true;
		}

		need = 100 - get_property("desertExploration").to_int();
		if((item_amount($item[Worm-Riding Hooks]) > 0) && ((get_property("gnasirProgress").to_int() & 16) != 16))
		{
			pullXWhenHaveY($item[Drum Machine], 1, 0);
			if(item_amount($item[Drum Machine]) > 0)
			{
				auto_log_info("Drum machine desert time!", "blue");
				use(1, $item[Drum Machine]);
				return true;
			}
		}

		need = 100 - get_property("desertExploration").to_int();
		# If we have done the Worm-Riding Hooks or the Killing jar, don\'t do this.
		if((need <= 15) && ((get_property("gnasirProgress").to_int() & 12) == 0))
		{
			pullXWhenHaveY($item[Killing Jar], 1, 0);
			if(item_amount($item[Killing Jar]) > 0)
			{
				auto_log_info("Secondary killing jar handler", "blue");
				auto_visit_gnasir();
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				visit_url("choice.php?whichchoice=805&option=2&pwd=");
				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
				{
					cli_execute("refresh inv");
					if(item_amount($item[Desert Sightseeing Pamphlet]) == 0)
					{
						abort("Returned killing jar (secondard) but did not return killing jar.");
					}
					else
					{
						if((get_property("gnasirProgress").to_int() & 4) != 4)
						{
							auto_log_warning("Mafia did not track gnasir Killing Jar (0x4). Fixing.", "red");
							set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 4);
						}
					}
				}
				use(1, $item[desert sightseeing pamphlet]);
				return true;
			}
		}

		autoAdv(1, $location[The Arid\, Extra-Dry Desert]);

		if(contains_text(get_property("lastEncounter"), "A Sietch in Time"))
		{
			auto_log_info("We've found the gnome!! Sightseeing pamphlets for everyone!", "green");
			set_property("auto_gnasirUnlocked", true);
		}

		if(contains_text(get_property("lastEncounter"), "He Got His Just Desserts"))
		{
			take_closet(closet_amount($item[Beer Helmet]), $item[Beer Helmet]);
			take_closet(closet_amount($item[Distressed Denim Pants]), $item[Distressed Denim Pants]);
			take_closet(closet_amount($item[Bejeweled Pledge Pin]), $item[Bejeweled Pledge Pin]);
		}
	}
	else
	{
		int need = 100 - get_property("desertExploration").to_int();
		auto_log_info("Getting some ultrahydrated, I suppose. Desert left: " + need, "blue");

		if((need > (5 * progress)) && cloversAvailable() > 2 && !auto_haveLovebugs())
		{
			auto_log_info("Gonna clover this, yeah, it only saves 2 adventures. So?", "green");
			cloverUsageInit();
			autoAdvBypass("adventure.php?snarfblat=122", $location[The Oasis]);
			cloverUsageFinish();
		}
		else
		{
			if(!autoAdv(1, $location[The Oasis]))
			{
				auto_log_warning("Could not visit the Oasis for some raisin, assuming desertExploration is incorrect.", "red");
				set_property("desertExploration", 0);
			}
		}
	}
	return true;
}

boolean L11_wishForBaaBaaBuran()
{
	if (!canGenieCombat() || canEat($item[fortune cookie]))
	{
		return false;
	}
	if(!get_property("auto_useWishes").to_boolean())
	{
		auto_log_warning("Skipping wishing for Baa'baa'bu'ran because auto_useWishes=false", "red");
	}
	else
	{
		auto_log_info("I'm sorry we don't already have stone wool. You might even say I'm sheepish. Sheep wish.", "blue");
		handleFamiliar("item");
		if((numeric_modifier("item drop") >= 100))
		{
			if (!makeGenieCombat($monster[Baa\'baa\'bu\'ran]) || item_amount($item[Stone Wool]) == 0)
			{
				auto_log_warning("Wishing for stone wool failed.", "red");
				return false;
			}
			return true;
		}
		else
		{
			auto_log_warning("Never mind, we couldn't get a mere +100% item for the Baa'baa'bu'ran wish.", "red");
		}
	}
	return false;
}

boolean L11_unlockHiddenCity() {
	if (!hidden_temple_unlocked() || internalQuestStatus("questL11Worship") < 0 || internalQuestStatus("questL11Worship") > 2) {
		return false;
	}
	if (my_adventures() - auto_advToReserve() <= 3) {
		return false;
	}

	auto_log_info("Searching for the Hidden City", "blue");
	if (auto_my_path() != "G-Lover" && !in_tcrs()) {
		if (item_amount($item[Stone Wool]) == 0 && have_effect($effect[Stone-Faced]) == 0) {
			L11_wishForBaaBaaBuran();
			pullXWhenHaveY($item[Stone Wool], 1, 0);
		}
		buffMaintain($effect[Stone-Faced], 0, 1, 1);
		if (have_effect($effect[Stone-Faced]) == 0) {
			if(isAboutToPowerlevel())	//we ran out of other things to do.
			{
				abort("We do not smell like Stone nor have the face of one. We currently donut farm Stone Wool. Please get some");
			}
			else return false;	//try to do other things first.
		}
	}
	return autoAdv($location[The Hidden Temple]);
}

void hiddenTempleChoiceHandler(int choice, string page) {
	if (choice == 123) { // At Least It's Not Full Of Trash
		run_choice(2); // Go to Beginning at the Beginning of Beginning
		visit_url("choice.php");
		cli_execute("dvorak"); // Solve puzzle and go to No Visible Means of Support (#125)
	} else if (choice == 125) { // No Visible Means of Support
		run_choice(3); // Unlock the Hidden City!
	} else if (choice == 579) { // Such Great Heights
		if (item_amount($item[The Nostril of the Serpent]) == 0 && internalQuestStatus("questL11Worship") < 3) {
			run_choice(2); // Get The Nostril of the Serpent
		} else {
			run_choice(3); // +3 adventures and extend 10 effects (first time) or skip
		}
	} else if (choice == 580) { // The Hidden Heart of the Hidden Temple
		if (!page.contains_text("The door is decorated with that little lightning-tailed guy from your father's diary.")) {
			run_choice(2); // Go to Unconfusing Buttons (#584) or Confusing Buttons (#583)
		} else {
			run_choice(1); // Go to At Least It's Not Full Of Trash (#123)
		}
	} else if (choice == 581) { // Such Great Depths
		run_choice(3); // Fight the Clan of cave bars
	} else if (choice == 582) { // Fitting In
		if (item_amount($item[The Nostril of the Serpent]) > 0 && internalQuestStatus("questL11Worship") < 3) {
				run_choice(2); // Go to The Hidden Heart of the Hidden Temple (#580)
		} else {
			run_choice(1); // Go to Such Great Heights (#579)
		}
	} else if (choice == 583) { // Confusing Buttons
		run_choice(1); // Randomly changes The Hidden Heart of the Hidden Temple
	} else if (choice == 584) { // Unconfusing Buttons
		run_choice(4); // Go to The Hidden Heart of the Hidden Temple (Pikachutlotal) (#580)
	} else {
		abort("unhandled choice in hiddenTempleChoiceHandler");
	}
}

boolean L11_hiddenTavernUnlock()
{
	return L11_hiddenTavernUnlock(false);
}

boolean L11_hiddenTavernUnlock(boolean force)
{
	if(!auto_is_valid($item[Book of Matches]))
	{
		return false;
	}

	if(my_ascensions() == get_property("hiddenTavernUnlock").to_int())
	{
		return true;
	}

	if(force)
	{
		if(!in_hardcore())
		{
			pullXWhenHaveY($item[Book of Matches], 1, 0);
		}
	}

	if(my_ascensions() > get_property("hiddenTavernUnlock").to_int())
	{
		if(item_amount($item[Book of Matches]) > 0)
		{
			use(1, $item[Book of Matches]);
			return true;
		}
		return false;
	}
	return true;
}

boolean L11_hiddenCity()
{
	if (internalQuestStatus("questL11Worship") < 3 || internalQuestStatus("questL11Worship") > 4)
	{
		return false;
	}

	if(item_amount($item[[2180]Ancient Amulet]) == 1)
	{
		return true;
	}
	else if (item_amount($item[[7963]Ancient Amulet]) == 0 && isActuallyEd())
	{
		return true;
	}

	if (internalQuestStatus("questL11Curses") > 1 || item_amount($item[Moss-Covered Stone Sphere]) > 0)
	{
		uneffect($effect[Thrice-Cursed]);
	}



	if (item_amount($item[Moss-Covered Stone Sphere]) == 0 && internalQuestStatus("questL11Business") < 1)
	{
		if(get_counters("Fortune Cookie", 0, 9) == "Fortune Cookie")
		{
			return false;
		}
	}

	if (internalQuestStatus("questL11Curses") < 2 && get_counters("Fortune Cookie", 0, 9) != "Fortune Cookie" && have_effect($effect[Ancient Fortitude]) == 0)
	{
		auto_log_info("The idden [sic] apartment!", "blue");

		boolean elevatorAction = ($location[The Hidden Apartment Building].turns_spent > 0 && $location[The Hidden Apartment Building].turns_spent % 8 == 0);

		if(auto_canForceNextNoncombat())
		{
			if((my_ascensions() == get_property("hiddenTavernUnlock").to_int() && (inebriety_left() >= 3*$item[Cursed Punch].inebriety) && !in_tcrs())
				|| (0 != have_effect($effect[Thrice-Cursed]) && $location[The Hidden Apartment Building].turns_spent <= 4))
			{
				elevatorAction = auto_forceNextNoncombat();

				if(in_pokefam())
				{
					if(get_property("relocatePygmyLawyer").to_int() != my_ascensions())
					{
						return autoAdv($location[The Hidden Apartment Building]);
					}
				}
			}
		}

		if(!elevatorAction)
		{
			auto_log_info("Hidden Apartment Progress: " + get_property("hiddenApartmentProgress"), "blue");
			return autoAdv($location[The Hidden Apartment Building]);
		}
		else
		{
			if(have_effect($effect[Thrice-Cursed]) == 0)
			{
				L11_hiddenTavernUnlock(true);
				while(have_effect($effect[Thrice-Cursed]) == 0 && inebriety_left() >= $item[Cursed Punch].inebriety && canDrink($item[Cursed Punch]) && my_ascensions() == get_property("hiddenTavernUnlock").to_int() && !in_tcrs())
				{
					buyUpTo(1, $item[Cursed Punch]);
					if(item_amount($item[Cursed Punch]) == 0)
					{
						abort("Could not acquire Cursed Punch, unable to deal with Hidden Apartment Properly");
					}
					autoDrink(1, $item[Cursed Punch]);
				}
			}
			auto_log_info("Hidden Apartment Progress: " + get_property("hiddenApartmentProgress"), "blue");
			return autoAdv($location[The Hidden Apartment Building]);
		}
	}

	if (internalQuestStatus("questL11Business") < 2 && my_adventures() >= 11)
	{
		auto_log_info("The idden [sic] office!", "blue");

		if (creatable_amount($item[McClusky file (complete)]) > 0) {
			create(1, $item[McClusky file (complete)]);
		}

		boolean workingHoliday = ($location[The Hidden Office Building].turns_spent > 0 && $location[The Hidden Office Building].turns_spent % 5 == 0);

		if (!workingHoliday && item_amount($item[McClusky file (complete)]) > 0 && auto_canForceNextNoncombat()) {
			auto_forceNextNoncombat();
		}

		auto_log_info("Hidden Office Progress: " + get_property("hiddenOfficeProgress"), "blue");
		return autoAdv($location[The Hidden Office Building]);
	}

	if (internalQuestStatus("questL11Spare") < 2)
	{
		auto_log_info("The idden [sic] bowling alley!", "blue");
		L11_hiddenTavernUnlock(true);
		if(my_ascensions() == get_property("hiddenTavernUnlock").to_int())
		{
			if(item_amount($item[Bowl Of Scorpions]) == 0)
			{
				buyUpTo(1, $item[Bowl Of Scorpions]);
				if(auto_my_path() == "One Crazy Random Summer")
				{
					buyUpTo(3, $item[Bowl Of Scorpions]);
				}
			}
		}

		buffMaintain($effect[Fishy Whiskers], 0, 1, 1);
		auto_log_info("Hidden Bowling Alley Progress: " + get_property("hiddenBowlingAlleyProgress"), "blue");
		if (canSniff($monster[Pygmy Bowler], $location[The Hidden Bowling Alley]) && auto_mapTheMonsters() && item_amount($item[bowling ball]) < 1)
		{
			auto_log_info("Attemping to use Map the Monsters to olfact a Pygmy Bowler.");
		}
		if (auto_canCamelSpit() && get_property("hiddenBowlingAlleyProgress").to_int() < 2)
		{
			auto_log_info("Bringing the Camel to spit on a Pygmy Bowler for bowling balls.");
			handleFamiliar($familiar[Melodramedary]);
		}
		return autoAdv($location[The Hidden Bowling Alley]);
	}

	if (internalQuestStatus("questL11Doctor") < 2)
	{
		if(item_amount($item[Dripping Stone Sphere]) > 0)
		{
			return true;
		}
		auto_log_info("The idden osptial!! [sic]", "blue");

		autoEquip($item[bloodied surgical dungarees]);
		autoEquip($item[half-size scalpel]);
		autoEquip($item[surgical apron]);
		autoEquip($slot[acc3], $item[head mirror]);
		autoEquip($slot[acc2], $item[surgical mask]);
		auto_log_info("Hidden Hospital Progress: " + get_property("hiddenHospitalProgress"), "blue");
		return autoAdv($location[The Hidden Hospital]);
	}

	if (item_amount($item[moss-covered stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Northwest)]);
	}

	if (item_amount($item[crackling stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Northeast)]);
	}

	if (item_amount($item[dripping stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Southwest)]);
	}

	if (item_amount($item[scorched stone sphere]) > 0) {
		auto_log_info("Getting the stone triangles", "blue");
		return autoAdv($location[An Overgrown Shrine (Southeast)]);
	}

	if (item_amount($item[stone triangle]) == 4) {
		auto_log_info("Fighting the out-of-work spirit", "blue");
		acquireHP();
		return autoAdv($location[A Massive Ziggurat]);
	}
	
	return false;
}

boolean L11_hiddenCityZones()
{
	if (internalQuestStatus("questL11Worship") < 3 || internalQuestStatus("questL11Worship") > 4)
	{
		return false;
	}

	boolean equipMachete()
	{
		if (auto_can_equip($item[Antique Machete]))
		{
			if (!possessEquipment($item[Antique Machete]))
			{
				pullXWhenHaveY($item[Antique Machete], 1, 0);
			}
			return autoForceEquip($item[Antique Machete]);
		}
		else
		{
			if (!possessEquipment($item[Muculent Machete]))
			{
				pullXWhenHaveY($item[Muculent Machete], 1, 0);
			}
			return autoForceEquip($item[Muculent Machete]);
		}
		return false;
	}

	L11_hiddenTavernUnlock();

	boolean needMachete = !possessEquipment($item[Antique Machete]);
	boolean needRelocate = (get_property("relocatePygmyJanitor").to_int() != my_ascensions());

	if (!in_hardcore() || in_boris() || auto_my_path() == "Way of the Surprising Fist" || in_pokefam())
	{
		needMachete = false;
	}

	if (needMachete || needRelocate) {
		if (handleFamiliar($familiar[Red-Nosed Snapper])) {
			auto_changeSnapperPhylum($phylum[dude]);
		}
		return autoAdv($location[The Hidden Park]);
	}

	if (get_property("hiddenApartmentProgress") == 0) {
		if (!equipMachete()) {
			return false;
		}
		return autoAdv($location[An Overgrown Shrine (Northwest)]);
	}

	if (get_property("hiddenOfficeProgress") == 0) {
		if (!equipMachete()) {
			return false;
		}
		return autoAdv($location[An Overgrown Shrine (Northeast)]);
	}

	if (get_property("hiddenHospitalProgress") == 0) {
		if (!equipMachete()) {
			return false;
		}
		return autoAdv($location[An Overgrown Shrine (Southwest)]);
	}

	if (get_property("hiddenBowlingAlleyProgress") == 0) {
		if (!equipMachete()) {
			return false;
		}
		return autoAdv($location[An Overgrown Shrine (Southeast)]);
	}

	if (!get_property("auto_openedziggurat").to_boolean()) {
		if (!equipMachete()) {
			return false;
		}
		boolean advSpent = autoAdv($location[A Massive Ziggurat]);
		if (get_property("lastEncounter") == "Legend of the Temple in the Hidden City" || (isActuallyEd() && get_property("lastEncounter") == "Temple of the Legend in the Hidden City")) {
			set_property("auto_openedziggurat", true);
		}
		return advSpent;
	}
	return false;
}

boolean L11_mauriceSpookyraven()
{
	if (internalQuestStatus("questL11Manor") < 0 || internalQuestStatus("questL11Manor") > 3 || internalQuestStatus("questM21Dance") < 4)
	{
		return false;
	}

	if ((isActuallyEd() && item_amount($item[7962]) == 0) || item_amount($item[2286]) > 0)
	{
		return true;
	}

	if (internalQuestStatus("questL11Manor") < 1)
	{
		auto_log_info("Searching for the basement of Spookyraven", "blue");
		if(!cangroundHog($location[The Haunted Ballroom]))
		{
			return false;
		}

		if (canBurnDelay($location[The Haunted Ballroom]))
		{
			// We'll All Be Flat choice adventure has a delay of 5 adventures.
			return false;
		}

		return autoAdv($location[The Haunted Ballroom]);
	}
	if(item_amount($item[recipe: mortar-dissolving solution]) == 0)
	{
		if(possessEquipment($item[Lord Spookyraven\'s Spectacles]))
		{
			equip($slot[acc3], $item[Lord Spookyraven\'s Spectacles]);
		}
		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		use(1, $item[recipe: mortar-dissolving solution]);
	}

	if (internalQuestStatus("questL11Manor") > 2)
	{
		auto_log_info("Down with the tyrant of Spookyraven!", "blue");
		acquireHP();
		int [element] resGoal;
		foreach ele in $elements[hot, cold, stench, sleaze, spooky]
		{
			resGoal[ele] = 3;
		}
		provideResistances(resGoal, false);

		# The autoAdvBypass case is probably suitable for Ed but we'd need to verify it.
		if (isActuallyEd())
		{
			visit_url("place.php?whichplace=manor4&action=manor4_chamberboss");
		}
		else
		{
			autoAdv($location[Summoning Chamber]);
		}
		return true;
	}

	if(!get_property("auto_haveoven").to_boolean())
	{
		ovenHandle();
	}

	if(item_amount($item[wine bomb]) == 1)
	{
		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		if (internalQuestStatus("questL11Manor") == 3)
		{
			return true;
		}
		else
		{
			abort("Tried to use the wine bomb but it somehow failed?");
		}
	}

	if(!possessEquipment($item[Lord Spookyraven\'s Spectacles]) || in_boris() || (auto_my_path() == "Way of the Surprising Fist") || in_bhy() || ((auto_my_path() == "Nuclear Autumn") && !get_property("auto_haveoven").to_boolean()))
	{
		auto_log_warning("Alternate fulminate pathway... how sad :(", "red");
		# I suppose we can let anyone in without the Spectacles.
		if(item_amount($item[Loosening Powder]) == 0)
		{
			autoAdv($location[The Haunted Kitchen]);
			return true;
		}
		if(item_amount($item[Powdered Castoreum]) == 0)
		{
			autoAdv($location[The Haunted Conservatory]);
			return true;
		}
		if(item_amount($item[Drain Dissolver]) == 0)
		{
			autoAdv($location[The Haunted Bathroom]);
			return true;
		}
		if(item_amount($item[Triple-Distilled Turpentine]) == 0)
		{
			autoAdv($location[The Haunted Gallery]);
			return true;
		}
		if(item_amount($item[Detartrated Anhydrous Sublicalc]) == 0)
		{
			autoAdv($location[The Haunted Laboratory]);
			return true;
		}
		if(item_amount($item[Triatomaceous Dust]) == 0)
		{
			autoAdv($location[The Haunted Storage Room]);
			return true;
		}

		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		return true;
	}

	if((item_amount($item[blasting soda]) == 1) && (item_amount($item[bottle of Chateau de Vinegar]) == 1))
	{
		auto_log_info("Time to cook up something explosive! Science fair unstable fulminate time!", "green");
		ovenHandle();
		autoCraft("cook", 1, $item[bottle of Chateau de Vinegar], $item[blasting soda]);
		if(item_amount($item[Unstable Fulminate]) == 0)
		{
			auto_log_warning("We could not make an Unstable Fulminate but we think we have an oven. Do this manually and resume?", "red");
			auto_log_warning("Speculating that get_campground() was incorrect at ascension start...", "red");
			// This issue is valid as of mafia r16799
			set_property("auto_haveoven", false);
			ovenHandle();
			autoCraft("cook", 1, $item[bottle of Chateau de Vinegar], $item[blasting soda]);
			if(item_amount($item[Unstable Fulminate]) == 0)
			{
				if(auto_my_path() == "Nuclear Autumn")
				{
					auto_log_warning("Could not make an Unstable Fulminate, assuming we have no oven for realz...", "red");
					return true;
				}
				else
				{
					abort("Could not make an Unstable Fulminate, make it manually and resume");
				}
			}
		}
	}

	if(get_property("spookyravenRecipeUsed") != "with_glasses")
	{
		abort("Did not read Mortar Recipe with the Spookyraven glasses. We can't proceed.");
	}

	if (item_amount($item[bottle of Chateau de Vinegar]) == 0 && !possessEquipment($item[Unstable Fulminate]) && internalQuestStatus("questL11Manor") < 3)
	{
		auto_log_info("Searching for vinegar", "blue");
		if(!bat_wantHowl($location[The Haunted Wine Cellar]))
		{
			bat_formBats();
		}
		if (canSniff($monster[Possessed Wine Rack], $location[The Haunted Wine Cellar]) && auto_mapTheMonsters())
		{
			auto_log_info("Attemping to use Map the Monsters to olfact a Possessed Wine Rack.");
		}
		return autoAdv($location[The Haunted Wine Cellar]);
	}
	if (item_amount($item[blasting soda]) == 0 && !possessEquipment($item[Unstable Fulminate]) && internalQuestStatus("questL11Manor") < 3)
	{
		auto_log_info("Searching for baking soda, I mean, blasting pop.", "blue");
		if(!bat_wantHowl($location[The Haunted Wine Cellar]))
		{
			bat_formBats();
		}
		if (canSniff($monster[Cabinet of Dr. Limpieza], $location[The Haunted Laundry Room]) && auto_mapTheMonsters())
		{
			auto_log_info("Attemping to use Map the Monsters to olfact a Cabinet of Dr. Limpieza.");
		}
		return autoAdv($location[The Haunted Laundry Room]);
	}

	if (possessEquipment($item[Unstable Fulminate]) && internalQuestStatus("questL11Manor") < 3)
	{
		auto_MaxMLToCap(auto_convertDesiredML(82), true);
		addToMaximize("500ml " + auto_convertDesiredML(82) + "max");

		if((auto_my_path() == "Picky") && (item_amount($item[gumshoes]) > 0))
		{
			auto_change_mcd(0);
			autoEquip($slot[acc2], $item[gumshoes]);
		}
		
		if(monster_level_adjustment() < 57)
		{
			buffMaintain($effect[Sweetbreads Flamb&eacute;], 0, 1, 1);
		}
		
		if(!autoForceEquip($slot[off-hand], $item[Unstable Fulminate]))
		{
			abort("Unstable Fulminate was not equipped. Please report this and include the following: Equipped items and if you have or don't have an Unstable Fulminate. For now, get the wine bomb manually, and run again.");
		}
		
		auto_log_info("Now we mix and heat it up.", "blue");
		return autoAdv($location[The Haunted Boiler Room]);
	}
	return false;
}

boolean L11_redZeppelin()
{
	if (internalQuestStatus("questL11Shen") < 8 && !isAboutToPowerlevel())
	{
		return false;
	}

	if (internalQuestStatus("questL11Ron") < 0 || internalQuestStatus("questL11Ron") > 1)
	{
		return false;
	}

	if(internalQuestStatus("questL11Ron") == 0)
	{
		return autoAdv($location[A Mob Of Zeppelin Protesters]);
	}

	// TODO: create lynyrd skin items

	set_property("choiceAdventure856", 1);
	set_property("choiceAdventure857", 1);
	set_property("choiceAdventure858", 1);
	buffMaintain($effect[Greasy Peasy], 0, 1, 1);
	buffMaintain($effect[Musky], 0, 1, 1);
	buffMaintain($effect[Blood-Gorged], 0, 1, 1);
	pullXWhenHaveY($item[deck of lewd playing cards], 1, 0);

	if(item_amount($item[Flamin\' Whatshisname]) > 0)
	{
		backupSetting("choiceAdventure866", 3);
	}
	else
	{
		backupSetting("choiceAdventure866", 2);
	}

	addToMaximize("100sleaze damage,100sleaze spell damage");
	auto_beachCombHead("sleaze");
	foreach it in $items[lynyrdskin breeches, lynyrdskin cap, lynyrdskin tunic]
	{
		if(possessEquipment(it) && auto_can_equip(it) &&
		   (numeric_modifier(equipped_item(to_slot(it)), "sleaze damage") < 5) &&
		   (numeric_modifier(equipped_item(to_slot(it)), "sleaze spell damage") < 5))
		{
			autoEquip(it);
		}
	}

	if(auto_is_valid($item[lynyrd snare]) && item_amount($item[lynyrd snare]) > 0 && get_property("_lynyrdSnareUses").to_int() < 3 && my_hp() > 150)
	{
		return autoAdvBypass("inv_use.php?pwd=&whichitem=7204&checked=1", $location[A Mob of Zeppelin Protesters]);
	}

	if(cloversAvailable() > 0 && get_property("zeppelinProtestors").to_int() < 75)
	{
		if(cloversAvailable() >= 3 && get_property("auto_useWishes").to_boolean())
		{
			makeGenieWish($effect[Fifty Ways to Bereave Your Lover]); // +100 sleaze dmg
			makeGenieWish($effect[Dirty Pear]); // double sleaze dmg
		}
		if(in_tcrs())
		{
			if(my_class() == $class[Sauceror] && my_sign() == "Blender")
			{
				if (0 == have_effect($effect[Improprie Tea]))
				{
					buyUpTo(1, $item[Ben-Gal&trade; Balm], 25);
					use(1, $item[Ben-Gal&trade; Balm]);
				}
			}
		}
		float fire_protestors = item_amount($item[Flamin\' Whatshisname]) > 0 ? 10 : 3;
		float sleaze_amount = numeric_modifier("sleaze damage") + numeric_modifier("sleaze spell damage");
		float sleaze_protestors = square_root(sleaze_amount);
		float lynyrd_protestors = have_effect($effect[Musky]) > 0 ? 6 : 3;
		foreach it in $items[lynyrdskin cap, lynyrdskin tunic, lynyrdskin breeches]
		{
			if (possessEquipment(it) && can_equip(it)) {
				lynyrd_protestors += 5;
			}
		}
		auto_log_info("Hiding in the bushes: " + lynyrd_protestors, "blue");
		auto_log_info("Going to a bench: " + sleaze_protestors, "blue");
		auto_log_info("Heading towards the flames" + fire_protestors, "blue");
		float best_protestors = max(fire_protestors, max(sleaze_protestors, lynyrd_protestors));
		if(best_protestors >= 10)
		{
			if(best_protestors == lynyrd_protestors)
			{
				foreach it in $items[lynyrdskin cap, lynyrdskin tunic, lynyrdskin breeches]
				{
					autoEquip(it);
				}
				set_property("choiceAdventure866", 1);
			}
			else if(best_protestors == sleaze_protestors)
			{
				set_property("choiceAdventure866", 2);
			}
			else if (best_protestors == fire_protestors)
			{
				set_property("choiceAdventure866", 3);
			}
			cloverUsageInit();
			boolean retval = autoAdv(1, $location[A Mob of Zeppelin Protesters]);
			cloverUsageFinish();
			return retval;
		}
	}

	if (handleFamiliar($familiar[Red-Nosed Snapper])) {
		auto_changeSnapperPhylum($phylum[dude]);
	}

	int lastProtest = get_property("zeppelinProtestors").to_int();
	if (canSniff($monster[Blue Oyster Cultist], $location[A Mob Of Zeppelin Protesters]) && auto_mapTheMonsters())
	{
		auto_log_info("Attemping to use Map the Monsters to olfact a Blue Oyster Cultist.");
	}
	boolean retval = autoAdv($location[A Mob Of Zeppelin Protesters]);
	if(!lastAdventureSpecialNC())
	{
		if(lastProtest == get_property("zeppelinProtestors").to_int())
		{
			set_property("zeppelinProtestors", get_property("zeppelinProtestors").to_int() + 1);
		}
	}
	else
	{
		set_property("lastEncounter", "Clear Special NC");
	}
	restoreSetting("choiceAdventure866");
	set_property("choiceAdventure856", 2);
	set_property("choiceAdventure857", 2);
	set_property("choiceAdventure858", 2);
	return retval;
}


boolean L11_ronCopperhead()
{
	if (internalQuestStatus("questL11Ron") < 2 || internalQuestStatus("questL11Ron") > 4)
	{
		return false;
	}


	if (internalQuestStatus("questL11Ron") > 1 && internalQuestStatus("questL11Ron") < 5)
	{
		if (item_amount($item[Red Zeppelin Ticket]) < 1)
		{
			// use the priceless diamond since we go to the effort of trying to get one in the Copperhead Club
			// and it saves us 4.5k meat.
			if (item_amount($item[priceless diamond]) > 0)
			{
				buy($coinmaster[The Black Market], 1, $item[Red Zeppelin Ticket]);
			}
			else if (my_meat() > npc_price($item[Red Zeppelin Ticket]))
			{
				buy(1, $item[Red Zeppelin Ticket]);
			}
		}
		// For Glark Cables. OPTIMAL!
		bat_formBats();
		if (canSniff($monster[Red Butler], $location[The Red Zeppelin]) && auto_mapTheMonsters())
		{
			auto_log_info("Attemping to use Map the Monsters to olfact a Red Butler.");
		}
		if (auto_canCamelSpit())
		{
			auto_log_info("Bringing the Camel to spit on a Red Butler for glark cables.");
			handleFamiliar($familiar[Melodramedary]);
		}
		boolean retval = autoAdv($location[The Red Zeppelin]);
		// open red boxes when we get them (not sure if this is the place for this but it'll do for now)
		if (item_amount($item[red box]) > 0)
		{
			use (item_amount($item[red box]), $item[red box]);
		}
		return retval;
	}

	if (internalQuestStatus("questL11Ron") < 5)
	{
		abort("Ron should be done with but tracking is not complete!");
	}

	// Copperhead Charm (rampant) autocreated successfully
	return false;
}

boolean L11_shenStartQuest()
{
	// as the first adventure in the Copperhead Club is always the first Shen NC
	// we can adventure there once as soon as it's open to start the quest and lock in
	// our zones
	if (internalQuestStatus("questL11Shen") != 0)
	{
		return false;
	}
	if (my_daycount() < 2 || !allowSoftblockShen())
	{
		// if you're fast enough to open it on day 1, maybe wait until day 2
		return false;
	}
	backupSetting("choiceAdventure1074", 1);
	auto_log_info("Going to see the World's Biggest Jerk about some snakes and stones and stuff.", "blue");
	if (autoAdv($location[The Copperhead Club]))
	{
		if (internalQuestStatus("questL11Shen") == 1)
		{
			auto_log_info("It seems Shen has given us a quest.", "blue");
			auto_log_info("I am going to avoid the following zones until Shen tells me to go there or until I run out of other things to do:");
			int linec = 1;
			foreach z, _ in shenZonesToAvoidBecauseMaybeSnake() {
				auto_log_info(linec++ + ". " + z);
				set_property("auto_shenZonesTurnsSpent", `{get_property("auto_shenZonesTurnsSpent")}{z}:{z.turns_spent};`);
			}
			set_property("auto_lastShenTurn", $location[The Copperhead Club].turns_spent);
		}
		return true;
	}
	return false;
}

boolean L11_shenCopperhead()
{
	if (internalQuestStatus("questL11Shen") < 0 || internalQuestStatus("questL11Shen") > 7)
	{
		return false;
	}

	if (L11_shenStartQuest()) {
		return true;
	}

	if (internalQuestStatus("questL11Shen") < 1) {
		// if we haven't spoke to Shen for the first time yet, don't try to handle the quest.
		return false;
	}

	if (internalQuestStatus("questL11Shen") == 2 || internalQuestStatus("questL11Shen") == 4 || internalQuestStatus("questL11Shen") == 6)
	{
		if (item_amount($item[Crappy Waiter Disguise]) > 0 && have_effect($effect[Crappily Disguised as a Waiter]) == 0 && !in_tcrs())
		{
			use(1, $item[Crappy Waiter Disguise]);

			// default to getting unnamed cocktails to turn into Flamin' Whatsisnames.
			int behindtheStacheOption = 4;
			if (item_amount($item[priceless diamond]) > 0 || item_amount($item[Red Zeppelin Ticket]) > 0 || my_meat() > 10000 ||  (internalQuestStatus("questL11Shen") == 6 && item_amount($item[unnamed cocktail]) > 0))
			{
				if (get_property("copperheadClubHazard") != "lantern")
				{
					// got priceless diamond or zeppelin ticket (or we are rich) so lets burn the place down (and make Flamin' Whatsisnames)
					behindtheStacheOption = 3;
				}
			}
			else
			{
				if (get_property("copperheadClubHazard") != "ice")
				{
					// knock over the ice bucket & try for the priceless diamond.
					behindtheStacheOption = 2;
				}
			}
			set_property("choiceAdventure855", behindtheStacheOption);
		}

		if (handleFamiliar($familiar[Red-Nosed Snapper])) {
			auto_changeSnapperPhylum($phylum[dude]);
		}

		addToMaximize("-10ml");
		if (autoAdv($location[The Copperhead Club]))
		{
			if (get_property("lastEncounter").contains_text("Shen Copperhead, "))
			{
				set_property("auto_lastShenTurn", $location[The Copperhead Club].turns_spent);
			}
			return true;
		}
		return false;
	}

	if((internalQuestStatus("questL11Shen") == 1) || (internalQuestStatus("questL11Shen") == 3) || (internalQuestStatus("questL11Shen") == 5))
	{
		item it = to_item(get_property("shenQuestItem"));
		if (it == $item[none] && isActuallyEd())
		{
			// temp workaround until mafia bug is fixed - https://kolmafia.us/showthread.php?23742
			cli_execute("refresh quests");
			it = to_item(get_property("shenQuestItem"));
		}
		location goal = $location[none];
		switch(it)
		{
		case $item[The Stankara Stone]:					goal = $location[The Batrat and Ratbat Burrow];						break;
		case $item[The First Pizza]:					goal = $location[Lair of the Ninja Snowmen];						break;
		case $item[Murphy\'s Rancid Black Flag]:		goal = $location[The Castle in the Clouds in the Sky (Top Floor)];	break;
		case $item[The Eye of the Stars]:				goal = $location[The Hole in the Sky];								break;
		case $item[The Lacrosse Stick of Lacoronado]:	goal = $location[The Smut Orc Logging Camp];						break;
		case $item[The Shield of Brook]:				goal = $location[The Unquiet Garves];							break;
		}
		if(goal == $location[none])
		{
			abort("Could not parse Shen event");
		}

		if(!zone_isAvailable(goal))
		{
			// handle paths which don't need Tower keys but the World's Biggest Jerk asks for The Eye of the Stars
			if (goal == $location[The Hole in the Sky])
			{
				if (!get_property("auto_holeinthesky").to_boolean())
				{
					set_property("auto_holeinthesky", true);
				}
				return (L10_topFloor() || L10_holeInTheSkyUnlock());
			}
			return false;
		}
		else
		{
			// If we haven't completed the top floor, try to complete it.
			if (goal == $location[The Castle in the Clouds in the Sky (Top Floor)] && (L10_topFloor() || L10_holeInTheSkyUnlock()))
			{
				return true;
			}
			else if (goal == $location[The Smut Orc Logging Camp] && (L9_ed_chasmStart() || L9_chasmBuild()))
			{
				return true;
			}

			if (canBurnDelay(goal))
			{
				// Snakes have variable delay of 3-5 adventures but we can burn at least 3 of that.
				return false;
			}

			return autoAdv(goal);
		}
	}

	if (internalQuestStatus("questL11Shen") < 8)
	{
		abort("Shen should be done with but tracking is not complete! Status: " + get_property("questL11Shen"));
	}

	//Now have a Copperhead Charm
	return false;
}

boolean L11_talismanOfNam()
{
	if(L11_shenCopperhead() || L11_redZeppelin() || L11_ronCopperhead())
	{
		return true;
	}
	if(creatable_amount($item[Talisman O\' Namsilat]) > 0)
	{
		if(create(1, $item[Talisman O\' Namsilat]))
		{
			return true;
		}
	}

	return false;
}

boolean L11_palindome()
{
	if (internalQuestStatus("questL11Palindome") < 0 || internalQuestStatus("questL11Palindome") > 5)
	{
		return false;
	}

	if (!possessEquipment($item[Talisman o' Namsilat])) {
		return false;
	}

	int total = 0;
	total = total + item_amount($item[Photograph Of A Red Nugget]);
	total = total + item_amount($item[Photograph Of An Ostrich Egg]);
	total = total + item_amount($item[Photograph Of God]);
	total = total + item_amount($item[Photograph Of A Dog]);

	boolean lovemeDone = hasILoveMeVolI() || (internalQuestStatus("questL11Palindome") >= 1);
	if(!lovemeDone && (get_property("palindomeDudesDefeated").to_int() >= 5))
	{
		string palindomeCheck = visit_url("place.php?whichplace=palindome");
		lovemeDone = lovemeDone || contains_text(palindomeCheck, "pal_drlabel");
	}

	auto_log_info("In the palindome : emodnilap eht nI", "blue");
	#
	#	In hardcore, guild-class, the right side of the or doesn't happen properly due us farming the
	#	Mega Gem within the if, with pulls, it works fine. Need to fix this. This is bad.
	#
	if((item_amount($item[Bird Rib]) > 0) && (item_amount($item[Lion Oil]) > 0) && (item_amount($item[Wet Stew]) == 0))
	{
		autoCraft("cook", 1, $item[Bird Rib], $item[Lion Oil]);
	}
	if((item_amount($item[Stunt Nuts]) > 0) && (item_amount($item[Wet Stew]) > 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0))
	{
		autoCraft("cook", 1, $item[wet stew], $item[stunt nuts]);
	}

	if((item_amount($item[Wet Stunt Nut Stew]) > 0) && !possessEquipment($item[Mega Gem]))
	{
		if(equipped_amount($item[Talisman o\' Namsilat]) == 0)
			equip($slot[acc3], $item[Talisman o\' Namsilat]);
		visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
	}

	if((total == 0) && !possessEquipment($item[Mega Gem]) && lovemeDone && in_hardcore() && (item_amount($item[Wet Stunt Nut Stew]) == 0) && ((internalQuestStatus("questL11Palindome") >= 3) || isGuildClass()) && !get_property("auto_bruteForcePalindome").to_boolean())
	{
		if(item_amount($item[Wet Stunt Nut Stew]) == 0)
		{
			equipBaseline();
			if((item_amount($item[Bird Rib]) == 0) || (item_amount($item[Lion Oil]) == 0))
			{
				if(item_amount($item[white page]) > 0)
				{
					set_property("choiceAdventure940", 1);
					if(item_amount($item[Bird Rib]) > 0)
					{
						set_property("choiceAdventure940", 2);
					}

					if(get_property("lastGuildStoreOpen").to_int() < my_ascensions())
					{
						auto_log_warning("This is probably no longer needed as of r16907. Please remove me", "blue");
						auto_log_warning("Going to pretend we have unlocked the Guild because Mafia will assume we need to do that before going to Whitey's Grove and screw up us. We'll fix it afterwards.", "red");
					}
					backupSetting("lastGuildStoreOpen", my_ascensions());
					string[int] pages;
					pages[0] = "inv_use.php?pwd&which=3&whichitem=7555";
					pages[1] = "choice.php?pwd&whichchoice=940&option=" + get_property("choiceAdventure940");
					if(autoAdvBypass(0, pages, $location[Whitey\'s Grove], "")) {}
					restoreSetting("lastGuildStoreOpen");
					return true;
				}
				// +item is nice to get that food
				bat_formBats();
				auto_log_info("Off to the grove for some doofy food!", "blue");
				autoAdv(1, $location[Whitey\'s Grove]);
			}
			else if(item_amount($item[Stunt Nuts]) == 0)
			{
				auto_log_info("We got no nuts!! :O", "Blue");
				autoEquip($slot[acc3], $item[Talisman o\' Namsilat]);
				autoAdv(1, $location[Inside the Palindome]);
			}
			else
			{
				abort("Some sort of Wet Stunt Nut Stew error. Try making it yourself?");
			}
			return true;
		}
	}
	if((((total == 4) && hasILoveMeVolI()) || ((total == 0) && possessEquipment($item[Mega Gem]))) && loveMeDone)
	{
		if(hasILoveMeVolI())
		{
			useILoveMeVolI();
		}
		if (equipped_amount($item[Talisman o\' Namsilat]) == 0)
			equip($slot[acc3], $item[Talisman o\' Namsilat]);
		visit_url("place.php?whichplace=palindome&action=pal_drlabel");
		visit_url("choice.php?pwd&whichchoice=872&option=1&photo1=2259&photo2=7264&photo3=7263&photo4=7265");

		if (isActuallyEd())
		{
			return true;
		}


		# is step 4 when we got the wet stunt nut stew?
		if (internalQuestStatus("questL11Palindome") < 5)
		{
			if(item_amount($item[&quot;2 Love Me\, Vol. 2&quot;]) > 0)
			{
				use(1, $item[&quot;2 Love Me\, Vol. 2&quot;]);
				auto_log_info("Oh no, we died from reading a book. I'm going to take a nap.", "blue");
				acquireHP();
				bat_reallyPickSkills(20);
			}
			if (equipped_amount($item[Talisman o\' Namsilat]) == 0)
				equip($slot[acc3], $item[Talisman o\' Namsilat]);
			visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
			if(!in_hardcore() && (item_amount($item[Wet Stunt Nut Stew]) == 0))
			{
				if((item_amount($item[Wet Stew]) == 0) && (item_amount($item[Mega Gem]) == 0))
				{
					pullXWhenHaveY($item[Wet Stew], 1, 0);
				}
				if((item_amount($item[Stunt Nuts]) == 0) && (item_amount($item[Mega Gem]) == 0))
				{
					pullXWhenHaveY($item[Stunt Nuts], 1, 0);
				}
			}
			if(in_hardcore() && isGuildClass())
			{
				return true;
			}
		}

		if((item_amount($item[Bird Rib]) > 0) && (item_amount($item[Lion Oil]) > 0) && (item_amount($item[Wet Stew]) == 0))
		{
			autoCraft("cook", 1, $item[Bird Rib], $item[Lion Oil]);
		}

		if((item_amount($item[Stunt Nuts]) > 0) && (item_amount($item[Wet Stew]) > 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0))
		{
			autoCraft("cook", 1, $item[wet stew], $item[stunt nuts]);
		}

		if(!possessEquipment($item[Mega Gem]))
		{
			if (equipped_amount($item[Talisman o\' Namsilat]) == 0)
				equip($slot[acc3], $item[Talisman o\' Namsilat]);
			visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
		}

		if(!possessEquipment($item[Mega Gem]))
		{
			auto_log_warning("No mega gem for us. Well, no raisin to go further here....", "red");
			return false;
		}
		autoEquip($slot[acc2], $item[Mega Gem]);
		autoEquip($slot[acc3], $item[Talisman o\' Namsilat]);
		int palinChoice = random(3) + 1;
		set_property("choiceAdventure131", palinChoice);

		auto_log_info("War sir is raw!!", "blue");

		string[int] pages;
		pages[0] = "place.php?whichplace=palindome&action=pal_drlabel";
		pages[1] = "choice.php?pwd&whichchoice=131&option=" + palinChoice;
		autoAdvBypass(0, pages, $location[Noob Cave], "");
		return true;
	}
	else
	{
		if((my_mp() > 60) || considerGrimstoneGolem(true))
		{
			handleBjornify($familiar[Grimstone Golem]);
		}
		if (internalQuestStatus("questL11Palindome") > 1)
		{
			if(!get_property("auto_bruteForcePalindome").to_boolean())
			{
				auto_log_critical("Palindome failure:", "red");
				auto_log_critical("You probably just need to get a Mega Gem to fix this.", "red");
				abort("We have made too much progress in the Palindome and should not be here.");
			}
			else
			{
				auto_log_critical("We need wet stunt nut stew to get the Mega Gem, but I've been told to get it via the mercy adventure.", "red");
				auto_log_critical("Set auto_bruteForcePalindome=false to try to get a stunt nut stew", "red");
				auto_log_critical("(We typically only set this option in hardcore Kingdom of Exploathing, in which the White Forest isn't available)", "red");
			}
		}

		autoEquip($slot[acc3], $item[Talisman o\' Namsilat]);
		if (handleFamiliar($familiar[Red-Nosed Snapper]))
		{
			auto_changeSnapperPhylum($phylum[dude]);
		}
		if (canSniff($monster[Bob Racecar], $location[Inside the Palindome]) && auto_mapTheMonsters())
		{
			auto_log_info("Attemping to use Map the Monsters to olfact a Bob Racecar.");
		}
		boolean advSpent = autoAdv($location[Inside the Palindome]);
		if(($location[Inside the Palindome].turns_spent > 30) && !in_pokefam() && (auto_my_path() != "G-Lover") && !in_koe())
		{
			abort("It appears that we've spent too many turns in the Palindome. If you run me again, I'll try one more time but many I failed finishing the Palindome");
		}
		else
		{
			return advSpent;
		}
	}
	return false;
}

boolean L11_unlockPyramid()
{
  if (internalQuestStatus("questL11Desert") < 1 || get_property("desertExploration").to_int() < 100 || internalQuestStatus("questL11Pyramid") > -1)
	{
		return false;
	}
	if (isActuallyEd())
	{
		return false;	//ed starts with pyramid unlocked and cannot adventure there
	}
	//get staff of ed if possible. we are only checking the non equipment version of it.
	//the equipment version is actually ed the undying path exclusive
	if(creatable_amount($item[[2325]Staff Of Ed]) > 0)
	{
		create(1, $item[[2325]Staff Of Ed]);
	}
	if(item_amount($item[[2325]Staff Of Ed]) == 0)
	{
		return false;
	}
	
	auto_log_info("Reveal the pyramid", "blue");
	if (in_koe())
	{
		visit_url("place.php?whichplace=exploathing_beach&action=expl_pyramidpre");
		cli_execute("refresh quests");
	}
	else
	{
		visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
	}

	//check results of above URL visit
	if (internalQuestStatus("questL11Pyramid") > -1)
	{
		return true;	//unlock successful
	}
	else 		//unlock failed
	{
		cli_execute("refresh quests");		//maybe it worked and mafia did not notice?
		if(internalQuestStatus("questL11Pyramid") > -1)
		{
			return true;		//actually unlock did not fail.
		}
	
		int initial = get_property("desertExploration").to_int();
		string page = visit_url("place.php?whichplace=desertbeach");
		matcher desert_matcher = create_matcher("title=\"[(](\\d+)% explored[)]\"", page);
		if(desert_matcher.find())
		{
			int found = to_int(desert_matcher.group(1));
			if(found != initial)
			{
				auto_log_info("Incorrectly had exploration value of " + initial + " when it should be at " + found + ". This was corrected. Trying to resume.", "blue");
				set_property("desertExploration", found);
				return true;
			}
			abort("Tried to open the Pyramid but could not. property desertExploration determined to be correct");
		}
		abort("Tried to open the Pyramid but could not. could not verify the actual exploration amount of the desert");
	}
	
	return false;
}

boolean L11_unlockEd()
{
	if (internalQuestStatus("questL11Pyramid") < 0 || internalQuestStatus("questL11Pyramid") > 3 || get_property("pyramidBombUsed").to_boolean())
	{
		return false;
	}
	if (isActuallyEd())
	{
		return true;
	}

	if (internalQuestStatus("questL03Rat") < 2)
	{
		auto_log_warning("Uh oh, didn\'t do the tavern and we are at the pyramid....", "red");

		// Forcing Tavern.
		set_property("auto_forceTavern", true);
		return false;
	}

	auto_log_info("In the pyramid (W:" + item_amount($item[crumbling wooden wheel]) + ") (R:" + item_amount($item[tomb ratchet]) + ") (U:" + get_property("controlRoomUnlock") + ")", "blue");

	if(!get_property("middleChamberUnlock").to_boolean())
	{
		autoAdv(1, $location[The Upper Chamber]);
		return true;
	}

	int total = item_amount($item[Crumbling Wooden Wheel]);
	total = total + item_amount($item[Tomb Ratchet]);

	if((total >= 10) && (my_adventures() >= 4) && get_property("controlRoomUnlock").to_boolean())
	{
		if (get_counters("Fortune Cookie", 0, 3) == "Fortune Cookie")
		{
			return false;
		}

		visit_url("place.php?whichplace=pyramid&action=pyramid_control");
		int x = 0;
		while(x < 10)
		{
			if(item_amount($item[crumbling wooden wheel]) > 0)
			{
				visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
			}
			else
			{
				visit_url("choice.php?whichchoice=929&option=2&pwd");
			}
			x = x + 1;
			if((x == 3) || (x == 7) || (x == 10))
			{
				visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
			}
			if((x == 3) || (x == 7))
			{
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
			}
		}
		return true;
	}
	if(total < 10)
	{
		buffMaintain($effect[Joyful Resolve], 0, 1, 1);
		buffMaintain($effect[One Very Clear Eye], 0, 1, 1);
		buffMaintain($effect[Fishy Whiskers], 0, 1, 1);
		buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
		buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
		buffMaintain($effect[Unusual Perspective], 0, 1, 1);
		if(!bat_wantHowl($location[The Middle Chamber]))
		{
			bat_formBats();
		}
		if(get_property("auto_dickstab").to_boolean())
		{
			buffMaintain($effect[Wet and Greedy], 0, 1, 1);
			buffMaintain($effect[Frosty], 0, 1, 1);
		}
		if((item_amount($item[possessed sugar cube]) > 0) && (have_effect($effect[Dance of the Sugar Fairy]) == 0))
		{
			cli_execute("make sugar fairy");
			buffMaintain($effect[Dance of the Sugar Fairy], 0, 1, 1);
		}
		if(have_effect($effect[items.enh]) == 0)
		{
			auto_sourceTerminalEnhance("items");
		}
	}

	if(get_property("controlRoomUnlock").to_boolean())
	{
		if(!contains_text(get_property("auto_banishes"), $monster[Tomb Servant]) && !contains_text(get_property("auto_banishes"), $monster[Tomb Asp]) && (get_property("olfactedMonster") != $monster[Tomb Rat]))
		{
			autoAdv(1, $location[The Upper Chamber]);
			return true;
		}
	}

	if (canSniff($monster[Tomb Rat], $location[The Middle Chamber]) && auto_mapTheMonsters())
	{
		auto_log_info("Attemping to use Map the Monsters to olfact a Tomb Rat.");
	}
	autoAdv(1, $location[The Middle Chamber]);
	return true;
}

boolean L11_defeatEd()
{
	if (internalQuestStatus("questL11Pyramid") != 3 || !get_property("pyramidBombUsed").to_boolean())
	{
		return false;
	}

	if (my_adventures() - auto_advToReserve() <= 7)
	{
		return false;
	}

	if (get_counters("Fortune Cookie", 0, 6) == "Fortune Cookie")
	{
		return false;
	}

	if(item_amount($item[[2334]Holy MacGuffin]) == 1)
	{
		council();
		return true;
	}

	int baseML = monster_level_adjustment();
	if(auto_my_path() == "Heavy Rains")
	{
		baseML = baseML + 60;
	}
	if(baseML > 150)
	{
		foreach s in $slots[acc1, acc2, acc3]
		{
			if(equipped_item(s) == $item[Hand In Glove])
			{
				equip(s, $item[none]);
			}
		}
		uneffect($effect[Ur-kel\'s Aria of Annoyance]);
		if(possessEquipment($item[Beer Helmet]))
		{
			autoEquip($item[beer helmet]);
		}
	}
	if(in_koe())
	{
		retrieve_item(1, $item[low-pressure oxygen tank]);
		autoForceEquip($item[low-pressure oxygen tank]);
	}

	zelda_equipTool($stat[moxie]);

	auto_log_info("Time to waste all of Ed's Ka Coins :(", "blue");

	set_property("choiceAdventure976", "1");

	autoAdv($location[The Lower Chambers]);
	if(in_pokefam() || in_koe())
	{
		cli_execute("refresh inv");
	}

	if(item_amount($item[[2334]Holy MacGuffin]) != 0)
	{
		council();
	}
	return true;
}
