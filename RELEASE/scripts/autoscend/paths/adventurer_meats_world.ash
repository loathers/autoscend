boolean in_amw()
{
	return my_path() == $path[Adventurer Meats World];
}

boolean amw_initializeSettings()
{
	set_property("auto_wandOfNagamar", false);
	return false;
}

boolean amw_canAfford(skill sk)
{
	return my_meat() >= (10 + meat_cost(sk));
}

boolean amw_buySubstat(stat st, int numberToBuy)
// buys in terms of substats, whether st is a stat or a substat
{
	auto_log_debug("Buying " + to_string(numberToBuy) + " substats.");
	if (numberToBuy > my_meat()){return false;}

	// setting which substat to buy
	int option = 0;
	if (st == $stat[muscle] || st == $stat[submuscle]){
		option = 1;
	}
	if (st == $stat[mysticality] || st == $stat[submysticality]){
		option = 2;
	}
	if (st == $stat[moxie] || st == $stat[submoxie]){
		option = 3;
	}

	if (option != 0){
		visit_url("place.php?whichplace=meatground&action=meatground_stats");
		string url = `choice.php?whichchoice=1592&pwd&option={to_string(option)}&num={to_string(numberToBuy)}`;
		visit_url(url, true);
		return true;
	}
	return false;
}
// Calculates how many adventures we get in the smallest bundle/package/whatever
int amw_advPerTrade()
{
	int advs_per_trade = 10;
	if (auto_have_skill($skill[Pork Belly]))
	{
		advs_per_trade += 1;
	}
	if (auto_have_skill($skill[Umami]))
	{
		advs_per_trade += 1;
	}
	if (auto_have_skill($skill[Grass-Fed]))
	{
		advs_per_trade += 1;
	}
	return advs_per_trade;
}

// Parses the cost of the (adv_bundles)-th bundle
// if non-cumulative, subtracts the cost of the previous bundles to calculate the cost of the "last" trade of 10-13 advs in the bundle
int amw_advBundleCost(int adv_bundles, boolean cumulative)
{
	if (adv_bundles > 5 || adv_bundles < 1)
	{
		abort("I can't calculate the cost of the "+to_string(adv_bundles)+"-th bundle!");
	}
	int adventure_count = adv_bundles * amw_advPerTrade();
	string amino_sac = visit_url("place.php?whichplace=meatground&action=meatground_turns");
   	matcher adv_meat_matcher = create_matcher('"Get '+to_string(adventure_count)+' Adventures">[^>]*>[^>]*>\s*([0-9]+) meat', amino_sac);
	int meat_cost;
	if ( adv_meat_matcher.find() ) {
		meat_cost = to_int(group(adv_meat_matcher,1));
	}
	if (adv_bundles != 1 && !cumulative)
	{
		meat_cost = meat_cost - amw_advBundleCost(adv_bundles-1, true);
	}
	return meat_cost;
}
// By default, assume the adv cost is supposed to be cumulative (because costs are displayed cumulatively)
int amw_advBundleCost(int adv_bundles)
{
	return amw_advBundleCost(adv_bundles, true);
}

// attempt to buy the cheapest bundle of advs
boolean amw_buyAdv()
{
	int starting_meat = my_meat();
	if (
		starting_meat + 50 < amw_advBundleCost(1) || // if true, can't afford adventures
		(isAboutToPowerlevel() && amw_advBundleCost(1) > 2000 && my_level() < 13) // don't want to be spending more on adventures
		// if it's greater than our mpa and we are powerleveling. note the big jump between the 11th and 12th trade; ~1200 --> ~7000
		) 
	{
		return false;
	}
	visit_url("place.php?whichplace=meatground&action=meatground_turns");
	string url = `choice.php?whichchoice=1593&pwd&option=1`;
	visit_url(url, true);

	// successful if meat was spent
	if (my_meat() < starting_meat){return true;}
	return false;
}

// following code to decide which stats to buy modeled after Path of the Plumber
record amw_statBuyable {
	stat st;
	int amount;
};

