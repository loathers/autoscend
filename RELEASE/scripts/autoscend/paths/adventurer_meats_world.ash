boolean in_amw()
{
	return my_path() == $path[Adventurer Meats World];
}

void amw_initializeSettings()
{
	if(!in_amw())
	{
		return;
	}
	set_property("auto_wandOfNagamar", false);
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
	// not sure how to tell if we can afford adventures yet, so attempting even if we can't afford
	// UPDATE: can tell if we can afford now, just not implemented yet
	int starting_meat = my_meat();
	visit_url("place.php?whichplace=meatground&action=meatground_turns");
	string url = `choice.php?whichchoice=1593&pwd&option=1`;
	visit_url(url, true);

	// successful if meat was spent
	if (my_meat() < starting_meat){return true;}
	// need to exit choice if unsuccessful
	url = `choice.php?whichchoice=1593&pwd&option=6`;
	visit_url(url, true);
	return false;
}

// following code to decide which stats to buy modeled after Path of the Plumber
record amw_statBuyable {
	stat st;
	int amount;
};

// returns a record of the (sub)stat and how much of that (sub)stat we want next
// prioritizing getting all of the skills for now
amw_statBuyable amw_nextStat()
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

// reserves meat from being spent on stats
// TODO: take into account how much meat is needed for the next bundle of 10
// TODO: take into account quests state (can reserve less if expensive things won't be bought soon)
int amw_calculateReserve()
{
	int current_level = my_level();
	if (current_level <= 4)
	{
		return 500;
	}
	else if (current_level <= 8)
	{
		return 1200;
	}
	else if (current_level <= 9)
	{
		return 2100;
	}
	else if (current_level <= 10)
	{
		return 4500;
	}
	else
	{
		return 6500; // enough to ensure that travel documents + shore won't bankrupt us
	}
}

int amw_substatsBuyable(amw_statBuyable goal)
{
	int meat_reserve = amw_calculateReserve();
	if (meat_reserve >= my_meat()){return 0;} // no meat unreserved to spend on stats
	int substats_to_goal = (goal.amount - my_basestat(goal.st));
	auto_log_debug("Substats to next goal: " + to_string(substats_to_goal));

	// return either the meat within budget or the substats we need to reach the goal
	return min(my_meat()-meat_reserve, substats_to_goal);
}

boolean amw_buyStats()
{
	amw_statBuyable next = amw_nextStat();
	if (next.amount != 0)
	{
		int amountToBuy = amw_substatsBuyable(next);
		if (amountToBuy > 0)
		{
			return amw_buySubstat(next.st, amountToBuy);
		}
	}
	return false;
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
	abort("You need more meat to get the next level. This isn't implemented, so you're going to have to do it manually.");
	return false;
}
