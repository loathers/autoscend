# This is meant for items that have a date of 2023

boolean auto_haveRockGarden()
{
	static item rockGarden = $item[Packet Of Rock Seeds];
	return auto_is_valid(rockGarden) && auto_get_campground() contains rockGarden;
}

void rockGardenEnd() //broke these out so they aren't handled at the start of everyday but ASAP after numberology
{
	//while we will probably never get these automatically, should handle them anyway
	if (item_amount($item[Molehill Mountain]) > 0 && !get_property("_molehillMountainUsed").to_boolean()){
		use(1,$item[Molehill Mountain]);
	}

	if((item_amount($item[strange stalagmite]) > 0) && !get_property("_strangeStalagmiteUsed").to_boolean())
	{
		use(1,$item[strange stalagmite]);
	}
	return;
}

void pickRocks()
{
	//Pick rocks everyday
	//If we manage to get a lodestone, will not use it, because it is a one-a-day and user may want to use it in specific places
    if (!auto_haveRockGarden()) return;
	visit_url("campground.php?action=rgarden1");
	if(get_property("desertExploration").to_int() < 100)
	{
		visit_url("campground.php?action=rgarden2");
	}
	visit_url("campground.php?action=rgarden3");
	return;
}

boolean wantToThrowGravel(location loc, monster enemy)
{
	// returns true if we want to use Groveling Gravel. Not intended to exhaustivly list all valid targets.
	// simply enough to use the few gravels we get in run.

	if(item_amount($item[groveling gravel]) == 0) return false;
	if(!auto_is_valid($item[groveling gravel])) return false;
	if (isFreeMonster(enemy)) { return false; } // don't use gravel against inherently free fights
	// prevent overuse after breaking ronin or in casual
	if(can_interact()) return false;

	// use gravel in battlefield if no breathitin charges
	if(get_property("breathitinCharges").to_int() == 0 && 
		(loc == $location[The Battlefield (Frat Uniform)] || loc == $location[The Battlefield (Hippy Uniform)]) &&
		!($monsters[Green Ops Soldier,C.A.R.N.I.V.O.R.E. Operative,Glass of Orange Juice,Sorority Nurse,
		Naughty Sorority Nurse,Monty Basingstoke-Pratt\, IV,Next-generation Frat Boy] contains enemy))
	{
		return true;
	}

	// spookyraven zones 
	if(loc == $location[The Haunted Bathroom]) return true;
	if(loc == $location[The Haunted Gallery]) return true;
	if(loc == $location[The Haunted Bedroom]) return true;

	// look for specific monsters in zones where some monsters we do care about
	static boolean[string] gravelTargets = $strings[
		// The Haunted Wine Cellar
		skeletal sommelier,

		// The Haunted Laundry Room
		plaid ghost,
		possessed laundry press,

		// The Haunted Boiler Room
		coaltergeist,
		steam elemental,
	];
	return gravelTargets contains enemy;
}

boolean auto_haveSITCourse()
{
	static item sitCourse = $item[S.I.T. Course Completion Certificate];
	return auto_is_valid(sitCourse) && item_amount(sitCourse) > 0;
}

void auto_SITCourse()
{
	if (!auto_haveSITCourse()) return;
	//Best choice seems to be insectologist
	if (!have_skill($skill[insectologist])){
		use(1,$item[S.I.T. Course Completion Certificate]);
		//auto_run_choice(1484);
		return;
	}
}

