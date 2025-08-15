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
	
	return auto_wantToFreeKillWithNoDrops(loc, enemy);
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

boolean[location] auto_allRifts()
{
	return $locations[
	    Shadow Rift (Desert Beach),
	    Shadow Rift (Forest Village),
	    Shadow Rift (Mt. McLargeHuge),
	    Shadow Rift (Somewhere Over the Beanstalk),
	    Shadow Rift (Spookyraven Manor Third Floor),
	    Shadow Rift (The 8-Bit Realm),
	    Shadow Rift (The Ancient Buried Pyramid),
	    Shadow Rift (The Castle in the Clouds in the Sky),
	    Shadow Rift (The Distant Woods),
	    Shadow Rift (The Hidden City),
	    Shadow Rift (The Misspelled Cemetary),
	    Shadow Rift (The Nearby Plains),
	    Shadow Rift (The Right Side of the Tracks)
	];
}

location auto_availableBrickRift()
{
	if(!auto_havePayPhone())
	{
		return $location[none];
	}

	if (in_avantGuard() && !auto_haveQueuedForcedNonCombat()) //if no NC forced, don't adventure in zone
	{
		return $location[none];
	}

	boolean[location] riftsWithBricks = $locations[Shadow Rift (The Ancient Buried Pyramid), Shadow Rift (The Hidden City), Shadow Rift (The Misspelled Cemetary)];
	boolean[location] riftsWithWishes = auto_riftsWithWishes();
	// First loop checks for bricks and wishes if we have BoFA
	if (auto_haveBofa() && auto_wishFactsLeft() > 0)
	{
		foreach loc in riftsWithBricks
		{
			if(riftsWithWishes contains loc && can_adventure(loc)) return loc;
		}
	}
	// Then ignore wishes
	foreach loc in riftsWithBricks
	{
		if(can_adventure(loc)) return loc;
	}
	return $location[none];
}

boolean[location] auto_riftsWithWishes()
{
	boolean[location] out;
	foreach loc in auto_allRifts()
	{
		foreach m in get_location_monsters(loc)
		{
			if(item_fact(m)==$item[pocket wish])
			{
				out[loc] = true;
				break;
			}
		}
	}
	return out;
}