// returns a record of the substat and how much of that substat we want for our next skill(s)
// prioritizing getting all of the skills currently
amw_statBuyable amw_nextSkillSubstats()
{
	amw_statBuyable goal;
	// getting elemental res for kitchen
	if (my_basestat($stat[muscle]) < 10)
	{
		goal.st = $stat[submuscle];
		goal.amount = 100;
		return goal;
	}
	// survivability
	else if (my_basestat($stat[moxie]) < 10)
	{
		goal.st = $stat[submoxie];
		goal.amount = 100;
		return goal;
	}
	// more elemental res/item drop/famwt/in-combat heal/elem dmg
	else if (my_basestat($stat[mysticality]) < 50)
	{
		goal.st = $stat[submysticality];
		goal.amount = 2500;
		return goal;
	}
	// getting some HP
	else if (my_basestat($stat[muscle]) < 30)
	{
		goal.st = $stat[submuscle];
		goal.amount = 900;
		return goal;
	}
	// survivability
	else if (my_basestat($stat[moxie]) < 30)
	{
		goal.st = $stat[submoxie];
		goal.amount = 900;
		return goal;
	}
	// +1 adv per bundle
	else if (my_basestat($stat[mysticality]) < 70)
	{
		goal.st = $stat[submysticality];
		goal.amount = 4900;
		return goal;
	}
	// +20 adv per day/survivability
	else if (my_basestat($stat[moxie]) < 50)
	{
		goal.st = $stat[submoxie];
		goal.amount = 2500;
		return goal;
	}
	// item/meat cute and lvl 11
	else if (my_basestat($stat[mysticality]) < 104)
	{
		goal.st = $stat[submysticality];
		goal.amount = 10816;
		return goal;
	}
	// -combat, elemental res
	else if (my_basestat($stat[moxie]) < 90)
	{
		goal.st = $stat[submoxie];
		goal.amount = 8100;
		return goal;
	}
	// tad more hp. necessary??
	else if (my_basestat($stat[muscle]) < 50)
	{
		goal.st = $stat[submuscle];
		goal.amount = 2500;
		return goal;
	}
	// +1 adv per bundle/lvl 12
	else if (my_basestat($stat[moxie]) < 125)
	{
		goal.st = $stat[submoxie];
		goal.amount = 15625;
		return goal;
	}
	// +1 adv per bundle
	else if (my_basestat($stat[muscle]) < 100)
	{
		goal.st = $stat[submuscle];
		goal.amount = 10000;
		return goal;
	}
	// initiative
	else if (my_basestat($stat[mysticality]) < 110)
	{
		goal.st = $stat[submysticality];
		goal.amount = 12100;
		return goal;
	}
	// level 13 if not d1
	else if (my_daycount() > 1 && my_basestat($stat[moxie]) < 148)
	{
		goal.st = $stat[submoxie];
		goal.amount = 21904;
		return goal;
	}

	goal.amount = 0; //represents no more stats wanted
	return goal;
}

// returns substats needed to get to next level
amw_statBuyable amw_nextLevelSubstats()
{
	int next_level;
	amw_statBuyable goal;
	next_level = my_level() + 1;
	stat mainstat = $stat[submysticality];
	// which stat is our mainstat should be mostly consistent with the priority of amw_nextSkillSubstats()
	// the difference between that function and this one is that this focuses on leveling priority if we have to meatlevel,
	// while the other one focuses on acquiring skills
	if (next_level == 12 || next_level == 13){
		mainstat = $stat[submoxie];
	}
	goal.st = mainstat;
	goal.amount = ((next_level-1)**2 + 4)**2;
	return goal;
}

// reserves meat from being spent on stats
int amw_calculateReserve()
{
	int current_level = my_level();
	int reserve;
	if (current_level <= 4)
	{
		reserve = 500;
	}
	else if (current_level <= 8)
	{
		reserve = 1200;
	}
	else if (current_level <= 9)
	{
		reserve = 2100;
	}
	else if (current_level <= 10)
	{
		reserve = 4500;
	}
	else
	{
		reserve = 6500; // enough to ensure that travel documents + shore won't bankrupt us
	}

	// save for two adventure trades for now, if that is greater
	return max(reserve, amw_advBundleCost(2, false));
}