boolean auto_haveMonkeyPaw()
{
	static item paw = $item[cursed monkey\'s paw];
	return auto_is_valid(paw) && (item_amount(paw) > 0 || have_equipped(paw));
}

boolean auto_makeMonkeyPawWish(effect wish)
{
	if (!auto_haveMonkeyPaw()) {
		auto_log_info("Requested monkey paw wish without paw available, skipping "+to_string(wish));
		return false;
	}
	if(get_property("_monkeyPawWishesUsed").to_int() >= 5) {
		auto_log_info("Out of monkey paw wishes, skipping "+to_string(wish));
		return false;
	}
	boolean success = monkey_paw(wish);
	if (success) {
		handleTracker(to_string($item[cursed monkey\'s paw]), to_string(wish), "auto_wishes");
	}
	return success;
}

boolean auto_makeMonkeyPawWish(item wish)
{
	if (!auto_haveMonkeyPaw()) {
		auto_log_info("Requested monkey paw wish without paw available, skipping "+to_string(wish));
		return false;
	}
	if(get_property("_monkeyPawWishesUsed").to_int() >= 5) {
		auto_log_info("Out of monkey paw wishes, skipping "+to_string(wish));
		return false;
	}
	boolean success = monkey_paw(wish);
	if (success) {
		handleTracker(to_string($item[cursed monkey\'s paw]), to_string(wish), "auto_wishes");
	}
	return success;
}

boolean auto_makeMonkeyPawWish(string wish)
{
	if (!auto_haveMonkeyPaw()) {
		auto_log_info("Requested monkey paw wish without paw available, skipping "+to_string(wish));
		return false;
	}
	if(get_property("_monkeyPawWishesUsed").to_int() >= 5) {
		auto_log_info("Out of monkey paw wishes, skipping "+wish);
		return false;
	}
	boolean success = monkey_paw(wish);
	if (success) {
		handleTracker(to_string($item[cursed monkey\'s paw]), wish, "auto_wishes");
	}
	return success;
}

boolean auto_haveCincho()
{
	static item cincho = wrap_item($item[Cincho de Mayo]);
	if(auto_is_valid(cincho) && (item_amount(cincho) > 0 || have_equipped(cincho)))
	{
		return true;
	}

	return false;
}

int auto_currentCinch()
{
	if(!auto_haveCincho())
	{
		return 0;
	}
	return 100 - get_property("_cinchUsed").to_int();
}

int auto_cinchAfterNextRest()
{
	int cinchoRestsAlready = get_property("_cinchoRests").to_int();
	// calculating for how much cinch NEXT rest will give
	cinchoRestsAlready++;

	int cinchGainedNextRest = 5;
	if(cinchoRestsAlready <= 5) cinchGainedNextRest = 30;
	else if(cinchoRestsAlready == 6) cinchGainedNextRest = 25;
	else if(cinchoRestsAlready == 7) cinchGainedNextRest = 20;
	else if(cinchoRestsAlready == 8) cinchGainedNextRest = 15;
	else if(cinchoRestsAlready == 9) cinchGainedNextRest = 10;
	// 10 and above give 5

	return auto_currentCinch() + cinchGainedNextRest;
}

boolean auto_nextRestOverCinch()
{
	return auto_cinchAfterNextRest() > 100;
}

boolean auto_getCinch(int goal)
{
	boolean atMaxMpHp()
	{
		return my_mp() == my_maxmp() && my_hp() == my_maxhp();
	}

	if(auto_currentCinch() >= goal)
	{
		return true;
	}
	if(atMaxMpHp())
	{
		// can't rest if we have full mp and hp
		return false;
	}
	if(!haveFreeRestAvailable())
	{
		// don't have enough cinch and don't have any free rests left
		return false;
	}
	if(!haveAnyIotmAlternativeRestSiteAvailable() && get_dwelling() == $item[big rock])
	{
		// don't have anywhere to rest
		// get dwelling returns big rock when no place to rest in campsite
		return false;
	}
	// use free rests until have enough cinch or out of rests
	while(auto_currentCinch() < goal && haveFreeRestAvailable())
	{
		if(atMaxMpHp())
		{
			// can't rest if we have full mp and hp
			return false;
		}
		if(!doFreeRest())
		{
			abort("Failed to rest to charge cincho");
		}
	}

	// see if we got enough cinch after using free rests
	if(auto_currentCinch() >= goal)
	{
		return true;
	}
	return false;
}

boolean shouldCinchoConfetti()
{
	// Cincho: Confetti Extravaganza doubles stat gains of current combat
	// costs 5 cinch and flips out the monster
	// cast this skill when we can't cast any more fiesta exists

	// can't cast it if we don't have it
	if(!canUse($skill[Cincho: Confetti Extravaganza]))
	{
		return false;
	}
	// don't over level
	if(!disregardInstantKarma())
	{
		return false;
	}
	// save cinch for fiest exit
	if(auto_currentCinch() > 60)
	{
		return false;
	}
	// use all free rests before using confetti. May get enough cinch to fiesta exit
	if(haveFreeRestAvailable())
	{
		return false;
	}
	// canSurvive checked in calling location. This function is only available to combat files
	return true;
}

boolean auto_have2002Catalog()
{
	static item catalog = wrap_item($item[2002 Mr. Store Catalog]);
	if(auto_is_valid(catalog) && (item_amount(catalog) > 0 || have_equipped(catalog)))
	{
		return true;
	}
	return false;
}

int remainingCatalogCredits()
{
	if(!auto_have2002Catalog())
	{
		return 0;
	}
	if(!get_property("_2002MrStoreCreditsCollected").to_boolean())
	{
		//todo - collect credits
	}
	return get_property("availableMrStore2002Credits").to_int();
}

boolean auto_haveIdolMicrophone()
{
	if(item_amount($item[Loathing Idol Microphone]) > 0)
	{
		return true;
	}
	if(item_amount($item[Loathing Idol Microphone (75% charged)]) > 0)
	{
		return true;
	}
	if(item_amount($item[Loathing Idol Microphone (50% charged)]) > 0)
	{
		return true;
	}
	if(item_amount($item[Loathing Idol Microphone (25% charged)]) > 0)
	{
		return true;
	}
	return false;
}

void auto_buyFrom2002MrStore()
{
	if(remainingCatalogCredits() == 0)
	{
		return;
	}
	// meat butler on day 1 of run
	item itemConsidering = $item[meat butler];
	if(remainingCatalogCredits() > 0 && my_daycount() == 1 && !haveCampgroundMaid() && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
		use(itemConsidering);
	}
	// manual of secret door detection. skill: Secret door awareness
	itemConsidering = $item[manual of secret door detection];
	if(remainingCatalogCredits() > 0 && !auto_have_skill($skill[Secret door awareness]) && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
		use(itemConsidering);
	}
	// giant black monlith. Mostly useful at low level for stats
	itemConsidering = $item[giant black monolith];
	if(remainingCatalogCredits() > 0 && !(auto_get_campground() contains itemConsidering) && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
		use(itemConsidering);
		visit_url("campground.php?action=monolith");
	}
	// crimbo cookie. Should we expand to buy more or use in more paths beyond HC LoL?
	itemConsidering = $item[Crimbo cookie sheet];
	if(remainingCatalogCredits() > 0 && in_hardcore() && my_daycount() == 1 && in_lol())
	{
		buy($coinmaster[Mr. Store 2002], remainingCatalogCredits(), itemConsidering);
	}
	// loathing idol microphone. Use remaining credits
	itemConsidering = $item[loathing idol microphone];
	if(remainingCatalogCredits() > 0 && !auto_haveIdolMicrophone() && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], remainingCatalogCredits(), itemConsidering);
	}
}

void auto_useBlackMonolith()
{
	// done if already used it today
	if(get_property("_blackMonolithUsed").to_boolean())
	{
		return;
	}
	// done if we don't want stats
	if(!disregardInstantKarma())
	{
		return;
	}
	// done if we don't have monolith
	if(!(auto_get_campground() contains $item[giant black monolith]))
	{
		return;
	}
	// use monolith
	visit_url("campground.php?action=monolith");
}