int auto_neededShadowBricks()
{
	if (!auto_havePayPhone() || in_avantGuard())
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
	// only accept and do quest if we can get bricks or force a noncombat
	if(auto_availableBrickRift() == $location[none] || !auto_canForceNextNoncombat())
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
	// in pokefam, we want at least 2 level 5s
	if (in_pokefam()) {
		// mafia can lose track of the team, so visit famteam so we're up to date
		visit_url("famteam.php");
		int pokelevel1 = my_poke_fam(0).poke_level;
		int pokelevel2 = my_poke_fam(1).poke_level;
		int pokelevel3 = my_poke_fam(2).poke_level;
		int numFives = 0;
		if (pokelevel1 == 5) {
			numFives++;
		}
		if (pokelevel2 == 5) {
			numFives++;
		}
		if (pokelevel3 == 5) {
			numFives++;
		}
		if (numFives < 2) {
			return false;
		}
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

	//Force a non combat instead of adventuring there to save turns, especially in AG
	if(auto_haveQueuedForcedNonCombat())
	{
		return autoAdv(auto_availableBrickRift());
	}

	if (auto_canForceNextNoncombat() && in_avantGuard()) //in avant guard, want to avoid adventuring here unless you can force an NC
	{
		return auto_forceNextNoncombat(auto_availableBrickRift());
	}

	backupSetting("shadowLabyrinthGoal", "browser"); // use mafia's automation handling for the Shadow Rift NC.
	return autoAdv(auto_availableBrickRift());
}

boolean auto_isShadowRiftMonster(monster m)
{
	boolean[monster] reg = $monsters[
	  shadow bat, shadow cow, shadow devil, shadow guy, shadow hexagon, shadow orb,
	  shadow prism, shadow slab, shadow snake, shadow spider, shadow stalk, shadow tree ];
	boolean[monster] boss = $monsters[
	  shadow cauldron, shadow matrix, shadow orrery, shadow scythe,
	  shadow spire, shadow tongue ];
	return reg contains m || boss contains m;
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
		handleTracker(to_string($item[cursed monkey\'s paw]), my_location().to_string(), to_string(wish), "auto_wishes");
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
		handleTracker(to_string($item[cursed monkey\'s paw]), my_location().to_string(), wish, "auto_wishes");
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

int auto_cinchFromNextRest()
{
	int cinchoRestsAlready = get_property("_cinchoRests").to_int();
	// calculating for how much cinch NEXT rest will give
	cinchoRestsAlready++;
	return auto_cinchFromRestN(cinchoRestsAlready);
}

int auto_cinchFromRestN(int n)
{
	int cinchGainedFromRest = 5;
	if     (n <= 5) cinchGainedFromRest = 30;
	else if(n == 6) cinchGainedFromRest = 25;
	else if(n == 7) cinchGainedFromRest = 20;
	else if(n == 8) cinchGainedFromRest = 15;
	else if(n == 9) cinchGainedFromRest = 10;
	
	return cinchGainedFromRest;
}
int auto_cinchAfterNextRest()
{
	return auto_currentCinch() + auto_cinchFromNextRest();
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

int auto_potentialMaxCinchLeft()
{
	int max_rests = auto_potentialMaxFreeRests();
	int curr_free_rests_used = get_property("_cinchoRests").to_int();
	int cinch = auto_currentCinch();
	for (int irest = curr_free_rests_used+1 ; irest < max_rests ; irest++)
	{
		cinch = cinch + auto_cinchFromRestN(irest);
	}
	return cinch;
}

int auto_cinchForcesLeft()
{
	return floor(auto_potentialMaxCinchLeft()/60);
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
		if(in_lol())
		{	//autoscend doesn't always trigger in LoL, switching to specify Replica
			use($item[Replica 2002 Mr. Store Catalog]);
		}
		else
		{
			use($item[2002 Mr. Store Catalog]);
		}
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

	// manual of secret door detection. skill: Secret door awareness
	item itemConsidering = $item[manual of secret door detection];
	if(can_read_skillbook(itemConsidering) && remainingCatalogCredits() > 0 && !auto_have_skill($skill[Secret door awareness]) && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
		use(itemConsidering);
		handleTracker("Mr. Store 2002","Claimed "+itemConsidering, "auto_iotm_claim");
	}
	//Pro skateboard to dupe tomb rat king drops
	itemConsidering = $item[pro skateboard];
	if(remainingCatalogCredits() > 0 && auto_is_valid(itemConsidering) && !possessEquipment(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
		handleTracker("Mr. Store 2002","Claimed "+itemConsidering, "auto_iotm_claim");
	}
	//FLUDA is +25% item, and a pickpocket
	itemConsidering = $item[Flash Liquidizer Ultra Dousing Accessory];
	if(remainingCatalogCredits() > 0 && auto_is_valid(itemConsidering) && !possessEquipment(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
		handleTracker("Mr. Store 2002","Claimed "+itemConsidering, "auto_iotm_claim");
	}
	// meat butler on day 1 of run
	itemConsidering = $item[meat butler];
	if(have_campground() && remainingCatalogCredits() > 0 && my_daycount() == 1 && !haveCampgroundMaid() && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
		use(itemConsidering);
		visit_url("campground.php"); // get butler meat
		handleTracker("Mr. Store 2002","Claimed "+itemConsidering, "auto_iotm_claim");
	}
	// giant black monolith. Mostly useful at low level for stats
	if (have_campground() && (my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean()) &&
	!(auto_haveSeptEmberCenser() || auto_haveTrainSet()) && !auto_ignoreExperience()) {
		itemConsidering = $item[giant black monolith];
		if(remainingCatalogCredits() > 0 && !(auto_get_campground() contains itemConsidering) && auto_is_valid(itemConsidering))
		{
			buy($coinmaster[Mr. Store 2002], 1, itemConsidering);
			use(itemConsidering);
			handleTracker("Mr. Store 2002","Claimed "+itemConsidering, "auto_iotm_claim");
			visit_url("campground.php?action=monolith");
		}
	}
	// crimbo cookie. Should we expand to buy more or use in more paths beyond HC LoL?
	itemConsidering = $item[Crimbo cookie sheet];
	if(remainingCatalogCredits() > 0 && in_hardcore() && my_daycount() == 1 && in_lol())
	{
		buy($coinmaster[Mr. Store 2002], remainingCatalogCredits(), itemConsidering);
		handleTracker("Mr. Store 2002","Claimed "+itemConsidering, "auto_iotm_claim");
	}
	// loathing idol microphone. Use remaining credits
	itemConsidering = $item[loathing idol microphone];
	if(remainingCatalogCredits() > 0 && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Mr. Store 2002], remainingCatalogCredits(), itemConsidering);
		handleTracker("Mr. Store 2002","Claimed "+itemConsidering, "auto_iotm_claim");
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

int auto_dousesRemaining()
{
	item fluda = $item[Flash Liquidizer Ultra Dousing Accessory];
	if (available_amount(fluda)<1 || !auto_is_valid(fluda))
	{
		return 0;
	}
	return 3-get_property("_douseFoeUses").to_int();
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
	
	if(canUse($skill[Aug. 24th: Waffle Day!]) && !get_property("_aug24Cast").to_boolean())
	{
		use_skill($skill[Aug. 24th: Waffle Day!]); //get some waffles to hopefully change some bad monsters to better ones
	}
	if(canUse($skill[Aug. 28th: Race Your Mouse Day!]) && !get_property("_aug28Cast").to_boolean() && pathHasFamiliar())
	{
		familiar hundred_fam = to_familiar(get_property("auto_100familiar"));
		if (((in_avantGuard() && in_hardcore()) || (hundred_fam != $familiar[none] && (isAttackFamiliar(hundred_fam) || hundred_fam.block))) && have_familiar(findRockFamiliarInTerrarium()))
		{
			use_familiar(findRockFamiliarInTerrarium());
			use_skill($skill[Aug. 28th: Race Your Mouse Day!]); //Fam equipment to lower weight of attack familiar or Burly bodyguard (Avant Guard) for Gremlins
		}
		else if(auto_needsGoodFamiliarEquipment() || in_small())
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
	//see how much mana cost reduction we can get (up to 3mp)
	simMaximizeWith("-1000mana cost");

	int manaCostMaximize = simValue("Mana Cost");
	if (!auto_turbo())
	{
		if(manaCostMaximize < 3 && canUse($skill[Aug. 30th: Beach Day!]) && !get_property("_aug30Cast").to_boolean() && get_property("_augSkillsCast").to_int()< 5)
		{
			use_skill($skill[Aug. 30th: Beach Day!]); //For -MP (and Rollover Adventures)
		}
	}
}

void auto_scepterRollover()
{
	//We don't want the baywatch if our accessory slots are already filled with > 7 adventure items or we if one of the slots is the counterclockwise watch
	boolean noWatch = ((numeric_modifier(equipped_item($slot[acc1]),"Adventures") >= 7 &&
	numeric_modifier(equipped_item($slot[acc2]),"Adventures") >= 7 &&
	numeric_modifier(equipped_item($slot[acc3]),"Adventures") >= 7) ||
		((is_watch(equipped_item($slot[acc1])) && numeric_modifier(equipped_item($slot[acc1]),"Adventures") >= 7) ||
		(is_watch(equipped_item($slot[acc2])) && numeric_modifier(equipped_item($slot[acc2]),"Adventures") >= 7) ||
		(is_watch(equipped_item($slot[acc3])) && numeric_modifier(equipped_item($slot[acc3]),"Adventures") >= 7)));
	if(!noWatch && canUse($skill[Aug. 30th: Beach Day!]) && !get_property("_aug30Cast").to_boolean() && get_property("_augSkillsCast").to_int()< 5)
	{
		use_skill($skill[Aug. 30th: Beach Day!]); //For Rollover adventures (and -MP)
		equipRollover(true);
	}
	//Get mainstats
	if(get_property("_augSkillsCast").to_int()< 5 && my_level() < 13)
	{
		if(canUse($skill[Aug. 12th: Elephant Day!]) && !get_property("_aug12Cast").to_boolean() && my_primestat() == $stat[muscle])
		{
			use_skill($skill[Aug. 12th: Elephant Day!]); //get muscle stubstats
		}
		if(canUse($skill[Aug. 11th: Presidential Joke Day!]) && !get_property("_aug11Cast").to_boolean() && my_primestat() == $stat[mysticality])
		{
			use_skill($skill[Aug. 11th: Presidential Joke Day!]); //get mysticality stubstats
		}
		if(canUse($skill[Aug. 23rd: Ride the Wind Day!]) && !get_property("_aug23Cast").to_boolean() && my_primestat() == $stat[moxie])
		{
			use_skill($skill[Aug. 23rd: Ride the Wind Day!]); //get moxies stubstats
		}
	}
	if(canUse($skill[Aug. 13th: Left\/Off Hander\'s Day!]) && !get_property("_aug13Cast").to_boolean() &&
	get_property("_augSkillsCast").to_int()< 5 && numeric_modifier(equipped_item($slot[off-hand]),"Adventures") >  0 && weapon_hands(equipped_item($slot[off-hand])) == 0)
	{
		use_skill($skill[Aug. 13th: Left\/Off Hander\'s Day!]); //bump up the off-hand
	}
	if(canUse($skill[Aug. 27th: Just Because Day!]) && !get_property("_aug27Cast").to_boolean() && get_property("_augSkillsCast").to_int()< 5)
	{
		use_skill($skill[Aug. 27th: Just Because Day!]); //3 random buffs
	}
}

void auto_lostStomach(boolean force)
{
	if(!auto_haveAugustScepter() || in_small() || fullness_limit()==0)
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
			case $monster[dirty old lihc]:
				return get_property("cyrptNicheEvilness").to_int() > 13;
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
			return ((get_property("cyrptAlcoveEvilness").to_int() - (5 * (5 + cyrptEvilBonus()))) > 13);
		case $monster[dirty old lihc]:
		 	// only worth it if we need 18 or more evilness reduced.
			// avant guard makes free fights cost a turn. Use DOL in place of tentacle
			return (in_avantGuard() && (get_property("cyrptNicheEvilness").to_int() - (5 * (3 + cyrptEvilBonus()))) > 13);
		case $monster[lobsterfrogman]:
		 	// only worth it if we need 3+ barrels
		 	boolean sonofa_complete = get_property("sidequestLighthouseCompleted") == "hippy" || get_property("sidequestLighthouseCompleted") == "fratboy";
			return (!sonofa_complete && item_amount($item[barrel of gunpowder])<4);
		case $monster[eldritch tentacle]:
			// Max tentacles fought being free is 11, so don't habitat if we've fought more than 6
			// This variable increments at the end of combat, so we need 5 here.
			if (get_property("_eldritchTentaclesFoughtToday").to_int() > 5)
			{
				return false;
			}
			// don't habitat free fights in avant guard
			return (!in_avantGuard() && (get_property("auto_habitatMonster").to_monster() == target || (get_property("_monsterHabitatsMonster").to_monster() == target && get_property("_monsterHabitatsFightsLeft").to_int() == 0)));
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
	if (!($phylums[Orc, Hippy] contains target && $locations[The Battlefield (Hippy Uniform), The Battlefield (Frat Uniform)] contains my_location()))
	{
		return false;
	}
	return true;
}

int auto_wishFactsLeft()
{
	if (!auto_haveBofa()) { return 0; }
	return 3-get_property("_bookOfFactsWishes").to_int();
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

boolean auto_haveEagle()
{
	if(canChangeToFamiliar($familiar[Patriotic Eagle]))
	{
		return true;
	}
	return false;
}

familiar auto_forceEagle(familiar famChoice)
{
	//Force the Patriotic Eagle if we used a banish recently and can't use one until we burn 11 combats with the Eagle
	if(auto_haveEagle() && get_property("screechCombats").to_int() > 0 && !auto_queueIgnore())
	{
		auto_log_info("Forcing Patriotic Eagle");
		return $familiar[Patriotic Eagle];
	}
	return famChoice;
}

boolean auto_canRWBBlast()
{
	if(!auto_haveEagle())
	{
		return false;
	}
	if(!(auto_is_valid($skill[%fn\, fire a Red\, White and Blue Blast])))
	{
		return false;
	}
	if(have_effect($effect[Everything Looks Red, White and Blue]) > 0)
	{
		//Already have ELRWB
		return false;
	}
	if(auto_habitatMonster() != $monster[none])
	{
		//don't want to RWB Blast a Habitated monster
		return false;
	}
	return true;
}

boolean auto_RWBBlastTarget(monster target)
{
	if(!auto_canRWBBlast())
	{
		return false;
	}
	switch(target)
	{
		case $monster[modern zmobie]:
			// only worth it if we need 15 or more evilness reduced
			return ((get_property("cyrptAlcoveEvilness").to_int() - (3 * (5 + cyrptEvilBonus()))) > 13);
		case $monster[dirty old lihc]:
			// only worth it if we need 9 or more evilness reduced.
			return ((get_property("cyrptNicheEvilness").to_int() - (3 * (3 + cyrptEvilBonus()))) > 13);
		default:
			return (get_property("rwbMonster").to_monster() == target);
	}
	return false;
}

int auto_rwbFightsLeft()
{
	if(auto_RWBMonster() != $monster[none])
	{
		return (3 - get_property("rwbMonsterCount").to_int());
	}
	return 0;
}

monster auto_RWBMonster()
{
	if(get_property("rwbMonsterCount").to_int() < 3)
	{
		return get_property("rwbMonster").to_monster();
	}
	return $monster[none];
}

string activeCitZoneMod() // get the active Citizen of a Zone mods, if any
{
	if(!auto_haveEagle() || have_effect($effect[Citizen of a Zone]) == 0)
	{
		return "";
	}
	visit_url("desc_effect.php?whicheffect=9391a5f7577e30ac3af6309804da6944"); // visit url to refresh Mafia's _citizenZoneMods preference
	string activeCitZoneMod = get_property("_citizenZoneMods").to_lower_case();
	return activeCitZoneMod;
}

boolean auto_citZoneModIsGoal(string goal)
{
	string activeCitZoneMod = activeCitZoneMod();

	if(contains_text(activeCitZoneMod, goal) || (goal == "spec" && contains_text(activeCitZoneMod, "cold resistance")))
	{
		return true;
	}
	return false;
}

boolean auto_citizenZonePrep(string goal)
{
	string activeCitZoneMod = activeCitZoneMod();
	if(my_meat() < meatReserve() && goal != "mp")
	{
		return false; //don't attempt to change if we don't have a lot of meat and we are going for something other than mp
	}
	if(have_effect($effect[Citizen of a Zone]) > 0 && contains_text(activeCitZoneMod, goal))
	{
		auto_log_info("No need to remove Citizen of a Zone");
		return false;
	}
	if(have_effect($effect[Citizen of a Zone]) > 0 && !contains_text(activeCitZoneMod, goal) && item_amount($item[Soft Green Echo Eyedrop Antidote]) == 0)
	{
		auto_log_info("Can't remove Citizen of a Zone");
		return false;
	}
	if(!(auto_citZoneModIsGoal(goal)) && item_amount($item[Soft Green Echo Eyedrop Antidote]) > 0) //try to remove Citizen of a Zone
	{
		uneffect($effect[Citizen of a Zone]);
		if(have_effect($effect[Citizen of a Zone]) > 0)
		{
			auto_log_debug("Tried to remove Citizen of a Zone but couldn't");
			return false;
		}
	}
	return true;
}

boolean[location] citizenZones(string goal)
{
	if(goal == "meat")
	{
		return $locations[The Battlefield (Frat Uniform), The Battlefield (Hippy Uniform), The Hidden Hospital, The Haunted Bathroom, The Castle in the Clouds in the Sky (Basement),
	Lair of the Ninja Snowmen, The Defiled Cranny, The Laugh Floor, The Batrat and Ratbat Burrow, The Sleazy Back Alley];
	}
	if(goal == "item")
	{
		return $locations[The Haunted Laundry Room, Whitey's Grove, The Icy Peak, Itznotyerzitz Mine,
	The Dark Heart of the Woods, The Hidden Temple, The Haunted Library, The Bat Hole Entrance, Noob Cave];
	}
	if(goal == "init")
	{
		return $locations[The Feeding Chamber, An Unusually Quiet Barroom Brawl, Oil Peak, Cobb's Knob Kitchens,
		The VERY Unquiet Garves, The Haunted Kitchen];
	}
	if(goal == "mp")
	{
		return $locations[The Upper Chamber, Inside the Palindome, A-boo Peak, The Hippy Camp, Megalo-City, Shadow Rift, Vanya's Castle,
		The Hatching Chamber, Wartime Hippy Camp (Frat Disguise), The Orcish Frat House, The Middle Chamber, The Black Forest,	The Haunted Ballroom,
		The Red Zeppelin, The Hidden Park, Twin Peak, The Smut Orc Logging Camp, The Daily Dungeon, The Spooky Forest];
	}
	if(goal == "spec")
	{
		//prismatic resistance
		return $locations[The Outskirts of Cobb\'s Knob];
	}
	return $locations[none];
}
boolean auto_getCitizenZone(location loc, boolean inCombat)
{
	familiar eagle = $familiar[Patriotic Eagle];
	//zones are approximately organized by autoscend level quest structure
	boolean[location] meatZones = citizenZones("meat");
	boolean[location] itemZones = citizenZones("item");
	boolean[location] initZones = citizenZones("init");
	//mp zones are organized by 20-30 mp regen then 10-15 mp regen and then approximately autoscend level quest structure
	boolean[location] mpZones = citizenZones("mp");
	boolean[location] specZones = citizenZones("spec");
	string activeCitZoneMod = activeCitZoneMod();
	string goal;
	
	if(!can_adventure(loc))
	{
		return false;
	}
	//set goal for tracking
	if(specZones contains loc)
	{
		
		//only want spec to get cold res for septEmberCenser usage and only if we don't get to L13. Don't want to do this outside of D1
		//ideally also have spring away or some other free run
		if((auto_goingToMouthwashLevel() && expected_level_after_mouthwash() < 13) && turns_played() == 0)
		{
			goal = "spec";
		}
	}
	if(meatZones contains loc)
	{
		goal = "meat";
	}
	else if(itemZones contains loc)
	{
		goal = "item";
	}
	else if(initZones contains loc)
	{
		goal = "init";
	}
	else if(mpZones contains loc)
	{
		goal = "mp";
	}
	else
	{
		//if for some reason we make it into the location getCitizenZone and it's not in any of the defined zones, get the item buff
		auto_log_debug("Somehow we got here and don't actually want to use the Eagle");
		return false;
	}
	if(!auto_citizenZonePrep(goal))
	{
		return false;
	}

	boolean wantToFreeRun()
	{
		if(loc == solveDelayZone())
		{
			return true;
		}
		return false;
	}
	if(!inCombat)
	{
		if(use_familiar(eagle))
		{
			if(wantToFreeRun())	set_property("auto_forceFreeRun", true);
			if(!autoAdv(loc))
			{
				auto_log_debug("Attempted to get citizen of a zone buff for " + goal + " goal however we failed.");
				return false;
			}
		}
	}
	else
	{
		handleTracker("Citizen of a Zone", my_location().to_string(), goal, "auto_otherstuff");
		return true;
	}
	return false;
}

boolean auto_getCitizenZone(string goal)
{
	boolean[location] zones = citizenZones(goal);

	if(!auto_citizenZonePrep(goal))
	{
		return false;
	}

	foreach loc in zones
	{
		if(!can_adventure(loc))
		{
			continue;
		}
		return auto_getCitizenZone(loc, false);
	}
	return false;
}

boolean auto_haveBurningLeaves()
{
	return auto_is_valid($item[A Guide to Burning Leaves]) && get_campground() contains $item[A Guide to Burning Leaves];
}

boolean auto_initBurningLeaves()
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
	return available_amount($item[rake]) > 0;
}

boolean auto_defaultBurnLeaves()
{
	// Returns true if we made everything we want, false if anything fails.
	if (!auto_haveBurningLeaves())
	{
		return false;
	}

	auto_initBurningLeaves();

	boolean success = true;

	if (!(get_campground() contains $item[forest canopy bed]) && get_dwelling() != $item[big rock] && auto_haveCincho() && creatable_amount($item[forest canopy bed])>0)
	{
		// get and use the forest canopy bed if we don't have one already and have a Cincho as it is +5 free rests
		if (create(1, $item[forest canopy bed]))
		{
			handleTracker("Burning Leaves", "Claimed " + $item[forest canopy bed], "auto_iotm_claim");
			success = success && use(1, $item[forest canopy bed]);
		}
		else
		{
			return false;
		}
	}

	if (get_campground() contains $item[forest canopy bed] && have_effect($effect[Resined]) == 0 && creatable_amount($item[distilled resin])>0)
	{
		// Get the Resined effect if we don't have it as it is net positive for leaves.
		if (create(1, $item[distilled resin]))
		{
			handleTracker("Burning Leaves", "Claimed " + $item[distilled resin], "auto_iotm_claim");
			success = success && use(1, $item[distilled resin]);
		}
		else
		{
			return false;
		}
	}

	if (in_avantGuard() && item_amount($item[Autumnic bomb]) == 0  && creatable_amount($item[Autumnic bomb])>0)
	{
		if (create(1, $item[Autumnic bomb])) //Reduces enemy hp in half, useful for bodyguards with 40K hp
		{
			handleTracker("Burning Leaves", "Claimed " + $item[Autumnic bomb], "auto_iotm_claim");
		}
		else
		{
			success = false;
		}
	}

	if (!isGuildClass() && get_campground() contains $item[forest canopy bed])
	{
		success = success && auto_makeAutumnalAegis(); // +2 resistance to all elements, 250 DA (for megalo-city with no tao)
	}
	return success;
}

boolean auto_makeAutumnalAegis()
{
	if (!auto_haveBurningLeaves())
	{
		return false;
	}
	if (creatable_amount($item[Autumnal Aegis]) > 0 && item_amount($item[Autumnal Aegis]) == 0)
	{
		if (create(1, $item[Autumnal Aegis])) // So-so resistance to all elements, 250 DA (for megalo-city)
		{
			handleTracker("Burning Leaves", "Claimed " + $item[Autumnal Aegis], "auto_iotm_claim");
		}
	}
	return available_amount($item[Autumnal Aegis]) > 0;
}

int auto_remainingBurningLeavesFights()
{
	if (!auto_haveBurningLeaves())
	{
		return 0;
	}
	return 5-get_property("_leafMonstersFought").to_int();
}

boolean auto_fightFlamingLeaflet()
{
	if (auto_remainingBurningLeavesFights() < 1)
	{
		return false;
	}
	if(available_amount($item[inflammable leaf]) < 11)
	{
		return false;
	}

	if(auto_haveTearawayPants())
	{
		addBonusToMaximize($item[tearaway pants], 500); // plants give turns when you tearaway
	}

	string[int] pages;
	pages[0] = "campground.php?preaction=leaves";
	pages[1] = "choice.php?pwd&whichchoice=1510&option=1&leaves=11";
	return autoAdvBypass(0, pages, $location[Noob Cave], "");
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
	 The Penultimate Fantasy Airship - Get an umbrella for basement, only if we don't have one.
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
	   || (place == $location[The eXtreme Slope] && (!possessEquipment($item[eXtreme scarf]) && !possessEquipment($item[snowboarder pants]) && !auto_haveMcHugeLargeSkis()))
	   || (place == $location[The Copperhead Club] && (item_amount($item[priceless diamond]) == 0 && item_amount($item[Red Zeppelin Ticket]) == 0) && !get_property("candyCaneSwordCopperheadClub").to_boolean())
	   || (place == $location[The Defiled Cranny] && !get_property("candyCaneSwordDefiledCranny").to_boolean())
	   || (place == $location[The Black Forest] && !get_property("candyCaneSwordBlackForest").to_boolean())
	   || (place == $location[The Hidden Apartment Building] && !get_property("candyCaneSwordApartmentBuilding").to_boolean())
	   || (place == $location[An Overgrown Shrine (Northeast)] && !get_property("_candyCaneSwordOvergrownShrine").to_boolean() && get_property("hiddenOfficeProgress").to_int() > 0)
	   || (place == $location[The Overgrown Lot] && !get_property("_candyCaneSwordOvergrownLot").to_boolean())
	   || (place == $location[The Penultimate Fantasy Airship] && L10_needUmbrella())
	   || ((place == $location[Wartime Frat House] && possessOutfit("War Hippy Fatigues")) || (place == $location[Wartime Hippy Camp] && possessOutfit("Frat Warrior Fatigues")))
	   || ($locations[The Sleazy Back Alley, A Mob of Zeppelin Protesters, The Daily Dungeon]) contains place)
	{
		return true;
	}
	return false;
}

int auto_remainingCandyCaneSlashes()
{
	if (!auto_haveCCSC())
	{
		return 0;
	}
	return 11-get_property("_surprisinglySweetSlashUsed").to_int();
}

int auto_remainingCandyCaneStabs()
{
	if (!auto_haveCCSC())
	{
		return 0;
	}
	return 11-get_property("_surprisinglySweetStabUsed").to_int();
}

