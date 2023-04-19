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
	return auto_is_valid(paw) && item_amount(paw) > 0;
}

boolean auto_makeMonkeyPawWish(effect wish)
{
	boolean success = monkey_paw(wish);
	if (success) {
		handleTracker(to_string($item[cursed monkey\'s paw]), to_string(wish), "auto_wishes");
	}
	return success;
}

boolean auto_makeMonkeyPawWish(item wish)
{
	boolean success = monkey_paw(wish);
	if (success) {
		handleTracker(to_string($item[cursed monkey\'s paw]), to_string(wish), "auto_wishes");
	}
	return success;
}

boolean auto_makeMonkeyPawWish(string wish)
{
	boolean success = monkey_paw(wish);
	if (success) {
		handleTracker(to_string($item[cursed monkey\'s paw]), wish, "auto_wishes");
	}
	return success;
}