int amw_substatsBuyable(amw_statBuyable goal, boolean meatleveling)
{
	int meat_reserve;
	if (!meatleveling) {meat_reserve = amw_calculateReserve();} // don't use all our meat if we don't have to
	else if (my_level() == 10) {meat_reserve = 5000;}
	else {meat_reserve = 50;} // possibly ok to spend down if we can level up and are meatleveling. except lvl 11 bc we need to shore anyway.

	if (meat_reserve >= my_meat()){return 0;} // no meat unreserved to spend on stats
	int substats_to_goal = (goal.amount - my_basestat(goal.st));
	auto_log_debug("Substats to next goal: " + to_string(substats_to_goal));

	if (!meatleveling)
	{
		// return either the meat within budget or the substats we need to reach the goal
		return min(my_meat()-meat_reserve, substats_to_goal);
	}
	// only dip into our reserves to meatlevel if we can reach the next level
	else if (my_meat()-meat_reserve >= substats_to_goal)
	{
		return substats_to_goal;
	}
	else {return 0;}
}
// by default we aren't meatleveling
int amw_substatsBuyable(amw_statBuyable goal)
{
	return amw_substatsBuyable(goal, false);
}

boolean amw_buyStats(boolean meatleveling)
{
	amw_statBuyable next;
	if (meatleveling)
	{
		// fetch substats to get to next level
		next = amw_nextLevelSubstats();
	}
	// fetch substats to get to next desired skill
	else {next = amw_nextSkillSubstats();}

	if (next.amount != 0)
	{
		int amountToBuy = amw_substatsBuyable(next, meatleveling);
		if (amountToBuy > 0)
		{
			return amw_buySubstat(next.st, amountToBuy);
		}
	}
	return false;
}
boolean amw_buyStats()
{
	return amw_buyStats(false);// do not meatlevel by default
}

boolean LM_adventurerMeatsWorld()
{
	//this function is called early once every loop of doTasks() in autoscend.ash
	//if something in this function returns true then it will restart the loop and get called again.
	if(!in_amw())
	{
		return false;
	}
	if (amw_buyStats()){return true;} // want to run again to put meat towards the next goal if applicable

	// this probably isn't the "right" place to add adventures...?
	if (my_adventures() <= 6)
	{
		amw_buyAdv();
	}

	// if user hasn't gotten meat to get skills/stats after turn 8 we want to make sure we get some 
	// to avoid beaten up and to progress properly
	// mobius ring and/or pulling meat avoid this
	if (turns_played() > 8 && my_basestat($stat[moxie]) < 10)
	{
		auto_log_info("Low meat after 8 turns, going to meatfarm");
		return LX_attemptPowerLevelMeat();
	}
	return false;
}

// if false, socp will not be preferred (e.g. won't be more preferred than a fairychaun when item is wanted)
// additionally, a meat familiar will be selected if not necessary for anything else
boolean amw_wantMeat()
{
	if (!in_amw() || amw_calculateReserve() + 100 < my_meat())
	{
		return false;
	}
	return true;
}

boolean LX_attemptPowerLevelMeat()
{
	// setting the parameter of buyStats to true drastically lowers meat reserve requirements
	if (amw_buyStats(true)){return true;}
	//abort("You need more meat to get the next level. This isn't implemented, so you're going to have to do it manually.");
	//return false;
	addToMaximize("200meat");
	autoMaximize("meat drop", false);
	handleFamiliar(lookupFamiliarDatafile("meat"));
	int meatDrop = simValue("Meat Drop");
	// "best" meatleveling zone at top
	// maybe add clovering if this is too slow
	if (meatDrop >= 300 && zone_isAvailable($location[The Hidden Hospital], true))
	{
		// could lower meatDrop a bit when janitor is banished
		return autoAdv($location[The Hidden Hospital]);
	}
	else if (zone_isAvailable($location[The Haunted Bedroom], true))
	{
		return autoAdv($location[The Haunted Bedroom]);
	}
	// only worth it with banishes
	//else if (zone_isAvailable($location[The Icy Peak], true))
	//{
		//return autoAdv($location[The Haunted Bedroom]);
	//}
	else if (zone_isAvailable($location[Cobb's Knob Treasury], true))
	{
		return autoAdv($location[Cobb's Knob Treasury]);
	}
	//else if ( level 3 quest started?)
	//{
		// pretentious artist rat whiskers
	//}
	else if (my_adventures() > 3)
	{
		int choice = 1;
		if (my_adventures() > 10){choice = 4;}
		visit_url("place.php?whichplace=town&action=town_oddjobs");
		run_choice(choice);
		return true;
		// 93? MPA, odd jobs board :p
	}
	return false;
}