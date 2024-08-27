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
	if (isFreeMonster(enemy, loc)) { return false; } // don't use gravel against inherently free fights
	// prevent overuse after breaking ronin or in casual
	if(can_interact()) return false;

	// many monsters in these zones with similar names
	if(loc == $location[The Battlefield (Frat Uniform)] && 
		(contains_text(enemy.to_string(), "War Hippy")) ||
		$strings[Bailey's Beetle, Mobile Armored Sweat Lodge] contains enemy)
	{
		return true;
	}
	if(loc == $location[The Battlefield (Hippy Uniform)] && contains_text(enemy.to_string(), "War Frat"))
	{
		return true;
	}

	// look for specific monsters in zones where some monsters we do care about
	static boolean[string] gravelTargets = $strings[
		// The Haunted Bathroom
		claw-foot bathtub,
		malevolent hair clog,
		toilet papergeist,

		// The Haunted Gallery
		cubist bull,
		empty suit of armor,
		guy with a pitchfork, and his wife,

		// The Haunted Bedroom
		animated mahogany nightstand,
		animated ornate nightstand,
		animated rustic nightstand,
		elegant animated nightstand,
		Wardr&ouml;b nightstand,
		
		// The Haunted Wine Cellar
		skeletal sommelier,

		// The Haunted Laundry Room
		plaid ghost,
		possessed laundry press,

		// The Haunted Boiler Room
		coaltergeist,
		steam elemental
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
	//Get cryptobotanist if under level 8 or switch to insectologist if possible
	if (my_level() < 8 && !have_skill($skill[cryptobotanist]) || (!get_property("_sitCourseCompleted").to_boolean() && my_level() >= 8 && !have_skill($skill[insectologist]))){
		use(1,$item[S.I.T. Course Completion Certificate]);
		//auto_run_choice(1494);
		return;
	}
}

boolean auto_havePayPhone()
{
	return auto_is_valid($item[closed-circuit pay phone]) && item_amount($item[closed-circuit pay phone]) > 0;
}

location auto_availableBrickRift()
{
	if(!auto_havePayPhone())
	{
		return $location[none];
	}

	boolean[location] riftsWithBricks = $locations[Shadow Rift (The Ancient Buried Pyramid), Shadow Rift (The Hidden City), Shadow Rift (The Misspelled Cemetary)];
	foreach loc in riftsWithBricks
	{
		if(can_adventure(loc)) return loc;
	}
	return $location[none];
}

int auto_neededShadowBricks()
{
	if(!auto_havePayPhone() || in_ag())
	{
		return 0;
	}

	int currentBricks = item_amount($item[shadow brick]);
	int bricksUsedToday = get_property("_shadowBricksUsed").to_int();
	return max(0, 13 - currentBricks - bricksUsedToday);
}

boolean auto_getPhoneQuest()
{
	if(!auto_havePayPhone())
	{
		return false;
	}

	if(get_property("questRufus") != "unstarted")
	{
		// already started quest
		return true;
	}

	// get artifact quest
	// auto_choice_adv handles actually picking it
	use($item[closed-circuit pay phone]);

	return get_property("questRufus") != "unstarted";
}

boolean auto_doPhoneQuest()
{
	if(!auto_havePayPhone())
	{
		return false;
	}
	// only accept and do quest if we can get bricks
	if(auto_availableBrickRift() == $location[none])
	{
		return false;
	}
	// already finished phone quest today
	if(get_property("_shadowAffinityToday").to_boolean() && have_effect($effect[Shadow Affinity]) == 0 && get_property("questRufus") == "unstarted")
	{
		return false;
	}
	// not high enough level yet. Survive at least 2 hits
	if(my_maxhp() <= expected_damage($monster[shadow slab]) * 2)
	{
		return false;
	}
	// don't start quest if fights will already be free... unless we already have shadow affinity
	if(isFreeMonster($monster[shadow slab], auto_availableBrickRift()) && have_effect($effect[Shadow Affinity]) == 0)
	{
		return false;
	}

	// get quest
	if(!auto_getPhoneQuest())
	{
		abort("Failed to get Rufus quest from cursed phone.");
	}

	// finish quest
	if(get_property("questRufus") == "step1")
	{
		use($item[closed-circuit pay phone]);
		if(get_property("questRufus") != "unstarted")
		{
			abort("Failed to finish Rufus quest from cursed phone.");
		}
		return true;
	}

	backupSetting("shadowLabyrinthGoal", "browser"); // use mafia's automation handling for the Shadow Rift NC.
	return autoAdv(auto_availableBrickRift());
}

boolean auto_haveMonkeyPaw()
{
	static item paw = $item[cursed monkey\'s paw];
	return auto_is_valid(paw) && (item_amount(paw) > 0 || have_equipped(paw));
}

int auto_monkeyPawWishesLeft()
{
	if (auto_haveMonkeyPaw())
	{
		return 5 - get_property("_monkeyPawWishesUsed").to_int();
	}
	return 0;
}

boolean auto_makeMonkeyPawWish(effect wish)
{
	if (!auto_haveMonkeyPaw()) {
		auto_log_info("Requested monkey paw wish without paw available, skipping "+to_string(wish));
		return false;
	}
	if (auto_monkeyPawWishesLeft() < 1) {
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
	if (auto_monkeyPawWishesLeft() < 1) {
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
	if (auto_monkeyPawWishesLeft() < 1) {
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
	if(is_werewolf())
	{
		return false; //can't rest as werewolf
	}
	if(auto_currentCinch() >= goal)
	{
		return true;
	}
	if(!haveFreeRestAvailable())
	{
		// don't have enough cinch and don't have any free rests left
		return false;
	}
	if(!haveAnyIotmAlternativeRestSiteAvailable() && (get_dwelling() == $item[big rock] && !in_small()))
	{
		// don't have anywhere to rest
		// get dwelling returns big rock when no place to rest in campsite
		// exception for Small path as you can't use housing in-run so you will always have a big rock.
		return false;
	}
	// use free rests until have enough cinch or out of rests
	while(auto_currentCinch() < goal && haveFreeRestAvailable() && !in_wereprof())
	{
		if(!doFreeRest())
		{
			auto_log_debug("Failed to rest to charge cincho. Will try again later.");
			return false;
		}
	}

	// go for cinch as a professor. commented out for now because mafia tracking of free rests as a prof MAY not be working as expected
	/*while(auto_currentCinch() < goal && haveFreeRestAvailable() && is_professor())
	{
		visit_url("place.php?whichplace=wereprof_cottage&action=wereprof_sleep"); //just visit the cottage to sleep as professor
	}*/

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
	if (haveFreeRestAvailable() || numeric_modifier("Free Rests") < auto_potentialMaxFreeRests())
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
		// using item collects credits
		use($item[2002 Mr. Store Catalog]);
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
	auto_log_debug("Have " + remainingCatalogCredits() + " credit(s) to buy from Mr. Store 2002. Let's spend them!");
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
	if (my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean()) {
		itemConsidering = $item[giant black monolith];
		if(remainingCatalogCredits() > 0 && !(auto_get_campground() contains itemConsidering) && auto_is_valid(itemConsidering))
		{
			buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
			use(itemConsidering);
			visit_url("campground.php?action=monolith");
		}
	}
	// crimbo cookie. Should we expand to buy more or use in more paths beyond HC LoL?
	itemConsidering = $item[Crimbo cookie sheet];
	if(remainingCatalogCredits() > 0 && in_hardcore() && my_daycount() == 1 && in_lol())
	{
		buy($coinmaster[Mr. Store 2002], remainingCatalogCredits(), itemConsidering);
	}
	// loathing idol microphone. Use remaining credits
	itemConsidering = $item[loathing idol microphone];
	if(remainingCatalogCredits() > 0 && auto_is_valid(itemConsidering))
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

boolean auto_haveAugustScepter()
{
	static item scepter = wrap_item($item[august scepter]);
	if(auto_is_valid(scepter) && (item_amount(scepter) > 0 || have_equipped(scepter)))
	{
		return true;
	}
	return false;
}

void auto_scepterSkills()
{
	if(!auto_haveAugustScepter())
	{
		return;
	}
	//Day 1 skills
	if(my_daycount() == 1)
	{
		if(canUse($skill[Aug. 24th: Waffle Day!]) && !get_property("_aug24Cast").to_boolean())
		{
			use_skill($skill[Aug. 24th: Waffle Day!]); //get some waffles to hopefully change some bad monsters to better ones
		}
		if(canUse($skill[Aug. 30th: Beach Day!]) && !get_property("_aug30Cast").to_boolean())
		{
			use_skill($skill[Aug. 30th: Beach Day!]); //Rollover adventures
		}
		if(canUse($skill[Aug. 28th: Race Your Mouse Day!]) && !get_property("_aug28Cast").to_boolean() && pathHasFamiliar())
		{
			familiar hundred_fam = to_familiar(get_property("auto_100familiar"));
			if(((in_ag() && in_hardcore()) || (hundred_fam != $familiar[none] && (isAttackFamiliar(hundred_fam) || hundred_fam.block))) && have_familiar(findRockFamiliarInTerrarium()))
			{
				use_familiar(findRockFamiliarInTerrarium());
				use_skill($skill[Aug. 28th: Race Your Mouse Day!]); //Fam equipment to lower weight of attack familiar or Burly bodyguard (Avant Guard) for Gremlins
			}
			else if((!auto_hasStillSuit() && item_amount($item[Astral pet sweater]) == 0) || in_small())
			{
				if(!is100FamRun())
				{
					use_familiar(findNonRockFamiliarInTerrarium()); //equip non-rock fam to ensure we get tiny gold medal
				}
				else
				{
					use_familiar(hundred_fam); // assuming non-rock familiar
				}
				use_skill($skill[Aug. 28th: Race Your Mouse Day!]); //Fam equipment
			}
		}
	}
	//Day 2+ skills
	if(my_daycount() >= 2)
	{
		if(canUse($skill[Aug. 24th: Waffle Day!]) && !get_property("_aug24Cast").to_boolean())
		{
			use_skill($skill[Aug. 24th: Waffle Day!]); //get some waffles to hopefully change some bad monsters to better ones
		}
		if(canUse($skill[Aug. 28th: Race Your Mouse Day!]) && !get_property("_aug28Cast").to_boolean() && ((!auto_hasStillSuit() && item_amount($item[Astral pet sweater]) == 0) || in_small()))
		{
			if(!is100FamRun())
			{
				handleFamiliar("stat"); //get any familiar equipped if not in a 100% run
			}
			use_skill($skill[Aug. 28th: Race Your Mouse Day!]); //Fam equipment
		}
	}
}

void auto_lostStomach(boolean force)
{
	if(!auto_haveAugustScepter() || in_small())
	{
		return;
	}

	//Cast Roller Coaster Day if forced to and fullness is greater than 0 and it's available to cast
	if (force && my_fullness() > 0 && get_property("_augSkillsCast").to_int() < 5 && !get_property("_aug16Cast").to_boolean())
	{
		use_skill($skill[Aug. 16th: Roller Coaster Day!]);
	}

	//Otherwise leave Roller Coaster Day until near the end of the day and it's available to cast
	if(fullness_left() == 0 && inebriety_left() == 0 && my_adventures() < 10  && get_property("_augSkillsCast").to_int() < 5 && !get_property("_aug16Cast").to_boolean() && !force)
	{
		use_skill($skill[Aug. 16th: Roller Coaster Day!]);
	}
}

boolean auto_haveBofa()
{
	return auto_is_valid($skill[just the facts]) && have_skill($skill[just the facts]);
}

boolean auto_canHabitat()
{
	if (!auto_haveBofa())
	{
		return false;
	}
	if (get_property("_monsterHabitatsRecalled").to_int() >= 3)
	{
		// no charges left
		return false;
	}
	if (get_property("_monsterHabitatsFightsLeft").to_int() > 0)
	{
		// already habitating something but we may not need all 5 of them in certain situations
		switch (get_property("_monsterHabitatsMonster").to_monster())
		{
			case $monster[fantasy bandit]:
				return (fantasyBanditsFought() < 5);
			case $monster[modern zmobie]:
				return get_property("cyrptAlcoveEvilness").to_int() > 13;
			default:
				return false;
		}
	}
	return true;
}

boolean auto_habitatTarget(monster target)
{
	if (!auto_canHabitat()) {
		return false;
	}
	if (get_property("_monsterHabitatsMonster").to_monster() == target && get_property("_monsterHabitatsFightsLeft").to_int() > 0)
	{
		// already habitating this monster
		return false;
	}
	switch (target)
	{
		case $monster[fantasy bandit]:
			// only worth it if we need all 5.
			return (fantasyBanditsFought() == 0);
		case $monster[modern zmobie]:
		 	// only worth it if we need 30 or more evilness reduced.
			return (get_property("cyrptAlcoveEvilness").to_int() > 42);
		case $monster[eldritch tentacle]:
			return (get_property("auto_habitatMonster").to_monster() == target || (get_property("_monsterHabitatsMonster").to_monster() == target && get_property("_monsterHabitatsFightsLeft").to_int() == 0));
		default:
			return (get_property("auto_habitatMonster").to_monster() == target);
	}
	return false;
}

int auto_habitatFightsLeft()
{
	return get_property("_monsterHabitatsFightsLeft").to_int();
}

monster auto_habitatMonster()
{
	if (get_property("_monsterHabitatsFightsLeft").to_int() > 0)
	{
		return get_property("_monsterHabitatsMonster").to_monster();
	}
	return $monster[none];
}

boolean auto_canCircadianRhythm()
{
	if (!auto_haveBofa())
	{
		return false;
	}
	if (get_property("_circadianRhythmsRecalled").to_boolean())
	{
		return false;
	}
	return true;
}

boolean auto_circadianRhythmTarget(monster target)
{
	if (!auto_canCircadianRhythm())
	{
		return false;
	}
	if (!($monsters[shadow bat, shadow cow, shadow devil, shadow guy, shadow hexagon, shadow orb, shadow prism, shadow slab, shadow snake, shadow spider, shadow stalk, shadow tree] contains target))
	{
		return false;
	}
	return true;
}

boolean auto_circadianRhythmTarget(phylum target)
{
	if (!auto_canCircadianRhythm())
	{
		return false;
	}
	if (!($phylums[Orc, Hippy] contains target) && $locations[The Battlefield (Hippy Uniform), The Battlefield (Frat Uniform)] contains my_location())
	{
		return false;
	}
	return true;
}

boolean auto_haveJillOfAllTrades()
{
	if(auto_have_familiar($familiar[Jill-of-All-Trades]))
	{
		return true;
	}
	return false;
}

string getParsedCandleMode()
{
	// returns candle mode which matches our familiar categories
	switch(get_property("ledCandleMode"))
	{
		case "disco":
			return "item";
		case "ultraviolet":
			return "meat";
		case "reading":
			return "stat";
		case "red":
			return "boss";
		default:
			return "unknown";
	}
}

void auto_handleJillOfAllTrades()
{
	if (!auto_haveJillOfAllTrades() || item_amount($item[LED candle]) == 0)
	{
		return;
	}

	// only bother to configure candle if Jill is equiped
	if(my_familiar() != $familiar[Jill-of-All-Trades])
	{
		return;
	}

	string currentMode = getParsedCandleMode();
	// want to configure jill to have bonus of whatever fam type we last looked up
	string desiredCandleMode = get_property("auto_lastFamiliarLookupType");

	auto_log_debug(`Jill current mode: {currentMode} and desired is {desiredCandleMode}`);
	if(currentMode == desiredCandleMode)
	{
		return;
	}

	switch(desiredCandleMode)
	{
		case "item":
		case "regen":
		case "init":
		case "gremlin":
		case "gremlins":
		case "yellowray":
			cli_execute("jillcandle item");
			break;
		case "meat":
			cli_execute("jillcandle meat");
			break;
		case "stat":
		case "drop":
			cli_execute("jillcandle stat");
			break;
		case "boss":
			cli_execute("jillcandle attack");
			break;
		default:
			abort("tried to configure Jill's LED Candle with a non-supported type");
	}

	return;
}

boolean auto_haveBurningLeaves()
{
	return auto_is_valid($item[A Guide to Burning Leaves]) && get_campground() contains $item[A Guide to Burning Leaves];
}

boolean auto_burnLeaves()
{
	if (!auto_haveBurningLeaves())
	{
		return false;
	}
	if (available_amount($item[rake]) < 1)
	{
		// visit the pile of burning leaves to grab the rakes
		visit_url("campground.php?preaction=leaves");
	}
	if (item_amount($item[inflammable leaf]) > 73 && !(get_campground() contains $item[forest canopy bed]) && get_dwelling() != $item[big rock] && auto_haveCincho())
	{
		// get and use the forest canopy bed if we don't have one already and have a Cincho as it is +5 free rests
		if (create(1, $item[forest canopy bed]))
		{
			return use(1, $item[forest canopy bed]);
		}
		return false;
	}
	if (get_campground() contains $item[forest canopy bed] && item_amount($item[inflammable leaf]) > 49 && have_effect($effect[Resined]) == 0)
	{
		// Get the Resined effect if we don't have it as it is net positive for leaves.
		if (create(1, $item[distilled resin]))
		{
			return use(1, $item[distilled resin]);
		}
		return false;
	}
	if(in_ag() && item_amount($item[inflammable leaf]) > 37 && item_amount($item[Autumnic bomb]) == 0)
	{
		create(1, $item[Autumnic bomb]); //Reduces enemy hp in half, useful for bodyguards with 40K hp
	}
	return false;
}

boolean auto_haveCCSC()
{
	if(auto_can_equip($item[Candy Cane Sword Cane]) && available_amount($item[Candy Cane Sword Cane]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_handleCCSC()
{
	if(!auto_haveCCSC())
	{
		return false;
	}
	location place = my_location();
	
	/* Where/Why We Want Only Certain Locations
	 The Sleazy Back Alley - 11-leaf clover (only visit if we are a moxie class unlocking guild, but still potentially useful)
	 The Daily Dungeon - Eleven-foot pole replacement. +1 Fat Loot Token
	 The Shore, Inc. Travel Agency - 2 Scrips and all stats
	 The Defiled Cranny - -11 evilness
	 The eXtreme Slope - If we can't do ninja snowmen for some reason, gives us 2 pieces of equipment in one NC
	 The Penultimate Fantasy Airship - Get an umbrella for basement, metallic A for wand, SGEEA, and Fantasy Chest for even more items
	 The Black Forest - +8 exploration
	 The Copperhead Club - Gives us a priceless diamond, saving 4950-5000 meat
	 The Hidden Apartment Building - +1 cursed level, Doesn't leave NC
	 The Hidden Bowling Alley - 1 less bowling ball needed
	 An Overgrown Shrine (Northeast) - Free Meat
	 A Mob of Zeppelin Protesters - Double Sleaze Protestors
	 Wartime Frat House/Camp - Skip non-useful NC to go to war start NC
	 */

	if((place == $location[The Hidden Bowling Alley] && item_amount($item[Bowling Ball]) > 0 && get_property("hiddenBowlingAlleyProgress").to_int() < 5 && !get_property("candyCaneSwordBowlingAlley").to_boolean())
	   || (place == $location[The Shore\, Inc. Travel Agency] && item_amount($item[Forged Identification Documents]) == 0 && !get_property("candyCaneSwordShore").to_boolean())
	   || (place == $location[The eXtreme Slope] && (!possessEquipment($item[eXtreme scarf]) && !possessEquipment($item[snowboarder pants])))
	   || (place == $location[The Copperhead Club] && (item_amount($item[priceless diamond]) == 0 && item_amount($item[Red Zeppelin Ticket]) == 0) && !get_property("candyCaneSwordCopperheadClub").to_boolean())
	   || (place == $location[The Defiled Cranny] && !get_property("candyCaneSwordDefiledCranny").to_boolean())
	   || (place == $location[The Black Forest] && !get_property("candyCaneSwordBlackForest").to_boolean())
	   || (place == $location[The Hidden Apartment Building] && !get_property("candyCaneSwordApartmentBuilding").to_boolean())
	   || (place == $location[An Overgrown Shrine (Northeast)] && !get_property("_candyCaneSwordOvergrownShrine").to_boolean() && get_property("hiddenOfficeProgress").to_int() > 0)
	   || (place == $location[The Overgrown Lot] && !get_property("_candyCaneSwordOvergrownLot").to_boolean())
	   || (place == $location[The Penultimate Fantasy Airship] && (!possessEquipment($item[Amulet of Extreme Plot Significance]) || !possessEquipment($item[unbreakable umbrella]) || !possessEquipment($item[Titanium Assault Umbrella])))
	   || ((place == $location[Wartime Frat House] && possessOutfit("War Hippy Fatigues")) || (place == $location[Wartime Hippy Camp] && possessOutfit("Frat Warrior Fatigues")))
	   || ($locations[The Sleazy Back Alley, A Mob of Zeppelin Protesters, The Daily Dungeon]) contains place)
	{
		return true;
	}
	return false;
}

void auto_useWardrobe()
{
	if(!auto_is_valid($item[wardrobe-o-matic]))
	{
		return;
	}
	if(item_amount($item[wardrobe-o-matic]) == 0)
	{
		return;
	}
	// check one of the 3 prefs which get set when wardrobe is used each day
	if(get_property("_futuristicHatModifier") != "")
	{
		return;
	}
	// wait for level 5 to get an upgraded wardrobe
	if(my_level() < 5)
	{
		return;
	}
	// wait for level 15 if close and not at NS tower
	if(my_level() == 14 && internalQuestStatus("questL13Final") < 0)
	{
		return;
	}
	// only need to use it so we get the hat, shirt, fam equip
	// let maximizer handle if any of it is worth equipping
	use($item[wardrobe-o-matic]);
}
